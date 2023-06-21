const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("MyDex", function(){
    let myDex;
    const MyDexAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

    before(async function() {
        const MyDex = await ethers.getContractFactory("MyDex");
        myDex = MyDex.attach(MyDexAddress);
    });

    describe("util", function(){
        
    });

    describe("tx", function(){
        
    });

});