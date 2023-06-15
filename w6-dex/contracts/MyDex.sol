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
    /// @param _to 接收地址
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

    /// @notice 给定一个token的输出, 给出另一个token的输入
    /// @param _amountOut 要兑换出的token的数量
    /// @param _amountInMax 接受的最大要支付的token的数量
    /// @param _path 兑换路径
    /// @param _to 接收地址
    /// @return amounts 返回兑换路径中所有token的兑换数量
    function swapTokensForExactTokens(
        uint _amountOut,
        uint _amountInMax,
        address[] memory _path,
        address _to
    ) external returns(uint[] memory amounts) {
        // 计算出所有路径的可兑换数量
        amounts = PairLibrary.getAmountsIn(address(factory), _amountOut, _path);
        require(amounts[0] <= _amountInMax, "EXCESSIVE_INPUT_AMOUNT");
        // 转_path[0], 从调用者转到_path[0], _path[1]的pair中
        TransferHelper.safeTransferFrom(_path[0], msg.sender, PairLibrary.getPair(address(factory), _path[0], _path[1]), amounts[0]);
        _swap(amounts, _path, _to);
    }


    /// @notice 移除流动性
    /// @param _tokenA tokenA地址
    /// @param _tokenB tokenB地址
    /// @param _liquidity lpToken数量
    /// @param _amountAMin tokenA最少要取出的数量
    /// @param _amountBMin tokenB最少要取出的数量
    /// @param _to 接收地址
    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint _liquidity,
        uint _amountAMin,
        uint _amountBMin,
        address _to
    ) external returns(uint amountA, uint amountB) {
        address pair = PairLibrary.getPair(address(factory), _tokenA, _tokenB);
        // 将调用者的lpToken转到pair里面
        Pair(pair).transferFrom(msg.sender, pair, _liquidity);
        // 燃烧lpToken, 兑换普通token
        (uint amount0, uint amount1) = Pair(pair).burn(_to);
        // 排序, 区分token0和token1
        (address token0,) = PairLibrary.sortToken(_tokenA, _tokenB);
        (amountA, amountB) = _tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= _amountAMin, "INSUFFICIENT_A_AMOUNT");
        require(amountB >= _amountBMin, "INSUFFICIENT_B_AMOUNT");
    }

    // 报价, 给定token数量和两个token储量, 返回等值的另一种token的数量
    function quote(uint amountA, uint reserveA, uint reserveB) public pure returns(uint amountB) {
        return PairLibrary.quote(amountA, reserveA, reserveB);
    }

    // 给定token数量和两个token储量, 返回能兑换出的另一种token的数量
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view returns(uint amountOut) {
        return PairLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    // 给定要兑换出的token数量和两个token的储量, 返回所需的另一种token的数量
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view returns(uint amountIn) {
        return PairLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    // 给定一个token的输入, 计算兑换路径内所有token的所需数量
    function getAmountsOut(uint amountIn, address[] memory path) public view returns(uint[] memory amounts) {
        return PairLibrary.getAmountsOut(address(factory), amountIn, path);
    }

    // 给定一个token的输出, 计算兑换路径内所有token的所需数量
    function getAmountsIn(uint amountOut, address[] memory path) public view returns(uint[] memory amounts) {
        return PairLibrary.getAmountsIn(address(factory), amountOut, path);
    }

}