// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Pair is ERC20, ReentrancyGuard {
    address public immutable token0;
    address public immutable token1;

    uint public reserves0;
    uint public reserves1;
    uint public constant MINIMUM_LIQUIDITY = 10**3; // 最小流动性

    // 铸造lpToken时触发
    event Mint(address, uint);

    constructor(address _token0, address _token1) ERC20("lpToken", "LP") {
        token0 = _token0;
        token1 = _token1;
    }

    // 获取token储量
    function getReserves() public view returns(uint, uint) {
        return(reserves0, reserves1);
    }

    // 更新token储量
    function _update(uint balance0, uint balance1) private {
        reserves0 = balance0;
        reserves1 = balance1;
    }

    // 为to地址铸造lpToken
    function mint(address to) external nonReentrant returns(uint liquidity) {
        // 计算调用者给pair合约转了多少钱
        (uint _reserves0, uint _reserves1) = getReserves();
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - reserves0;
        uint amount1 = balance1 - reserves1;

        // 计算lpToken
        if (totalSupply() == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            // 第一次铸造要锁定最小流动性
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min(amount0 * totalSupply() / _reserves0, amount1 * totalSupply() / _reserves1);
        }
        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");
        // 铸造lpToken
        _mint(to, liquidity);

        // 更新token储量
        _update(balance0, balance1);
        emit Mint(to, liquidity);
    }
}