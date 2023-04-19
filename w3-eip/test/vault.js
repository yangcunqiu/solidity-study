const { ethers } = require("hardhat");
const { expect } = require("chai");
const { BigNumber } = require("ethers");

describe("Vault", function() {
    const initialSupply = 100000;
    let hl, vault, owner, otherAccount;
    before(async function() {
        // init
        [owner, otherAccount] = await ethers.getSigners();
        const HL = await ethers.getContractFactory("HL");
        hl = await HL.deploy(initialSupply);
        await hl.deployed();
        console.log("hl deployed to: %s[%s]", network.name, hl.address);
        const Vault = await ethers.getContractFactory("Vault");
        vault = await Vault.deploy(hl.address);
        await vault.deployed();
        console.log("Vault deployed to: %s[%s]", network.name, vault.address);
    });

    describe("hl", function() {
        it("balance", async function() {
            expect(await hl.balanceOf(owner.address)).to.equal(BigNumber.from(initialSupply).mul(BigNumber.from(10).pow(18)));
        });
    });

    describe("deposit", function() {
        it("no approve not deposit", async function() {
            // await expect(vault.deposite(100)).to.be.reverted;
            await expect(vault.deposite(100)).to.be.revertedWith("ERC20: insufficient allowance");

        });

        it("add", async function() {
            const value = 100;
            // 先授权 再转账
            hl.approve(vault.address, value);
            const pre = await vault.tokenMap(owner.address);
            const preToken = await hl.balanceOf(owner.address);

            await vault.deposite(value);
            
            const post = await vault.tokenMap(owner.address);
            const postToken = await hl.balanceOf(owner.address);

            expect(post).to.equal(BigNumber.from(pre).add(value));
            expect(postToken).to.equal(BigNumber.from(preToken).sub(value));
        });
    });

    describe("withdraw", function() {
        it("too large", async function() {
            const pre = await vault.tokenMap(owner.address);
            const preToken = await hl.balanceOf(owner.address);

            await expect(vault.withdraw(BigNumber.from(pre).add(1))).to.be.revertedWith("not sufficient funds");

            const post = await vault.tokenMap(owner.address);
            const postToken = await hl.balanceOf(owner.address);

            expect(post).to.equal(pre);
            expect(postToken).to.equal(preToken);
        });

        it("normal withdraw", async function() {
            const pre = await vault.tokenMap(owner.address);
            const preToken = await hl.balanceOf(owner.address);

            await vault.withdraw(pre);

            const post = await vault.tokenMap(owner.address);
            const postToken = await hl.balanceOf(owner.address);

            expect(post).to.equal(0);
            expect(postToken).to.equal(BigNumber.from(preToken).add(pre));
        });
    });

});