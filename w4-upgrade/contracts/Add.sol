// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Multicall.sol";

contract Add is Multicall{

    uint256 public num;

    function increment() public {
        num++;
    }

}