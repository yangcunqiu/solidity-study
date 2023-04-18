const { ethers } = require("hardhat");
const { expect } = require("chai");
const { BigNumber } = require("ethers");

describe("Vault", function() {
    const initialSupply = 100000;
    let zml, vault, owner, otherAccount;
    before(async function() {
        // init
        [owner, otherAccount] = await ethers.getSigners();
        const ZML = await ethers.getContractFactory("ZML");
        zml = await ZML.deploy(initialSupply);
        await zml.deployed();
        console.log("ZML deployed to: %s[%s]", network.name, zml.address);
        const Vault = await ethers.getContractFactory("Vault");
        vault = await Vault.deploy(zml.address);
        await vault.deployed();
        console.log("Vault deployed to: %s[%s]", network.name, vault.address);
    });

    describe("zml", function() {
        it("balance", async function() {
            expect(await zml.balanceOf(owner.address)).to.equal(BigNumber.from(initialSupply).mul(BigNumber.from(10).pow(18)));
        });
    });

});