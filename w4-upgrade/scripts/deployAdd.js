const hre = require("hardhat");

async function main() {
    const Add = await hre.ethers.getContractFactory("Add");
    const add = await Add.deploy();
    await add.deployed();
    console.log("Add deployed to: %s[%s]", hre.network.name, add.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})