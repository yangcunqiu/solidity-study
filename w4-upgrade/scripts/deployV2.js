const {ethers, upgrades, network} = require("hardhat");

const proxyAddr = "0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0";

async function main() {
  const CalV2 = await ethers.getContractFactory("CalV2");
  const calV2 = await upgrades.upgradeProxy(proxyAddr, CalV2);

  console.log("CalV2 upgrade to: %s[%s]", network.name, proxyAddr);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
