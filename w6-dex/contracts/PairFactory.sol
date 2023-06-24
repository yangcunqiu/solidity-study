// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pair.sol";

contract PairFactory {
    mapping(address => mapping(address => address)) public pairMap;
    address[] public pairList;

    // 创建pair
    function createPair(address _tokenA, address _tokenB) external returns(address) {
        // 校验token地址
        require(_tokenA != _tokenB, "IDENTICAL_ADDRESS");
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        require(token0 != address(0), "ZERO_ADDRESS");
        require(pairMap[token0][token1] == address(0), "PAIR_EXISTS");
        // 创建pair
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        Pair pair = new Pair{salt: salt}(token0, token1);
        // 保存pair
        pairMap[token0][token1] = address(pair);
        pairMap[token1][token0] = address(pair);
        pairList.push(address(pair));
        return address(pair);
    }


}