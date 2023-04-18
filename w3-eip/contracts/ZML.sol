// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 发行自己的erc20合约
contract ZML is ERC20 {
    constructor(uint256 initialSupply) ERC20("testerc20", "ZML") {
        _mint(msg.sender, initialSupply * 10 ** 18);
    }
}