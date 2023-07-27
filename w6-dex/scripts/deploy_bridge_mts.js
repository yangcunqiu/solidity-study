const hre = require("hardhat");

async function main() {
    const MTSBridge = await hre.ethers.getContractFactory("MTSBridge");
    const mtsBridge = await MTSBridge.deploy("0x057A16A940A8030A1adA52A756810d74F9dc7003");
    await mtsBridge.deployed();
    console.log("MTSBridge deployed to %s[%s]", hre.network.name, mtsBridge.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});