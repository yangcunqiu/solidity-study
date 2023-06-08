const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("xhlMarket", function() {
    const token = "0x672465cbFa4306aDfaeDD1753Dfa036aBe08c4A6";
    const nftToken = "0x1b08e065b4Fb03766A5637E473a70A65499ee8a9";
    const xhlMarketAddr = "0xaDA5BcD78ef58170dE5A6Bf327829d1790eb85e8";
    let xhlMarket, hl, xhl, owner, otherAccount;

    before(async function() {
        [owner, otherAccount] = await ethers.getSigners();
        // const XHLMarket = await ethers.getContractFactory("XHLMarket");
        // xhlMarket = await XHLMarket.deploy(token, nftToken);
        // await xhlMarket.deployed();
        // console.log("XHLMarket deployed to: %s[%s]", network.name, xhlMarket.address);

        const XHLMarket = await ethers.getContractFactory("XHLMarket");
        xhlMarket = XHLMarket.attach(xhlMarketAddr);

        const HL = await ethers.getContractFactory("HL");
        hl = HL.attach(token);

        const XHL = await ethers.getContractFactory("XHL");
        xhl = XHL.attach(nftToken);
    });

    describe("list", function() {
        it("no exist tokenId", async function(){
            await expect(xhlMarket.list(20, 200)).to.be.reverted;
        });

        it("address not tokenId owner", async function(){
            await expect(xhlMarket.connect(otherAccount).list(1, 200)).to.be.reverted;
        });

        it("normal no approve", async function(){
            await expect(xhlMarket.list(1, 200)).to.be.reverted;
        });

        it("normal", async function(){
            const tokenId = 1;
            // 授权
            await xhl.approve(xhlMarket.address, tokenId);
            console.log("Token owner:", await xhl.ownerOf(tokenId));
            console.log("Token approved:", await xhl.getApproved(tokenId));
            await xhlMarket.list(tokenId, 200);
            expect(await xhlMarket.tokenPrice(1)).to.equal(200);
            expect(await xhlMarket.ownerOf(tokenId)).to.be.equal(xhlMarket.address);
        });
    });

    describe("buy", function() {
        it("aleady selled", async function(){
            await expect(xhlMarket.connect(otherAccount).buy(20, 100)).to.be.revertedWith("ERC721: invalid token ID");
        });
        it("low price", async function(){
            await expect(xhlMarket.connect(otherAccount).buy(1, 100)).to.be.revertedWith("low price");
        });
        it("normal no approve", async function(){
            await expect(xhlMarket.connect(otherAccount).buy(1, 200)).to.be.reverted;
        });
        it("normal", async function(){
            await hl.connect(otherAccount).approve(xhlMarket.address, 200);
            console.log(await h1.allowance(otherAccount.address, xhlMarket.address));
            await xhlMarket.connect(otherAccount).buy(1, 200);
            expect(await xhlMarket.ownerOf(1)).to.be.equal(otherAccount.address);
        });
    });
    
});