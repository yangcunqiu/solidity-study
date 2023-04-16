const { expect } = require("chai");

describe("Test", function () {
  
  let test;

  async function init() {
    // 部署合约
    const [owner, otherAccount] = await ethers.getSigners();
    const Test = await ethers.getContractFactory("Test");
    test = await Test.deploy(10);
    await test.deployed();
    console.log("Test deployed to: ", test.address);
  }

  before(async function() {
    await init();
  })

  it("init equal 10", async function() {
    expect(await test.num()).to.equal(10);
  })
  
  it("add 1 equal 11", async function () {
    expect(await test.add(1)).to.equal(12);
  })
});
