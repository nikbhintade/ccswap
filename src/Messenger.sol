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

contract Messenger is CCIPReceiver, OwnerIsCreator {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event MessageReceived(bytes32 messageId, string message, address sender, address tokenAddress, uint256 tokenAmount);
    event MessageSent(bytes32 messageId, string message, address receiver);

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    IERC20 private s_linkToken;
    IERC20 private s_ccipBnM;
    address private s_uniRouter;

    // Note: fixed fee for mainnet release is not ideal so it should be replaced correct fees
    uint24 private constant POOL_FEE = 500; // 0.05% fee for Uniswap V3

    bytes32 latestMessageId;
    uint64 latestSourceChainSelector;
    address latestSender;
    string latestMessage;
    address private s_lastReceivedTokenAddress; // Store the last received token address.
    uint256 private s_lastReceivedTokenAmount; // Store the last received amount.

    constructor(address router, address link, address ccipBnM, address uniRouter) CCIPReceiver(router) {
        s_linkToken = IERC20(link);
        s_ccipBnM = IERC20(ccipBnM);
        s_uniRouter = uniRouter;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // swap: token address, receiver address, slipage
    function swap(
        uint64 destinationChainSelector,
        uint256 amount,
        address token0,
        address token1,
        address receiver,
        uint256 gasLimit
    ) external returns (bytes32 messageId) {
        // transfer token from sender to this contract
        IERC20 token = IERC20(token0);
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);

        // approve token for router
        TransferHelper.safeApprove(token0, s_uniRouter, amount);

        // ExactInputSingleParams for Uniswap V3
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: address(s_ccipBnM),
            fee: POOL_FEE,
            recipient: address(this),
            amountIn: amount,
            amountOutMinimum: amount - (amount / 200), // slipage in basis points
            sqrtPriceLimitX96: 0
        });

        // swap token for ccipBnM
        uint256 amountOut = IV3SwapRouter(s_uniRouter).exactInputSingle(params);
        require(amountOut > 0, "Swap failed: No ccipBnM received");

        // approve ccipBnM for router
        TransferHelper.safeApprove(address(s_ccipBnM), getRouter(), amountOut);

        // transfer ccipBnM to destination chain
        Client.EVM2AnyMessage memory ccipMessage =
            _buildCCIPMessage(receiver, address(s_linkToken), gasLimit, amountOut, "");
    }

    function sendMessage(uint64 destinationChainSelector, uint256 gasLimit, address receiver, string memory message)
        external
        returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory ccipMessage =
            _buildCCIPMessage(receiver, address(s_linkToken), gasLimit, 1 ether, message);

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(destinationChainSelector, ccipMessage);

        s_linkToken.transferFrom(msg.sender, address(this), fees);
        s_linkToken.approve(address(router), fees);
        s_ccipBnM.approve(address(router), 1 ether);

        messageId = router.ccipSend(destinationChainSelector, ccipMessage);
        emit MessageSent(messageId, message, receiver);

        return messageId;
    }

    function _buildCCIPMessage(
        address receiver,
        address feeTokenAddress,
        uint256 gasLimit,
        uint256 amount,
        string memory message
    ) internal view returns (Client.EVM2AnyMessage memory) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: address(s_ccipBnM), amount: amount});
        return Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(message),
            tokenAmounts: tokenAmounts, // No token transfers
            extraArgs: Client._argsToBytes(Client.GenericExtraArgsV2({gasLimit: gasLimit, allowOutOfOrderExecution: true})),
            feeToken: feeTokenAddress
        });
    }

    function getLatestMessageDetails() public view returns (bytes32, uint64, address, string memory) {
        return (latestMessageId, latestSourceChainSelector, latestSender, latestMessage);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        latestMessageId = message.messageId;
        latestSourceChainSelector = message.sourceChainSelector;
        latestSender = abi.decode(message.sender, (address));
        latestMessage = abi.decode(message.data, (string));

        s_lastReceivedTokenAddress = message.destTokenAmounts[0].token;
        s_lastReceivedTokenAmount = message.destTokenAmounts[0].amount;

        string memory msgData = abi.decode(message.data, (string));
        address sender = abi.decode(message.sender, (address));

        emit MessageReceived(message.messageId, msgData, sender, s_lastReceivedTokenAddress, s_lastReceivedTokenAmount);
    }
}
