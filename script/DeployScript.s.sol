// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {console2 as console} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";
import {NetworkDetailsLoader} from "./utils/NetworkDetailsLoader.sol";

contract DeployScript is NetworkDetailsLoader {
    function run() external {
        address ccipRouter;

        if (block.chainid == 421614) {} else if (block.chainid == 84532) {
            ccipRouter = 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93;
        } else if (block.chainid == 11155111) {
            ccipRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
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
