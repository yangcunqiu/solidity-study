// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IUniswapV2Router02.sol";
import "hardhat/console.sol";

contract TokenMarket {

    address immutable token;
    address immutable WETH;
    address immutable uniswapV2Route02;

    constructor (address _token, address _WETH, address _uniswapV2Route02) {
        token = _token;
        WETH = _WETH;
        uniswapV2Route02 = _uniswapV2Route02;
    }

    function addLiquidity(uint amountADesired, uint amountBDesired) public returns(uint amountA, uint amountB, uint liquidity){
        (amountA, amountB, liquidity) = IUniswapV2Router02(uniswapV2Route02).addLiquidity(
            token,
            WETH,
            amountADesired,
            amountBDesired,
            amountADesired,
            amountBDesired,
            msg.sender,
            block.timestamp + 500
        );
    }

    function buyToken(uint _slipPoint) public payable returns(uint amountOut) {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = token;

        uint[] memory amounts = IUniswapV2Router02(uniswapV2Route02).getAmountsOut(
            msg.value,
            path
        );
        console.log("1 uniswapV2 return amounts : ", amounts[0], amounts[1]);

        amountOut = amounts[1];
        uint amountOutMin = amountOut * (1 - _slipPoint); 

        amounts = IUniswapV2Router02(uniswapV2Route02).swapExactTokensForTokens(
            msg.value,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 500
        );
        console.log("2 uniswapV2 return amounts : ", amounts[0], amounts[1]);

        amountOut = amounts[1];
    }

}