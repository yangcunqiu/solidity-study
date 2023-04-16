const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bank", function () {
  let bank, owner, addr1;
  const CONTRACT_ADDRESS = "0x948bC534E7BFa7EF62b3492fd5C732283F1F47aE";

  before(async function () {
    [owner, addr1] = await ethers.getSigners();
    const Bank = await ethers.getContractFactory("Bank");
    bank = Bank.attach(CONTRACT_ADDRESS);
  });

  describe("transferMap", function () {
    it("Should return the correct balance of an address", async function () {
      const depositAmount = ethers.utils.parseEther("20.0");
      const depositedAmount = await bank.transferMap(owner.address);
      expect(depositedAmount).to.equal(depositAmount);
    });
  });

  describe("Withdraw", function () {
    console.log(owner);
    console.log(addr1);
    it("Should allow withdrawal and update balance", async function () {
      const ownerInitialBalance = await owner.getBalance();
      const gasPrice = (await owner.getGasPrice()).mul(10);

      const withdrawTx = await bank.connect(owner).withdraw();
      const gasUsed = (await withdrawTx.wait()).gasUsed;

      const ownerFinalBalance = await owner.getBalance();
      const expectedBalance = ownerInitialBalance
        .sub(gasUsed.mul(gasPrice));

      expect(ownerFinalBalance).to.equal(expectedBalance);
    });
  });
});
