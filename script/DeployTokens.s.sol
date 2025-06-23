// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script, console2 as console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Token} from "src/utils/Token.sol";

contract DeployTokens is Script {
    /*//////////////////////////////////////////////////////////////
                                  VARIABLES
    //////////////////////////////////////////////////////////////*/

    string[] private tokenNames;
    string[] private tokenSymbols;
    string[] private chainSymbols;
    string[] private chainRPCs;

    /**
     * LOGO LIST:
     * https://cryptologos.cc/hedera
     * https://cryptologos.cc/aptos
     * https://cryptologos.cc/near-protocol
     * https://cryptologos.cc/uniswap
     * https://cryptologos.cc/polkadot-new
     * https://cryptologos.cc/sui
     * https://cryptologos.cc/usd-coin
     * https://cryptologos.cc/aave
     * https://cryptologos.cc/sei
     * https://cryptologos.cc/the-graph
     *
     */
    function run() external {
        // token names and symbols
        tokenNames = ["Hedera", "Aptos", "Near", "Uniswap", "Polkadot", "Sui", "USD Coin", "Aave", "Sei", "The Graph"];
        tokenSymbols = ["HBAR", "APT", "NEAR", "UNI", "DOT", "SUI", "USDC", "AAVE", "SEI", "GRT"];

        // token extensions for each network
        chainSymbols = ["ETH", "BASE", "ARB", "OP", "AVAX"];

        string memory chainSymbol = "OP";

        // // RPC URLs for each network
        // chainRPCs = ["ethereumSepolia", "baseSepolia", "arbitrumSepolia", "optimismGoerli", "avalancheFuji"];

        // string[] memory forkChainRPCs = new string[](2);
        // forkChainRPCs[0] = "http://127.0.0.1:8545";
        // forkChainRPCs[1] = "http://127.0.0.1:8546";

        // // loop through chainRPCs array
        // for (uint256 i = 0; i < chainRPCs.length; i++) {
        //     if (i > 1) {
        //         break;
        //     }

        // loop through token names
        for (uint256 j = 0; j < tokenNames.length; j++) {
            // break after single token deployment on each chain
            if (j > 11) {
                break;
            }

            string memory tokenName = string.concat(chainSymbol, " ", tokenNames[j]);
            string memory tokenSymbol = string.concat(chainSymbol, "-", tokenSymbols[j]);

            Token token;
            // create a select fork for the chain using the RPC URL
            // vm.createSelectFork(vm.rpcUrl(chainRPCs[i]));

            // deploy each token
            vm.startBroadcast();

            token = new Token(tokenName, tokenSymbol);
            vm.stopBroadcast();

            // log the deployed token address
            string memory message = string.concat(
                "Deployed [", chainSymbol, " ", tokenNames[j], "] at: ", Strings.toHexString(address(token))
            );
            console.log(message);
        }
        // }
    }
}
