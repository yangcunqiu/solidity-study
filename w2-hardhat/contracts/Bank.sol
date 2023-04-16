// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Bank {

    mapping(address => uint256) public transferMap;

    receive() external payable {
        transferMap[msg.sender] = msg.value;
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}