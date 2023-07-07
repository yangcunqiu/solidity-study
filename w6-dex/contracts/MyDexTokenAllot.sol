// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

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

    PoolInfo[] public poolInfoList;
    // poolInfo index => userAddress => userInfo
    mapping(uint => mapping (address => UserInfo)) public UserInfoMap; 
    uint public totalAllocPoint;
    uint public startBlock;
    uint public mdtCount; // 每个区块产生的mdt数量

    // 添加一个新的lpToken到池子里
    function add(address _lpToken, uint _allocPoint, bool _isUpdate) public onlyOwner {
        if (_isUpdate) {
            updatePoolInfo();
        }

        uint lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfoList.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accShareAmount: 0
            });
        );
    }

    function updatePoolInfo() internal {

    }
    
}