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
        (address token0, address token1) = PairLibrary.sortToken(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            keccak256(abi.encodePacked(
                type(Pair).creationCode,
                abi.encode(token0, token1)
            ))
        )))));
    }

    // 获取token储量
    function getTokenReserves(address factory, address tokenA, address tokenB) internal view returns(uint reservesA, uint reservesB) {
        address pair = getPair(factory, tokenA, tokenB);
        console.log("pair: %s", pair);
        (uint reserves0, uint reserves1) = Pair(pair).getReserves();
        console.log("reserves0: %s, reserves1: %s", reserves0, reserves1);
        // 排序
        (address token0, ) = sortToken(tokenA, tokenB);
        console.log("tokenA: %s, tokenB: %s, token0: %s", tokenA, tokenB, token0);
        (reservesA, reservesB) = tokenA == token0 ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    // 报价, 返回当前token能兑换出多少数量的另一种token
    function quote(uint amount0, uint reserves0, uint reserves1) internal pure returns(uint) {
        require(amount0 > 0, "INSUFFICIENT_AMOUNT");
        require(reserves0 > 0 && reserves1 > 0, "INSUFFICIENT_LIQUIDITY");
        return amount0 * reserves1 / reserves0;
    }

    // 给定一个token的输入, 计算兑换路径内所有token的所需数量
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns(uint[] memory amounts) {
        require(path.length >= 2, "INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length -1; i++) {
            // 获取储量 [A,B,C] => 1. [A,B] 2. [B,C]
            (uint reserveIn, uint reserveOut) = getTokenReserves(factory, path[i], path[i+1]);
            // 为每一对计算兑换数量
            console.log("getAmountsOut, [%s]%s -> [%s]", path[i], amounts[i], path[i+1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
            console.log("getAmountsOut, [%s] -> [%s]%s", path[i], path[i+1], amounts[i + 1]);
        }
    }

    // 给定一个token输入和两个token的储量, 计算另一个token的输出
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal view returns(uint amountOut) {
        console.log("getAmountOut start: amountIn: %s, reserveIn: %s, reserveOut: %s", amountIn, reserveIn, reserveOut);
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * 997; // 这里相当于收取了手续费, 直接把输入扣掉了一部分再参与后面计算
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
        console.log("getAmountOut, uniswapV2: ", amountOut);

        // 使用x*y=k, 不收取手续费算一遍
        uint kAmountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
        console.log("getAmountOut, nonFee: ", kAmountOut);
    }

    // 给定一个token的输出, 计算兑换路径内所有token的所需数量
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns(uint[] memory amounts) {
        require(path.length >= 2, "INVAILD_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        // 从后往前遍历
        for (uint i = path.length - 1; i > 0; i--) {
            // 获取 path[i-1] 和 path[i]的储量
            (uint reserveIn, uint reserveOut) = getTokenReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    // 给定一个token的输出和两个token的储量, 计算另一个token的输入
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal view returns(uint amountIn) {
        require(amountOut > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn * reserveOut * 1000;
        uint denominator = (reserveOut - amountOut) * 997; // 扣除手续费
        amountIn = (numerator / denominator) + 1; // 避免由于整数除法造成的向下取整问题, 确保交易成功
        console.log("getAmountIn, uniswapV2: ", amountIn);

        uint kAmountIn = (reserveIn * amountOut) / (reserveOut - amountOut);
        console.log("getAmountIn, nonFee: ", kAmountIn);
    }

}