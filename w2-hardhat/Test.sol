// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Test {

    uint256 public num;

    constructor(uint256 _initNum) {
        num = _initNum;
    }

    function add(uint256 _n) public view returns(uint256 result) {
        result = num + _n;
    }

}