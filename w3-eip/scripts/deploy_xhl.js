const hre = require("hardhat");

async function main() {
    const XHL = await hre.ethers.getContractFactory("XHL");
    const xhl = await XHL.deploy();
    await xhl.deployed();
    console.log("XHL deployed to: %s[%s]", hre.network.name, xhl.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})