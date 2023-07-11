// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./MyDexToken.sol";
import "./SafeMath.sol";

contract MyDexTokenAllot is Ownable{
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    struct PoolInfo {
        address lpToken;
        uint allocPoint;
        uint lastRewardBlock; // 上一次计算收益的区块
        uint accShareAmount; // 单位lp累计收益
    }

    struct UserInfo {
        address userAddress;
        uint lpAmount;
        uint debtAmount; // 记录用户质押lp时的accShareAmount当作债务, 用户领取收益时要扣减债务
    }

    PoolInfo[] public poolInfos;
    // poolInfo index => userAddress => userInfo
    mapping(uint => mapping (address => UserInfo)) public UserInfoMap;
    MyDexToken public myDexToken;
    uint public totalAllocPoint;
    uint public startBlock;
    uint public mdtCount; // 每个区块产生的mdt数量

    constructor(address _myDexToken, uint _mdtCount) {
        myDexToken = MyDexToken(_myDexToken);
        mdtCount = _mdtCount;
    }

    event Add(address indexed acount, address indexed lpToken, uint allocPoint);
    event Deposit(address indexed acount, address indexed lpToken, uint amount);
    event Withdraw(address indexed acount, address indexed lpToken, uint amount);
    

    // 添加一个新的lpToken到池子里
    function add(address _lpToken, uint _allocPoint, bool _isUpdate) public onlyOwner {
        if (_isUpdate) {
            updatePoolInfos();
        }

        uint lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfos.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accShareAmount: 0
            })
        );
        emit Add(msg.sender, _lpToken, _allocPoint);
    }

    function updatePoolInfos() internal {
        uint length = poolInfos.length;
        for (uint i; i < length; i++) {
            updatePoolInfo(i);
        } 
    }

    function updatePoolInfo(uint _pid) internal {
        PoolInfo storage pool = poolInfos[_pid];
        // 是否已经更新过了
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        // 查看合约的当前lpToken余额
        uint lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint multipiler = getMultiplier(pool.lastRewardBlock, block.number);
        if (totalAllocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        // 计算奖励
        uint mdtReward = multipiler.mul(mdtCount).mul(pool.allocPoint).div(totalAllocPoint);
        // 给当前合约mint
        myDexToken.mint(address(this), mdtReward);
        // 计算acc
        pool.accShareAmount = pool.accShareAmount.add(mdtReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // 存入lpToken
    function deposit(uint _pid, uint _amount) public {
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = UserInfoMap[_pid][msg.sender];
        // 更新奖励
        updatePoolInfo(_pid);
        if (user.lpAmount >= 0) {
            // 待领取奖励
            uint pendingAmount = user.lpAmount.mul(pool.accShareAmount).div(1e12).sub(user.debtAmount);
            // 把用户上次的待领取奖励发给用户
            safeTransferMdt(msg.sender, pendingAmount);
        }
        // 将用户的lpToken转到当前合约
        IERC20(pool.lpToken).safeTransferFrom(msg.sender, address(this), _amount);
        // 更新
        user.lpAmount = user.lpAmount.add(_amount);
        user.debtAmount = user.lpAmount.mul(pool.accShareAmount).div(1e12);
        emit Deposit(msg.sender, pool.lpToken, _amount);
    }
    
    // 取出lp
    function withdraw(uint _pid, uint _amount) public {
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = UserInfoMap[_pid][msg.sender];
        require(user.lpAmount >= _amount, "withdraw, not good");
        // 更新奖励
        updatePoolInfo(_pid);
        // 待领取奖励
        uint pendingAmount = user.lpAmount.mul(pool.accShareAmount).div(1e12).sub(user.debtAmount);
        // 把用户上次的待领取奖励发给用户
        safeTransferMdt(msg.sender, pendingAmount);
        // 更新
        user.lpAmount = user.lpAmount.sub(_amount);
        user.debtAmount = user.lpAmount.mul(pool.accShareAmount).div(1e12);
        // 将lp从当前合约转给用户
        IERC20(pool.lpToken).safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, pool.lpToken, _amount);
    }

    // 查看用户待领取奖励
    function pendingMdt(address _account, uint _pid) public view returns(uint pendingAmount){
        PoolInfo storage pool = poolInfos[_pid];
        UserInfo storage user = UserInfoMap[_pid][_account];
        uint acc = pool.accShareAmount;
        uint lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
        if (lpSupply > 0 && block.number > pool.lastRewardBlock) {
            // 更新
            uint multipiler = getMultiplier(pool.lastRewardBlock, block.number);
            uint mdtReward = multipiler.mul(mdtCount).mul(pool.allocPoint).div(totalAllocPoint);
            acc = acc.add(mdtReward.mul(1e12).div(lpSupply));
        }
        pendingAmount = user.lpAmount.mul(acc).div(1e12).sub(user.debtAmount);
    }

    function getMultiplier(uint _start, uint _end) private pure returns(uint multipiler) {
        return _end.sub(_start);
    }

    function safeTransferMdt(address _to, uint _amount) private {
        IERC20(myDexToken).safeTransfer(_to, _amount);
    }
}