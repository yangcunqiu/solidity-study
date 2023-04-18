// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 实现存取erc20
/// @title erc20 ZML token
contract Vault {
    // ZML address
    address immutable token;
    // 记录每个用户token余额
    mapping(address => uint256) public tokenMap;

    constructor(address _token) {
        token = _token;
    }

    // 向合约中存入erc20 (用户需要先调用erc20合约approve函数对该合约进行授权, 数量不能小于存入数量)
    function deposite(uint256 _value) public returns(bool) {
        // 先调用erc20进行转账 (把_value数量的token从用户地址转到该合约地址)
        bool success = IERC20(token).transferFrom(msg.sender, address(this), _value);
        require(success, "transferFrom fail!");
        // 增加存款
        tokenMap[msg.sender] += _value;
        return true;
    }

    // 取款, 支持用户取出自己的erc20
    function withdraw(uint256 _value) public returns(bool) {
        // 判断余额
        require(tokenMap[msg.sender] >= _value, "not sufficient funds");
        // 减少存款
        tokenMap[msg.sender] -= _value;
        // 调用erc20给用户转账 (把_value数量的token从该合约地址转到用户地址)
        bool success = IERC20(token).transfer(msg.sender, _value);
        require(success, "transfer fail");
        return true;
    }

}