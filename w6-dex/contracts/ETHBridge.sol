// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WMTS is ERC20("Wrapper MTS", "WMTS") {
    address immutable public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}

contract ETHBridge {

    address immutable public owner;
    WMTS immutable public mts;

    mapping(address => uint) public mtsAmountMap;

    constructor (address _owner, address _mts) {
        owner = _owner;
        mts = WMTS(_mts);
    }

    modifier onlyOwner() {
        require(msg.sender != owner, "not owner");
        _;
    }

    event LockMts(address indexed account, uint amount);
    event UnlockMts(address indexed account, uint amount);

    function lockMts(uint _amount) public {
        safeTransferToken(address(mts), msg.sender, address(this), _amount);
        mtsAmountMap[msg.sender] += _amount;
        emit LockMts(msg.sender, _amount);
    }

    function unlockMts(address _to, uint _amount) public onlyOwner {
        // TODO 校验签名
        mts.mint(_to, _amount);
        emit UnlockMts(_to, _amount);
    }

    function subMts(address account, uint amount) public onlyOwner {
        mtsAmountMap[account] -= amount;
    }

    function safeTransferToken(address _token, address _from, address _to, uint _amount) internal {
        bool success = IERC20(_token).transferFrom(_from, _to, _amount);
        require(success, "ETHBridge: safeTransferToken: token transfer failed");
    }
}