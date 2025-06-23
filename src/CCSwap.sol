// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

/// todo: cross-chain message passing with ccip
/// todo: cross-chain token transfers

import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {IV3SwapRouter} from "src/interfaces/IV3SwapRouter.sol";

contract CCSwap is CCIPReceiver, OwnerIsCreator {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event CCSwapInitiated(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address indexed sender,
        address token0,
        address token1,
        uint256 amountToken0
    );

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    // Note: fixed fee for mainnet release is not ideal so it should be replaced correct fees
    uint24 private constant POOL_FEE = 500; // 0.05% fee for Uniswap V3

    bytes32 latestMessageId;
    uint64 latestSourceChainSelector;
    address latestSender;
    string latestMessage;
    address private s_lastReceivedTokenAddress; // Store the last received token address.
    uint256 private s_lastReceivedTokenAmount; // Store the last received amount.

    mapping(uint256 => address) public destinationChainCCSwapAddress;
    mapping(uint256 => address) public uniswapRouterAddress;
    mapping(uint256 => address) public linkTokenAddressByChainSelector;
    mapping(uint256 => address) public ccipBnMAddressByChainSelector;
    mapping(uint64 => uint256) public chainIdByChainSelector;

    constructor(address router) CCIPReceiver(router) {}

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setChainConfig(
        uint256 blockChainId,
        address ccswap,
        address uniswapRouter,
        address linkToken,
        address ccipBnM
    ) external /* onlyOwner */ {
        destinationChainCCSwapAddress[blockChainId] = ccswap;
        uniswapRouterAddress[blockChainId] = uniswapRouter;
        linkTokenAddressByChainSelector[blockChainId] = linkToken;
        ccipBnMAddressByChainSelector[blockChainId] = ccipBnM;
    }

    function setChainIdByChainSelector(uint64 chainSelector, uint256 chainId) external /* onlyOwner */ {
        chainIdByChainSelector[chainSelector] = chainId;
    }

    // swap: token address, receiver address, slipage
    function swap(uint64 destinationChainSelector, uint256 amount, address token0, address token1, uint256 gasLimit)
        external
        returns (bytes32 messageId)
    {
        // transfer token from sender to this contract
        SafeERC20.safeTransferFrom(IERC20(token0), msg.sender, address(this), amount);

        // approve token for router
        TransferHelper.safeApprove(token0, uniswapRouterAddress[block.chainid], amount);

        // ExactInputSingleParams for Uniswap V3
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: address(ccipBnMAddressByChainSelector[block.chainid]),
            fee: POOL_FEE,
            recipient: address(this),
            amountIn: amount,
            amountOutMinimum: amount - (amount / 200), // slipage in basis points
            sqrtPriceLimitX96: 0
        });

        // swap token for ccipBnM
        uint256 amountOut = IV3SwapRouter(uniswapRouterAddress[block.chainid]).exactInputSingle(params);
        delete params;

        // approve ccipBnM for router
        TransferHelper.safeApprove(address(ccipBnMAddressByChainSelector[block.chainid]), getRouter(), amountOut);

        // create order. order structure: {receiver, token address}

        bytes memory order = abi.encode(msg.sender, token1);

        uint256 destinationChainId = chainIdByChainSelector[destinationChainSelector];

        // build CCIP message
        Client.EVM2AnyMessage memory ccipMessage = _buildCCIPMessage(
            destinationChainSelector,
            destinationChainCCSwapAddress[destinationChainId],
            address(linkTokenAddressByChainSelector[block.chainid]),
            gasLimit,
            amountOut,
            order
        );

        IRouterClient router = IRouterClient(getRouter());
        uint256 fees = router.getFee(destinationChainSelector, ccipMessage);

        IERC20(address(linkTokenAddressByChainSelector[block.chainid])).approve(getRouter(), fees);

        // send CCIP message
        messageId = IRouterClient(getRouter()).ccipSend(destinationChainSelector, ccipMessage);

        // emit CCSwapInitiated(messageId, destinationChainSelector, msg.sender, token0, token1, amount);
    }

    function _buildCCIPMessage(
        uint64 destinationChainSelector,
        address receiver,
        address feeTokenAddress,
        uint256 gasLimit,
        uint256 amount,
        bytes memory order
    ) internal view returns (Client.EVM2AnyMessage memory) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] =
            Client.EVMTokenAmount({token: address(ccipBnMAddressByChainSelector[block.chainid]), amount: amount});

        return Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: order,
            tokenAmounts: tokenAmounts, // No token transfers
            extraArgs: Client._argsToBytes(Client.GenericExtraArgsV2({gasLimit: gasLimit, allowOutOfOrderExecution: true})),
            feeToken: feeTokenAddress
        });
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        address uniswapRouter = uniswapRouterAddress[block.chainid];

        // Decode the message data
        (address receiver, address tokenAddress) = abi.decode(message.data, (address, address));

        // Get the amount of ccipBnM received
        uint256 amountReceived = message.destTokenAmounts[0].amount;
        address tokenReceived = message.destTokenAmounts[0].token;

        // approve the token amount for uniswap router
        TransferHelper.safeApprove(tokenReceived, uniswapRouter, amountReceived);

        // exactInputSingleParams for Uniswap V3
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: address(ccipBnMAddressByChainSelector[block.chainid]),
            tokenOut: tokenAddress,
            fee: POOL_FEE,
            recipient: receiver,
            amountIn: amountReceived,
            amountOutMinimum: amountReceived - (amountReceived / 200), // slipage in basis points
            sqrtPriceLimitX96: 0
        });

        // swap ccipBnM for token
        IV3SwapRouter(uniswapRouter).exactInputSingle(params);
    }
}
