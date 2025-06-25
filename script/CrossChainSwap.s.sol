// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script, console2 as console} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";
import {Token} from "src/utils/Token.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainSwap is Script {
    function run() external {
        address linkToken;
        CCSwap ccswap;

        uint64 chainSelector = 3478487238524512106;
        address token0 = 0x369841a81df5174891e7C3663E6D228d65B4Fea6;
        address token1 = 0x85Dd42Ea8276AA21544f3f634ef84CcF5161fFCe;

        if (block.chainid == 11155111) {
            ccswap = CCSwap(0x530b9AeBF59481e459Cf6a0c7269042843a6FCb2);
            linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // Ethereum Sepolia
        } else if (block.chainid == 421614) {
            ccswap = CCSwap(0xa67D4C6E8ffF498a57F400A95701ED7Ee0c161A9);
            linkToken = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E; // Arbitrum Sepolia
        } else if (block.chainid == 84532) {
            ccswap = CCSwap(0x1Ef00bE0a03f862f980Ac8789A37031c69fB2417);
            linkToken = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410; // Base Sepolia
        } else if (block.chainid == 11155420) {
            ccswap = CCSwap(0xfeCaAc337c404D39944C64B6A174bDadD1269F63);
            linkToken = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410; // Optimism Sepolia
        } else {
            revert("Unsupported chain");
        }

        uint256 balance = IERC20(linkToken).balanceOf(address(ccswap));

        if (balance < 1 ether) {
            vm.broadcast();
            IERC20(linkToken).transfer(address(ccswap), 1 ether - balance);
        }

        balance = Token(token0).balanceOf(msg.sender);

        if (balance < 1 ether) {
            vm.broadcast();
            Token(token0).mint(msg.sender);
        }

        vm.startBroadcast();
        Token(token0).approve(address(ccswap), UINT256_MAX);

        ccswap.swap(chainSelector, 0.1 ether, token0, token1, 400_000);

        vm.stopBroadcast();
    }
}
