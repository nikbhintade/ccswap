// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";

contract SetConfig is Script {
    address[] ccswapAddresses;
    address[] uniswapRouterAddresses;
    address[] linkTokenAddresses;
    address[] ccipBnMAddresses;
    uint64[] chainSelectors;
    uint256[] chainIds;

    function run() external {
        CCSwap ccswap;

        if (block.chainid == 421614) {} else if (block.chainid == 84532) {} else if (block.chainid == 11155111) {} else
        if (block.chainid == 11155420) {} else {
            revert("Unsupported chain");
        }

        // Ethereum, Arbitrum, Base, Optimism

        ccswapAddresses = [
            0x530b9AeBF59481e459Cf6a0c7269042843a6FCb2,
            0xa67D4C6E8ffF498a57F400A95701ED7Ee0c161A9,
            0x1Ef00bE0a03f862f980Ac8789A37031c69fB2417,
            0xfeCaAc337c404D39944C64B6A174bDadD1269F63
        ];

        uniswapRouterAddresses = [
            0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E,
            0x101F443B4d1b059569D643917553c771E1b9663E,
            0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4,
            0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4
        ];

        linkTokenAddresses = [
            0x779877A7B0D9E8603169DdbD7836e478b4624789,
            0xb1D4538B4571d411F07960EF2838Ce337FE1E80E,
            0xE4aB69C077896252FAFBD49EFD26B5D171A32410,
            0xE4aB69C077896252FAFBD49EFD26B5D171A32410
        ];

        ccipBnMAddresses = [
            0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05,
            0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D,
            0x88A2d74F47a237a62e7A51cdDa67270CE381555e,
            0x8aF4204e30565DF93352fE8E1De78925F6664dA7
        ];

        chainIds = [
            11155111, // Ethereum Sepolia
            421614, // Arbitrum Sepolia
            84532, // Base Sepolia
            11155420 // Optimism Sepolia
        ];

        chainSelectors = [
            16015286601757825753, // Ethereum Sepolia
            3478487238524512106, // Arbitrum Sepolia
            10344971235874465080, // Base Sepolia
            5224473277236331295 // Optimism Sepolia
        ];

        require(
            ccswapAddresses.length == uniswapRouterAddresses.length
                && ccswapAddresses.length == linkTokenAddresses.length && ccswapAddresses.length == ccipBnMAddresses.length
                && ccswapAddresses.length == chainIds.length && ccswapAddresses.length == chainSelectors.length,
            "Arrays length mismatch"
        );

        ccswap = CCSwap(0xfeCaAc337c404D39944C64B6A174bDadD1269F63);

        vm.startBroadcast();

        for (uint256 i = 0; i < ccswapAddresses.length; i++) {
            ccswap.setChainConfig(
                chainIds[i], ccswapAddresses[i], uniswapRouterAddresses[i], linkTokenAddresses[i], ccipBnMAddresses[i]
            );
            ccswap.setChainIdByChainSelector(chainSelectors[i], chainIds[i]);
        }

        vm.stopBroadcast();
    }
}
