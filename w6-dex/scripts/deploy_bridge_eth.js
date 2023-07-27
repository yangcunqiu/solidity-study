const hre = require("hardhat");

async function main() {
    const WMTS = await hre.ethers.getContractFactory("WMTS");
    const wmts = await WMTS.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    await wmts.deployed();
    console.log("WMTS deployed to %s[%s]", hre.network.name, wmts.address);

    const ETHBridge = await hre.ethers.getContractFactory("ETHBridge");
    const ethBridge = await ETHBridge.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", wmts.address);
    await ethBridge.deployed();
    console.log("ETHBridge deployed to %s[%s]", hre.network.name, ethBridge.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});