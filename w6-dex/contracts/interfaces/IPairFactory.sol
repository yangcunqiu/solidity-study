// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPairFactory {
    function pairMap(address _tokenA, address _tokenB) external view returns(address);

    function createPair(address _tokenA, address _tokenB) external returns(address);


}