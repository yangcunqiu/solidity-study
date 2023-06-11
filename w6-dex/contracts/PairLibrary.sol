// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pair.sol";

library PairLibrary {

    // token排序
    function sortToken(address tokenA, address tokenB) internal pure returns(address token0, address token1) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
    }

    // 计算pair地址
    function getPair(address factory, address tokenA, address tokenB) internal pure returns(address pair) {
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            factory,
            abi.encodePacked(tokenA, tokenB),
            keccak256(abi.encodePacked(
                type(Pair).creationCode,
                abi.encode(tokenA, tokenB)
            ))
        )))));
    }

    // 获取token储量
    function getReserves(address factory, address tokenA, address tokenB) internal view returns(uint reservesA, uint reservesB) {
        address pair = getPair(factory, tokenA, tokenB);
        (uint reserves0, uint reserves1) = Pair(pair).getReserves();
        // 排序
        (address token0, ) = sortToken(tokenA, tokenB);
        (reservesA, reservesB) = tokenA == token0 ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    // 报价, 返回当前token能兑换出多少数量的另一种token
    function quote(uint amount0, uint reserves0, uint reserves1) internal pure returns(uint) {
        require(amount0 > 0, "INSUFFICIENT_AMOUNT");
        require(reserves0 > 0 && reserves1 > 0, "INSUFFICIENT_LIQUIDITY");
        return reserves1 / reserves0 * amount0;
    }
}