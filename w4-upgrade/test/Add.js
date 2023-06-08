const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("add", function() {
    let add;
    before(async function() {
        const Add = await hre.ethers.getContractFactory("Add");
        add = await Add.deploy();
        await add.deployed();
    });

    it("once", async function() {
        const num = await add.num();
        await add.increment();
        const num2 = await add.num();
        expect(num2).to.equal(num.add(1));
    });

    it("mult", async function() {
        const preNum = await add.num();

        // 获取abi编码
        const incrementFunctionData = add.interface.encodeFunctionData("increment");

        const callData = [
            incrementFunctionData,
            incrementFunctionData,
            incrementFunctionData
        ];

        await add.multicall(callData);

        const postNum = await add.num();
        expect(postNum).to.equal(preNum.add(3));
    });
});