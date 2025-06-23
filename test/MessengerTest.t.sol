// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Test, console2 as console} from "forge-std/Test.sol";
import {
    CCIPLocalSimulator,
    IRouterClient,
    LinkToken,
    BurnMintERC677Helper
} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";

import {Messenger} from "src/Messenger.sol";

contract MessengerTest is Test {
    CCIPLocalSimulator public ccipLocalSimulator;
    Messenger public sender;
    Messenger public receiver;

    BurnMintERC677Helper public s_ccipBnM;

    uint64 public destinationChainSelector;

    function setUp() public {

        // dummy uniswap router address
        address uniRouter = address(0);

        ccipLocalSimulator = new CCIPLocalSimulator();

        (
            uint64 chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            ,
            LinkToken link,
            BurnMintERC677Helper ccipBnM,
        ) = ccipLocalSimulator.configuration();

        s_ccipBnM = ccipBnM;

        sender = new Messenger(address(sourceRouter), address(link), address(ccipBnM), uniRouter);
        console.log("Sender address:", address(sender));
        receiver = new Messenger(address(destinationRouter), address(link), address(ccipBnM), uniRouter);
        console.log("Receiver address:", address(receiver));
        
        destinationChainSelector = chainSelector;
    }

    function testSendAndReceiveCrossChainMessage() external {
        s_ccipBnM.drip(address(sender));
        s_ccipBnM.drip(address(sender));

        uint256 balance = s_ccipBnM.balanceOf(address(sender));
        console.log("Sender's ccipBnM balance:", balance);
        uint256 receiverBalance = s_ccipBnM.balanceOf(address(receiver));
        console.log("Receiver's ccipBnM balance:", receiverBalance);

        ccipLocalSimulator.requestLinkFromFaucet(address(sender), 5 ether);

        string memory messageToSend = "Hello from Base Sepolia to Arbitrum Sepolia!";

        // Send a message from sender to receiver on the destination chain
        bytes32 messageId = sender.sendMessage(destinationChainSelector, 350_000, address(receiver), messageToSend);

        // get details of the latest message received by the receiver
        (bytes32 latestMessageId, uint64 latestSourceChainSelector, address latestSender, string memory latestMessage) =
            receiver.getLatestMessageDetails();

        balance = s_ccipBnM.balanceOf(address(sender));
        console.log("Sender's ccipBnM balance after sending message:", balance);
        receiverBalance = s_ccipBnM.balanceOf(address(receiver));
        console.log("Receiver's ccipBnM balance after receiving message:", receiverBalance);

        assertEq(latestMessageId, messageId);
        assertEq(latestSourceChainSelector, destinationChainSelector);
        assertEq(latestSender, address(sender));
        assertEq(latestMessage, messageToSend);
    }
}
