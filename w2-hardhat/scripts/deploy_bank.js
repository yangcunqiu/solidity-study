const hre = require("hardhat");

async function main() {
  const Bank = await hre.ethers.getContractFactory("Bank");
  const bank = await Bank.deploy();

  await bank.deployed();
  console.log("Bank deployed to: %s[%s]", hre.network.name, bank.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
