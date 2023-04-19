const hre = require("hardhat");

async function main() {
    const HL = await hre.ethers.getContractFactory("HL");
    const hl = await HL.deploy(100000);
    await hl.deployed();
    console.log("HL deployed to: %s[%s]", hre.network.name, hl.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})