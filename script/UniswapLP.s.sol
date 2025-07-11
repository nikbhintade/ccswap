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

contract UniswapLP is Script {
    /*//////////////////////////////////////////////////////////////
                                  VARIABLES
    //////////////////////////////////////////////////////////////*/

    // current addresses are for Celo Alfajores testnet
    address private constant UNISWAP_FACTORY = 0x229Fd76DA9062C1a10eb4193768E192bdEA99572;
    address private constant UNISWAP_NONFUNGIBLE_POSITION_MANAGER = 0x0eC9d3C06Bc0A472A80085244d897bb604548824;

    function run() external {
        // Start recording logs
        vm.recordLogs();

        Token tokenA = Token(0xaADA75c8438FBee9948Ad907B417bAC0609C94F0);

        address tokenB = 0x7e503dd1dAF90117A1b79953321043d9E6815C72;

        IUniswapV3Factory factory = IUniswapV3Factory(UNISWAP_FACTORY);

        // Create a pool for the two tokens with a specific fee
        uint24 fee = 500; // 0.05% fee
        address pool = factory.getPool(address(tokenA), address(tokenB), fee);

        if (pool == address(0)) {
            vm.broadcast();
            pool = factory.createPool(address(tokenA), address(tokenB), fee);
        }

        // Fetch logs
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Get the event signature hash
        bytes32 eventSig = keccak256("PoolCreated(address,address,uint24,int24,address)");

        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == eventSig) {
                // Decode indexed topics
                address token0 = address(uint160(uint256(logs[i].topics[1])));
                address token1 = address(uint160(uint256(logs[i].topics[2])));
                uint24 eventFee = uint24(uint256(logs[i].topics[3]));

                // Decode non-indexed data
                (int24 tickSpacing, address createdPool) = abi.decode(logs[i].data, (int24, address));

                // Log everything
                console.log("PoolCreated:");
                console.log("  token0:", token0);
                console.log("  token1:", token1);
                console.log("  fee:", eventFee);
                console.log("  tickSpacing:", tickSpacing);
                console.log("  pool address:", createdPool);

                vm.broadcast();
                IUniswapV3Pool(pool).initialize(TickMath.getSqrtRatioAtTick(tickSpacing));
                break;
            }
        }

        vm.startBroadcast();

        uint256 amountToMint = 2 ether;
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(UNISWAP_NONFUNGIBLE_POSITION_MANAGER);
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(tokenA),
            token1: address(tokenB),
            fee: fee,
            tickLower: -100,
            tickUpper: 100,
            amount0Desired: amountToMint,
            amount1Desired: amountToMint,
            amount0Min: 0,
            amount1Min: 0,
            recipient: msg.sender,
            deadline: block.timestamp + 1 hours
        });

        tokenA.mint(msg.sender);

        (bool success,) = tokenB.call(abi.encodeWithSignature("drip(address)", msg.sender));
        (success,) = tokenB.call(abi.encodeWithSignature("drip(address)", msg.sender));
        (success,) = tokenB.call(abi.encodeWithSignature("drip(address)", msg.sender));

        TransferHelper.safeApprove(address(tokenA), address(positionManager), UINT256_MAX);
        TransferHelper.safeApprove(address(tokenB), address(positionManager), UINT256_MAX);

        (uint256 tokenId,,,) = positionManager.mint(params);

        vm.stopBroadcast();

        console.log("Minted LP token with ID:", tokenId);
    }
}
