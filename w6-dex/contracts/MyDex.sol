// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pair.sol";
import "./PairFactory.sol";
import "./PairLibrary.sol";
import "hardhat/console.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract MyDex {

    PairFactory public immutable factory;

    // 添加流动性时触发
    event AddLiquidity(address, address, address, uint, uint);

    constructor(address _factory) {
        factory = PairFactory(_factory);
    }

    // 计算能添加多少流动性
    function _calLiquidity(
        address _tokenA, 
        address _tokenB, 
        uint _amountADesired, 
        uint _amountBDesired, 
        uint _amountAMin, 
        uint _amountBMin
    ) private returns(uint amountA, uint amountB) {
        // 获取pair地址
        if (factory.pairMap(_tokenA, _tokenB) == address(0)) {
            // 需要创建pair
            factory.createPair(_tokenA, _tokenB);
        }
        // 获取token储量
        (uint reserveA, uint reserveB) = PairLibrary.getReserves(address(factory), _tokenA, _tokenB);
        if (reserveA == 0 && reserveB == 0) {
            // pair第一次添加流动性
            (amountA, amountB) = (_amountADesired, _amountBDesired);
        } else {
            // 需要计算token最终能添加多少
            // 计算如果用期望数量的tokenA来添加需要多少数量的tokenB
            uint amountBOptimal = PairLibrary.quote(_amountADesired, reserveA, reserveB);
            console.log("amountBOptimal: ", amountBOptimal);
            if (amountBOptimal <= _amountBDesired) {
                // 如果计算出实际的tokenB数量小于要期望的, 那么说明tokenB相当于tokenA来说涨了
                require(amountBOptimal >= _amountBMin, "INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (_amountADesired, amountBOptimal);
            } else {
                // 说明tokenB相当于tokenA来说跌了
                // 计算如果用期望数量的tokenB来添加需要多少数量的tokenA
                uint amountAOptimal = PairLibrary.quote(_amountBDesired, reserveB, reserveA);
                console.log("amountAOptimal: ", amountAOptimal);
                require(amountAOptimal >= _amountAMin, "INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, _amountBDesired);
            }
        }
    }

    /// @notice 添加流动性
    /// @param _tokenA tokenA地址
    /// @param _tokenB _tokenB地址
    /// @param _amountADesired tokenA期望能够添加的数量
    /// @param _amountBDesired tokenB期望能够添加的数量 
    /// @param _amountAMin tokenA最少要添加的数量
    /// @param _amountBMin tokenB最少要添加的数量
    /// @return amountA tokenA实际添加的数量
    /// @return amountB tokenB实际添加的数量
    /// @return liquidity 能够获得的lpToken数量
    function addLiquidity(
        address _tokenA, 
        address _tokenB, 
        uint _amountADesired, 
        uint _amountBDesired, 
        uint _amountAMin, 
        uint _amountBMin
    ) public returns(uint amountA, uint amountB, uint liquidity) {
        console.log("addLiquidity");
        // 计算能添加多少流动性
        (amountA, amountB) = _calLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin);

        // 获取到pair地址
        address pair = PairLibrary.getPair(address(factory), _tokenA, _tokenB);
        // 转账 将调用者amount数量的token转到pair合约中
        TransferHelper.safeTransferFrom(_tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(_tokenB, msg.sender, pair, amountB);
        // 给调用者铸造lpToken
        liquidity = Pair(pair).mint(msg.sender);
        emit AddLiquidity(msg.sender, _tokenA, _tokenB, amountA, amountB);
    }

    // swap
    function _swap(uint[] memory _amounts, address[] memory _path, address _to) private {
        for (uint i; i < _path.length - 1; i++) {
            (address input, address output) = (_path[i], _path[i + 1]);
            (address token0,) = PairLibrary.sortToken(input, output);
            uint amountOut = _amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < _path.length - 2 ? PairLibrary.getPair(address(factory), output, _path[i + 2]) : _to;
            Pair(PairLibrary.getPair(address(factory), input, output)).swap(amount0Out, amount1Out, to);
        }
    }

    /// @notice 给定一个token的输入, 兑换出另一个token
    /// @param _amountIn 支付的token数量
    /// @param _amountOutMin 能接受的最小的兑换出的token数量 (这里其实就是设置的滑点)
    /// @param _path 兑换路径 假如没有A和C的pair, 可以使用[A,B,C]通过B-token中转用A兑换出C
    /// @return amounts 返回兑换路径中所有token的兑换数量
    function swapEactTokenForTokens(
        uint _amountIn,
        uint _amountOutMin,
        address[] memory _path,
        address _to
    ) external returns(uint[] memory amounts) {
        console.log("swapEactTokenForTokens, amountIn", _amountIn);
        for (uint i; i < _path.length - 1; i++) {
            console.log("swapEactTokenForTokens, path: %s ", _path[i]);
        }
        
        // 计算出所有路径的可兑换数量
        amounts = PairLibrary.getAmountsOut(address(factory), _amountIn, _path);
        // 校验必须达到amountOutMin数量, amounts的最后一个就是要最终兑换出的token
        require(amounts[amounts.length - 1] >= _amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");
        // 将path[0]的token从调用者转到pair合约, 转amounts[0]的数量, path[0]和amounts[0]就是调用者想用来兑换的token和数量
        TransferHelper.safeTransferFrom(_path[0], msg.sender, PairLibrary.getPair(address(factory), _path[0], _path[1]), amounts[0]);
        // 开始swap
        _swap(amounts, _path, _to);
    }


}