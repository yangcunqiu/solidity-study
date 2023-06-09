// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IPairFactory.sol";

contract MyDex {

    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    // 添加流动性
    function addLiquidity(address _tokenA, address _tokenB, uint _amountADesired, uint _amountBDesired, uint _amountAMin, uint _amountBMin) public returns(uint) {
        if (IPairFactory(factory).pairMap(_tokenA, _tokenB) == address(0)) {
            // 需要创建pair
            IPairFactory(factory).createPair(_tokenA, _tokenB);
        }
    }

}