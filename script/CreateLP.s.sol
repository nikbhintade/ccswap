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
    address private constant BASE_CCIPBNM_ADDRESS = 0x88A2d74F47a237a62e7A51cdDa67270CE381555e;
    address private constant ARBITRUM_CCIPBNM_ADDRESS = 0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D;
    address private constant ETHEREUM_CCIPBNM_ADDRESS = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;

    address private constant BASE_APTOS_ADDRESS = 0x482D44f610200bD112E43642F365d67aB0E23450;
    address private constant ARB_SUI_ADDRESS = 0xfe0A862C3d5aD3AbFc7340312D4aB37F772A545A;
    address private constant ETH_POLKADOT_ADDRESS = 0x13F160f731274581636E6B24fc72E710FFa178B3;

    address private constant BASE_UNISWSAP_NONFUNGIBLE_POSITION_MANAGER = 0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2;

    address private constant ARBITRUM_UNISWAP_NONFUNGIBLE_POSITION_MANAGER = 0x6b2937Bde17889EDCf8fbD8dE31C3C2a70Bc4d65;

    address private constant ETHEREUM_UNISWAP_NONFUNGIBLE_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52;

    function run() external {
        address ccipBnM;
        address token0;
        address uniswapNFTPositionManager;

        if (block.chainid == 421614) {
            // Arbitrum Sepolia
            ccipBnM = ARBITRUM_CCIPBNM_ADDRESS;
            token0 = ARB_SUI_ADDRESS;
            uniswapNFTPositionManager = ARBITRUM_UNISWAP_NONFUNGIBLE_POSITION_MANAGER;
        } else if (block.chainid == 84532) {
            // Base Sepolia
            ccipBnM = BASE_CCIPBNM_ADDRESS;
            token0 = BASE_APTOS_ADDRESS;
            uniswapNFTPositionManager = BASE_UNISWSAP_NONFUNGIBLE_POSITION_MANAGER;
        } else if (block.chainid == 11155111) {
            ccipBnM = ETHEREUM_CCIPBNM_ADDRESS;
            token0 = ETH_POLKADOT_ADDRESS;
            uniswapNFTPositionManager = ETHEREUM_UNISWAP_NONFUNGIBLE_POSITION_MANAGER;
        } else if (block.chainid == 44787) {
            ccipBnM = 0x7e503dd1dAF90117A1b79953321043d9E6815C72;
            token0 = 0xaADA75c8438FBee9948Ad907B417bAC0609C94F0;
            uniswapNFTPositionManager = 0x0eC9d3C06Bc0A472A80085244d897bb604548824;
        } else {
            revert("Unsupported chain");
        }

        bool success;

        vm.broadcast();
        (success,) = ccipBnM.call(abi.encodeWithSignature("drip(address)", msg.sender));

        vm.broadcast();
        (success,) = ccipBnM.call(abi.encodeWithSignature("drip(address)", msg.sender));

        vm.broadcast();
        (success,) = ccipBnM.call(abi.encodeWithSignature("drip(address)", msg.sender));

        vm.broadcast();
        (success,) = token0.call(abi.encodeWithSignature("mint(address)", msg.sender));

        require(success, "Failed to request tokens from faucet");

        INonfungiblePositionManager positionManager = INonfungiblePositionManager(uniswapNFTPositionManager);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: ccipBnM,
            fee: 500,
            tickLower: -100,
            tickUpper: 10000,
            amount0Desired: 100 ether,
            amount1Desired: 3 ether,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 1 days
        });

        vm.startBroadcast();

        positionManager.createAndInitializePoolIfNecessary(token0, ccipBnM, 500, TickMath.getSqrtRatioAtTick(10));

        TransferHelper.safeApprove(token0, uniswapNFTPositionManager, type(uint256).max);

        TransferHelper.safeApprove(ccipBnM, uniswapNFTPositionManager, type(uint256).max);

        (uint256 tokenId,,,) = positionManager.mint(params);

        vm.stopBroadcast();

        console.log("LP Token ID:", tokenId);

        // uint256 balance = IERC20(token0).balanceOf(tokenId);
    }
}
