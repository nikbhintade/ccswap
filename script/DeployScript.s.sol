// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {console2 as console} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";
import {NetworkDetailsLoader} from "./utils/NetworkDetailsLoader.sol";

contract DeployScript is NetworkDetailsLoader {
    function run(string calldata network) external {
        NetworkDetailsLoader.NetworkDetails memory networkDetails = load(network);

        vm.startBroadcast();
        CCSwap ccswap = new CCSwap(networkDetails.router, networkDetails.linkToken, networkDetails.ccipBnM);
        vm.stopBroadcast();
        console.log("CCSwap deployed at:", address(ccswap));

        // Optionally, you can verify the contract on Etherscan or any other block explorer
    }
}
