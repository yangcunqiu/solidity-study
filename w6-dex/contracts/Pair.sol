// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "hardhat/console.sol";

contract Pair is ERC20, ReentrancyGuard {
    address public immutable token0;
    address public immutable token1;

    uint public reserves0;
    uint public reserves1;
    uint public constant MINIMUM_LIQUIDITY = 10**3; // 最小流动性

    // 铸造lpToken时触发
    event Mint(address, uint);
    // swap的时候触发
    event Swap(address account, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address to);
    // 销毁时触发
    event Burn(address account, address to, uint liquidity, uint amount0, uint amount1);

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
            _mint(address(this), MINIMUM_LIQUIDITY);
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

    function swap(uint amount0Out, uint amount1Out, address to) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
        (uint _reserve0, uint _reserve1) = getReserves();
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "INSUFFICIENT_LIQUIDITY");

        {
            address _token0 = token0;
            address _token1 = token1;
            require(_token0 != to && _token1 != to, "INVALID_TO");
            // 乐观转账
            if (amount0Out > 0) {
                TransferHelper.safeTransfer(_token0, to, amount0Out);
            }
            if (amount1Out > 0) {
                TransferHelper.safeTransfer(_token1, to, amount1Out);
            }
        }

        // 校验转入金额
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        // 计算token0转入的金额
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        // 校验K
        uint balance0Adjusted = balance0 * 1000 - amount0In * 3;
        uint balance1Adjusted = balance1 * 1000 - amount1In * 3;
        require(balance0Adjusted * balance1Adjusted >= uint(_reserve0 * _reserve1 * (1000 ** 2)), "K'");

        // 更新储量
        _update(balance0, balance1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function burn(address to) external returns(uint amount0, uint amount1) {
        // 查看当前pair余额
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        // 因为之前已经把调用者的lpToken转移到pair地址了, 所以这里liquidity=调用者发送的lpToken数量
        uint liquidity = balanceOf(address(this));

        // 计算lpToken能兑换出多少数量的token
        // 每次swap扣了一部分后再当成输入计算能兑换出多少输出, 但是增加totalSupply的时候没扣, 所以多出来的部分就是手续费, 按比例给每个流动性提供者
        amount0 = liquidity * balance0 / totalSupply();
        amount1 = liquidity * balance1 / totalSupply();
        require(amount0 > 0 && amount1 > 0, "INSUFFICIENT_LIQUIDITY_BURNED");

        // 燃烧lpToken
        _burn(address(this), liquidity);

        // 给调用者转账
        TransferHelper.safeTransfer(token0, to, amount0);
        TransferHelper.safeTransfer(token1, to, amount1);

        // 查看pair最新余额
        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        // 更新储量
        _update(balance0, balance1);
        emit Burn(msg.sender, to, liquidity, amount0, amount1);
    }
}