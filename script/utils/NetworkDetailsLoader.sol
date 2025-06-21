// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "forge-std/StdJson.sol";
import "./JsonTry.sol";

abstract contract NetworkDetailsLoader is Script {
    using stdJson for string;

    struct NetworkDetails {
        string name;
        uint64 chainSelector;
        address router;
        address linkToken;
        address ccipBnM;
    }

    JsonTry private jsonTry = new JsonTry();

    function load(string memory key) internal returns (NetworkDetails memory) {
        string memory path = string.concat(vm.projectRoot(), "/utils/ccipAddresses.json");
        string memory json = vm.readFile(path);

        string memory prefix = string.concat(".", key);

        return NetworkDetails({
            name: json.readString(string.concat(prefix, ".name")),
            chainSelector: uint64(json.readUint(string.concat(prefix, ".chainSelector"))),
            router: json.readAddress(string.concat(prefix, ".router")),
            linkToken: json.readAddress(string.concat(prefix, ".linkToken")),
            ccipBnM: json.readAddress(string.concat(prefix, ".ccipBnM"))
        });
    }

    function getDeployedAddress(string memory networkKey, string memory contractName) internal returns (address) {
        string memory path = string.concat(vm.projectRoot(), "/utils/ccipAddresses.json");
        string memory json = vm.readFile(path);

        string memory chainIdPath = string.concat(".", networkKey, ".chainId");
        uint256 chainId = json.readUint(chainIdPath);

        string memory broadcastPath =
            string.concat(vm.projectRoot(), "/broadcast/DeployScript.s.sol/", vm.toString(chainId), "/run-latest.json");

        string memory runJson = vm.readFile(broadcastPath);

        for (uint256 i = 0;; i++) {
            string memory txPath = string.concat(".transactions[", vm.toString(i), "]");
            string memory namePath = string.concat(txPath, ".contractName");

            try jsonTry.tryReadString(runJson, namePath) returns (string memory foundName) {
                if (keccak256(bytes(foundName)) == keccak256(bytes(contractName))) {
                    return runJson.readAddress(string.concat(txPath, ".contractAddress"));
                }
            } catch {
                break; // no more transactions
            }
        }

        revert("Contract not found in any transaction");
    }
}
