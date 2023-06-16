const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("MyDex", function(){
    let myDex;
    const MyDexAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

    before(async function() {
        const MyDex = await ethers.getContractFactory("MyDex");
        myDex = MyDex.attach(MyDexAddress);
    });

    describe("util", function(){
        
    });

    describe("tx", function(){

    });

});