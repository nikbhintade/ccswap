// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/StdJson.sol";

contract JsonTry {
    using stdJson for string;

    function tryReadString(string memory json, string memory path) external returns (string memory) {
        return json.readString(path);
    }
}
