const hre = require("hardhat");

async function main() {
    const Vault = await hre.ethers.getContractFactory("Vault");
    const vault = await Vault.deploy("0x5FbDB2315678afecb367f032d93F642f64180aa3");
    await vault.deployed();
    console.log("Vault deployed to: %s[%s]", hre.network.name, vault.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})