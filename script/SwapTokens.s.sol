// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script, console2 as console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Token} from "src/utils/Token.sol";
import {IV3SwapRouter} from "src/interfaces/IV3SwapRouter.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract SwapTokens is Script {
    address private constant UNISWAP_SWAP_ROUTER_2 = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;

    function run() external {
        Token tokenA = Token(0x6110497BB349F84452b92E012B4D6394B5A41AC0);
        Token tokenB = Token(0x8325708abD29A98DA3988b43737eA7E82F7395B9);

        uint256 tokenBBalance = tokenB.balanceOf(msg.sender);
        console.log("Message Sender:", msg.sender);
        console.log("   Token B Balance:", tokenBBalance);

        uint24 fee = 500;

        uint256 amountToSwap = 1 ether;

        vm.startBroadcast();

        TransferHelper.safeApprove(address(tokenA), UNISWAP_SWAP_ROUTER_2, amountToSwap);

        IV3SwapRouter swapRouter = IV3SwapRouter(UNISWAP_SWAP_ROUTER_2);

        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: address(tokenA),
            tokenOut: address(tokenB),
            fee: fee,
            recipient: msg.sender,
            amountIn: amountToSwap,
            amountOutMinimum: amountToSwap - (amountToSwap / 200), // 0.5% slippage
            sqrtPriceLimitX96: 0
        });

        swapRouter.exactInputSingle(params);

        vm.stopBroadcast();

        tokenBBalance = tokenB.balanceOf(msg.sender);
        console.log("   Token B Balance after swap:", tokenBBalance);
    }
}
