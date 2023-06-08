const {ethers, upgrades, network} = require("hardhat");
const { getImplementationAddress } = require('@openzeppelin/upgrades-core');

async function main() {
  const Cal = await ethers.getContractFactory("Cal");
  const cal = await upgrades.deployProxy(Cal);

  await cal.deployed();
  // 1. 部署逻辑合约
  // 2. 部署代理
  // 3. 部署代理管理员

  console.log("Cal (proxy) deployed to: %s[%s]", network.name, cal.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
