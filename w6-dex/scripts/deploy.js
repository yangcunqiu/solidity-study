const hre = require("hardhat");

async function main() {
  const PairFactory = await hre.ethers.getContractFactory("PairFactory");
  const factory = await PairFactory.deploy();
  await factory.deployed();
  console.log("PairFactory deployed to: %s[%s]", hre.network.name, factory.address);

  const MyDex = await hre.ethers.getContractFactory("MyDex");
  const myDex = await MyDex.deploy(factory.address);
  await myDex.deployed();
  console.log("MyDex deployed to: %s[%s]", hre.network.name, myDex.address)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
