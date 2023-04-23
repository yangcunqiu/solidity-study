const { ethers } = require("hardhat");

describe("xhl", function() {
    let xhl, owner, addr1;
    const CONTRACT_ADDRESS = "0x1b08e065b4Fb03766A5637E473a70A65499ee8a9";
  
    before(async function () {
      [owner, addr1] = await ethers.getSigners();
      const XHL = await ethers.getContractFactory("XHL");
      xhl = XHL.attach(CONTRACT_ADDRESS);
    });

    it("mint", async function() {
        await xhl.mint(owner.address, "ipfs://QmWdN8RGjrxX35y71moEjjoppcAvod6VUQjckFWcLa4BXX");
    });
});
