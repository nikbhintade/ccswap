// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {
    CCIPLocalSimulator,
    IRouterClient,
    LinkToken,
    BurnMintERC677Helper
} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";

import {CCSwap} from "src/CCSwap.sol";

contract CCSwapTest is Test {
    CCIPLocalSimulator public ccipLocalSimulator;
    CCSwap public sender;
    CCSwap public receiver;

    uint64 public destinationChainSelector;

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();

        (
            uint64 chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            ,
            LinkToken link,
            BurnMintERC677Helper ccipBnM,
        ) = ccipLocalSimulator.configuration();

        sender = new CCSwap(address(sourceRouter), address(link), address(ccipBnM));
        receiver = new CCSwap(address(destinationRouter), address(link), address(ccipBnM));
        destinationChainSelector = chainSelector;
    }

    function testSendAndReceiveCrossChainMessage() external {
        ccipLocalSimulator.requestLinkFromFaucet(address(sender), 5 ether);

        string memory messageToSend = "Hello from Base Sepolia to Arbitrum Sepolia!";

        bytes32 messageId = sender.sendMessage(destinationChainSelector, 350_000, address(receiver), messageToSend);
        (bytes32 latestMessageId, uint64 latestSourceChainSelector, address latestSender, string memory latestMessage) =
            receiver.getLatestMessageDetails();

        assertEq(latestMessageId, messageId);
        assertEq(latestSourceChainSelector, destinationChainSelector);
        assertEq(latestSender, address(sender));
        assertEq(latestMessage, messageToSend);
    }
}
