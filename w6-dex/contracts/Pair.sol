// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Pair {
    address public immutable token0;
    address public immutable token1;

    uint public reserves0;
    uint public reserces1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }


}