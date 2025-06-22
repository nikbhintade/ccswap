// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {console2 as console} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";
import {NetworkDetailsLoader} from "./utils/NetworkDetailsLoader.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SendMessageScript is NetworkDetailsLoader {
    function run() external {
        address ccswapAddressBase = getDeployedAddress("baseSepolia", "CCSwap");
        address ccswapAddressArbitrum = getDeployedAddress("arbitrumSepolia", "CCSwap");

        console.log("CCSwap address on Base Sepolia:", ccswapAddressBase);
        console.log("CCSwap address on Arbitrum Sepolia:", ccswapAddressArbitrum);

        require(ccswapAddressBase != address(0) && ccswapAddressArbitrum != address(0), "CCSwap addresses not found");

        // Load network details for Base Sepolia and Arbitrum Sepolia
        NetworkDetailsLoader.NetworkDetails memory arbitrumSepoliaDetails = load("arbitrumSepolia");
        NetworkDetailsLoader.NetworkDetails memory baseSepoliaDetails = load("baseSepolia");

        CCSwap ccswap = CCSwap(ccswapAddressBase);
        IERC20 linkToken = IERC20(baseSepoliaDetails.linkToken);

        vm.startBroadcast();
        linkToken.approve(ccswapAddressBase, type(uint256).max);

        ccswap.sendMessage(
            arbitrumSepoliaDetails.chainSelector,
            350_000,
            ccswapAddressArbitrum,
            "Hello from Base Sepolia to Arbitrum Sepolia!"
        );

        linkToken.approve(ccswapAddressBase, type(uint256).min);
        vm.stopBroadcast();
        // Optionally, you can verify the contract on Etherscan or any other block explorer
    }
}
