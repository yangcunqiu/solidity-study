const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("cal", function() {
    let cal, proxy, owner;
    const CONTRACT_ADDRESS = "0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0";
  
    before(async function () {
        [owner, otherAccount] = await ethers.getSigners();
        cal = await ethers.getContractFactory("Cal");
    
        // 使用 attach 方法来确保与升级代理进行交互
        proxy = await ethers.getContractAt("Cal", CONTRACT_ADDRESS);
    });

    it("num", async function() {
        const num = await proxy.num();
        console.log("pre num: ", num.toString());
        await proxy.add(1);
        console.log("post num: ", (await proxy.num()).toString());
        expect(await proxy.num()).to.equal(num.add(1));
    });
});
