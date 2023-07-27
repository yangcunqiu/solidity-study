// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MTSBridge {

    address immutable public owner;

    mapping(address => uint) public mtsAmountMap;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender != owner, "not owner");
        _;
    }

    event LockMts(address indexed account, uint amount);
    event UnlockMts(address indexed account, uint amount);

    function lockMts() public payable {
        mtsAmountMap[msg.sender] += msg.value;
        emit LockMts(msg.sender, msg.value);
    }

    function unlockMts(address payable _to, uint _amount) public onlyOwner {
        // TODO 校验签名
        safeTransferMTS(_to, _amount);
        emit UnlockMts(msg.sender, _amount);
    }

    function subMts(address account, uint amount) public onlyOwner {
        mtsAmountMap[account] -= amount;
    }

    function safeTransferMTS(address _to, uint value) internal {
        (bool success, ) = _to.call{value: value}(new bytes(0));
        require(success, 'HardhatBridge: safeTransferMTS: MTS transfer failed');
    }

}