// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script, console2 as console} from "forge-std/Script.sol";
import {CCSwap} from "src/CCSwap.sol";
import {Token} from "src/utils/Token.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainSwap is Script {
    function run() external {
        uint64 chainSelectorBase = 10344971235874465080;
        CCSwap ccswapBase = CCSwap(0xBCA71800A771FcB71F158906B1e70e1c197505c3);
        address uniswapRouterBase = 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4;
        address linkTokenBase = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;
        address ccipBnMBase = 0x88A2d74F47a237a62e7A51cdDa67270CE381555e;

        uint64 chainSelectorEth = 16015286601757825753;
        CCSwap ccswapEth = CCSwap(0x09D088e920699bCb977c7177b1498429cC1b4d41);
        address uniswapRouterEth = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;
        address linkTokenEth = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
        address ccipBnMEth = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;


        vm.startBroadcast();

        // chain config setup
        ccswapEth.setChainConfig(84532, address(ccswapBase), uniswapRouterBase, linkTokenBase, ccipBnMBase);
        ccswapEth.setChainConfig(11155111, address(ccswapEth), uniswapRouterEth, linkTokenEth, ccipBnMEth);

        ccswapEth.setChainIdByChainSelector(chainSelectorBase, 84532);
        ccswapEth.setChainIdByChainSelector(chainSelectorEth, 11155111);

        vm.stopBroadcast();

        delete ccipBnMBase;
        delete ccipBnMEth;
        delete uniswapRouterBase;
        delete uniswapRouterEth;
        delete linkTokenBase;
        // delete linkTokenEth;
        delete ccswapBase;
        // delete ccswapEth;

        uint256 balance = IERC20(linkTokenEth).balanceOf(address(ccswapEth));

        if (balance < 0.05 ether) {
            vm.broadcast();
            IERC20(linkTokenEth).transfer(address(ccswapEth), 0.05 ether - balance);
        }

        vm.startBroadcast();
        Token(0x13F160f731274581636E6B24fc72E710FFa178B3).approve(address(ccswapEth), UINT256_MAX);

        ccswapEth.swap(
            chainSelectorBase,
            0.01 ether,
            0x13F160f731274581636E6B24fc72E710FFa178B3, // ETH Polkadot address
            0x482D44f610200bD112E43642F365d67aB0E23450, // Base Aptos address
            1_000_000
        );

        vm.stopBroadcast();

        // Optionally, you can verify the contract on Etherscan or any other block explorer
    }
}
