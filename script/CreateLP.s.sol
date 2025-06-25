// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script, console2 as console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Token} from "src/utils/Token.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CreateLP is Script {
    address[] token0;

    function run() external {
        address ccipBnM;
        address uniswapNFTPositionManager;

        if (block.chainid == 421614) {
            // Arbitrum Sepolia
            ccipBnM = 0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D;
            token0 = [
                0x71893B2ECe4826fe54CAB810d78C9F501d60E149,
                0x6110497BB349F84452b92E012B4D6394B5A41AC0,
                // 0xE2a90166b8d80D57F8D6e5f875aF95308B00C68e, // usdc
                // 0xfe0A862C3d5aD3AbFc7340312D4aB37F772A545A, // sui
                0x8325708abD29A98DA3988b43737eA7E82F7395B9,
                // 0xf49Ca83BfdCE9f30BA12178D1bFA48297D94330b
                0x85Dd42Ea8276AA21544f3f634ef84CcF5161fFCe // aave
            ];
            uniswapNFTPositionManager = 0x6b2937Bde17889EDCf8fbD8dE31C3C2a70Bc4d65;
        } else if (block.chainid == 84532) { // Done deployed 3 pools on Base Sepolia
            // Base Sepolia
            ccipBnM = 0x88A2d74F47a237a62e7A51cdDa67270CE381555e;
            token0 = [
                0x777b48ef08A87933e0D0f10881Aea1f653A2d497,
                0x482D44f610200bD112E43642F365d67aB0E23450,
                0x3B9E8Aa5F6cF87038a098071b16645385FBDE21D //Aave (removed usdc)
                // 0xF6ad502da39243A1e92FD545f8867F5707ac40C9, // Sui (removed NEAR)
                // 0xc6d422e6A10AE87d3860776776f3ECe23e7494ff
            ];
            uniswapNFTPositionManager = 0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2;
        } else if (block.chainid == 11155111) {
            ccipBnM = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
            token0 = [
                0xC5AaBA5A2bf9BaFE78402728da518B8b629F3808, // Hedera
                0xf8ba235aE8CB078200B5525786f91C9b6043cfA6, // Aptos
                0x93F305FaBE1aE9f62Da2BE248554E18519d035fB, // USDC
                0x398bf9558A02c927865bd6b51999A47a0E76dE67, //NEAR
                0xAea090e3faCaB1b441a1e8BB046f1760b5f1eD12 // Uniswap
            ];
            uniswapNFTPositionManager = 0x1238536071E1c677A632429e3655c799b22cDA52;
        } else if (block.chainid == 11155420) {
            ccipBnM = 0x8aF4204e30565DF93352fE8E1De78925F6664dA7;
            token0 = [
                // 0xe4b3A31823B703809cf9db163a20BD706099C846, // hedera
                0x369841a81df5174891e7C3663E6D228d65B4Fea6,
                0x2A7EE9Cfb04343157da9C84d011036F037696Ea0,
                // 0x8DE497aB5eB1069e3B4777207d9AD45ebDE4a86d, //near
                // 0xCa43b352f6DB42e7CB1D588B7e06c9de1e87B14B, // uniswap
                // 0xAad29c847afBB3D4b6F7a22C57Ea28dE8222D577, // sui,
                0x8ad0D9ff78C7aA5458AE539f5428aD6C23fC2bC0 // aave
            ];
            uniswapNFTPositionManager = 0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2;
        } else {
            revert("Unsupported chain");
        }

        bool success;

        INonfungiblePositionManager positionManager = INonfungiblePositionManager(uniswapNFTPositionManager);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(0),
            token1: ccipBnM,
            fee: 500,
            tickLower: -100,
            tickUpper: 100,
            amount0Desired: 10 ether,
            amount1Desired: 10 ether,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 1 days
        });

        vm.startBroadcast();

        for (uint256 i = 0; i < token0.length; i++) {
            address token = token0[i];

            for (uint256 j = 0; j < 10; j++) {
                (success,) = ccipBnM.call(abi.encodeWithSignature("drip(address)", msg.sender));
            }

            (success,) = token.call(abi.encodeWithSignature("mint(address)", msg.sender));

            require(success, "Failed to request tokens from faucet");

            positionManager.createAndInitializePoolIfNecessary(token, ccipBnM, 500, TickMath.getSqrtRatioAtTick(10));

            TransferHelper.safeApprove(token, uniswapNFTPositionManager, type(uint256).max);

            TransferHelper.safeApprove(ccipBnM, uniswapNFTPositionManager, type(uint256).max);

            params.token0 = token;

            (uint256 tokenId,,,) = positionManager.mint(params);
        }

        vm.stopBroadcast();

        // uint256 balance = IERC20(token0).balanceOf(tokenId);
    }
}
