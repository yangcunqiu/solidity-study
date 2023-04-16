const hre = require("hardhat");

async function main() {
  const Test = await hre.ethers.getContractFactory("Test");
  const test = await Test.deploy(10);

  await test.deployed();

  console.log("Test deployed to: ", test.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
