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

contract CCSwap is CCIPReceiver, OwnerIsCreator {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event MessageReceived(bytes32 messageId, string message, address sender);
    event MessageSent(bytes32 messageId, string message, address receiver);

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    IERC20 private s_linkToken;
    IERC20 private s_ccipBnM;

    bytes32 latestMessageId;
    uint64 latestSourceChainSelector;
    address latestSender;
    string latestMessage;

    constructor(address router, address link, address ccipBnM) CCIPReceiver(router) {
        s_linkToken = IERC20(link);
        s_ccipBnM = IERC20(ccipBnM);
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // swap: token address, receiver address, slipage
    function swap(
        uint64 destinationChainSelector,
        uint256 amount,
        uint256 slipage,
        address tokenAddress,
        address receiver
    ) external returns (bytes32 messageId) {
        // transfer token from sender to this contract
        IERC20 token = IERC20(tokenAddress);
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);

        // swap token for ccipBnM

        // transfer ccipBnM to destination chain
    }

    function sendMessage(uint64 destinationChainSelector, uint256 gasLimit, address receiver, string calldata message)
        external
        returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory ccipMessage = _buildCCIPMessage(receiver, message, address(s_linkToken), gasLimit);

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(destinationChainSelector, ccipMessage);

        s_linkToken.transferFrom(msg.sender, address(this), fees);
        s_linkToken.approve(address(router), fees);

        messageId = router.ccipSend(destinationChainSelector, ccipMessage);
        emit MessageSent(messageId, message, receiver);

        return messageId;
    }

    function getLatestMessageDetails() public view returns (bytes32, uint64, address, string memory) {
        return (latestMessageId, latestSourceChainSelector, latestSender, latestMessage);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        latestMessageId = message.messageId;
        latestSourceChainSelector = message.sourceChainSelector;
        latestSender = abi.decode(message.sender, (address));
        latestMessage = abi.decode(message.data, (string));

        string memory msgData = abi.decode(message.data, (string));
        address sender = abi.decode(message.sender, (address));

        emit MessageReceived(message.messageId, msgData, sender);
    }

    function _buildCCIPMessage(address receiver, string calldata message, address feeTokenAddress, uint256 gasLimit)
        internal
        pure
        returns (Client.EVM2AnyMessage memory)
    {
        return Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(message),
            tokenAmounts: new Client.EVMTokenAmount[](0), // No token transfers
            extraArgs: Client._argsToBytes(Client.GenericExtraArgsV2({gasLimit: gasLimit, allowOutOfOrderExecution: true})),
            feeToken: feeTokenAddress
        });
    }
}
