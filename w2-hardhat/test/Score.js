const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Score", function() {
    let teacher, score, owner, otherAccount;

    async function init() {
        [owner, otherAccount] = await ethers.getSigners();
        
        const Teacher = await ethers.getContractFactory("Teacher");
        teacher = await Teacher.deploy();
        await teacher.deployed();
        console.log("Teacher deployed to: %s[%s]", hre.network.name, teacher.address);

        const Score = await ethers.getContractFactory("Score");
        score = await Score.deploy(teacher.address);
        await score.deployed();
        console.log("Score deployed to: %s[%s]", hre.network.name, score.address);

        
    }

    before(async function() {
        await init();
    })

    it("score >= 100", async function() {
        expect(teacher.saveOrUpdate(score.address, otherAccount.address, 101)).to.be.revertedWith("score too large");
    });

    it("teacher address can saveOrUpdate", async function() {
        const init = 90;
        await teacher.saveOrUpdate(score.address, owner.address, init);
        const res = await score.scoreMap(owner.address);
        expect(res).to.equal(init);
    });

    it("otherAccount address can't saveOrUpdate", async function() {
        await expect(score.saveOrUpdate(owner.address, 90)).to.be.revertedWith("invalid address");
    });

});