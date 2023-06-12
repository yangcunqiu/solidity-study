// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pair.sol";
import "hardhat/console.sol";

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

    // 给定一个token的输入, 计算兑换路径内所有token可兑换出的数量
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns(uint[] memory amounts) {
        require(path.length > 2, "INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length -1; i++) {
            // 获取储量 [A,B,C] => 1. [A,B] 2. [B,C]
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i+1]);
            // 为每一对计算兑换数量
            console.log("getAmountsOut, %s[%d] -> %s", amounts[i], path[i], path[i+1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }

    }

    // 给定一个token输入和两个token的储量, 计算可兑换出另一个token的数量
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal view returns(uint amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * 997; // 这里相当于收取了手续费, 直接把输入扣掉了一部分再参与后面计算
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
        console.log("getAmountOut, uniswapV2: ", amountOut);

        // 一步算出结果
        uint amountOut1 = (997 * amountIn * reserveOut) / (1000 * reserveIn + 997 * amountIn);
        console.log("getAmountOut, oneCal: ", amountOut1);

        // 使用x*y=k, 不收取手续费算一遍
        uint xkAmount = (amountIn * reserveOut) / (reserveIn + amountIn);
        console.log("getAmountOut, nonFee: ", xkAmount);
    }


}