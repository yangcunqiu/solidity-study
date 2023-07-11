// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyDexToken is ERC20, Ownable {
    constructor() ERC20("myDexToken", "MDT") {}

    address allotAddr;

    function mint(address account, uint256 amount) public {
        require(msg.sender == allotAddr, "address not allotAddr");
        _mint(account, amount);
    }

    function set(address _allotAddr) public onlyOwner {
        allotAddr = _allotAddr;
    }
}

