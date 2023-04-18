const hre = require("hardhat");

async function main() {
    const ZML = await hre.ethers.getContractFactory("ZML");
    const zml = await ZML.deploy(100000);
    await zml.deployed();
    console.log("ZML deployed to: %s[%s]", hre.network.name, zml.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})