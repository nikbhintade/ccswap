// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 public constant MINT_AMOUNT = 100 ether; // 100 tokens with 18 decimals

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to) external {
        _mint(to, MINT_AMOUNT);
    }
}
