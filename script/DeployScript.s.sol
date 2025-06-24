// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {console2 as console} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";
import {NetworkDetailsLoader} from "./utils/NetworkDetailsLoader.sol";

contract DeployScript is NetworkDetailsLoader {
    function run() external {
        address ccipRouter;

        if (block.chainid == 421614) {
            ccipRouter = 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165; // Arbitrum Sepolia
        } else if (block.chainid == 84532) {
            ccipRouter = 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93; // Base Sepolia
        } else if (block.chainid == 11155111) {
            ccipRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59; // Ethereum Sepolia
        } else if (block.chainid == 11155420) {
            ccipRouter = 0x114A20A10b43D4115e5aeef7345a1A71d2a60C57; // Optimism Sepolia
        } else {
            revert("Unsupported chain");
        }

        vm.startBroadcast();
        CCSwap ccswap = new CCSwap(ccipRouter);
        vm.stopBroadcast();
        console.log("CCSwap deployed at:", address(ccswap));

        // Optionally, you can verify the contract on Etherscan or any other block explorer
    }
}
