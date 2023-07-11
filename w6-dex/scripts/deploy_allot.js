const hre = require("hardhat");

async function main() {
    const Mdt = await hre.ethers.getContractFactory("MyDexToken");
    const mdt = await Mdt.deploy();
    await mdt.deployed();
    console.log("MyDexToken deployed to %s[%s]", hre.network.name, mdt.address);

    const Allot = await hre.ethers.getContractFactory("MyDexTokenAllot");
    const allot = await Allot.deploy(mdt.address, 10);
    await allot.deployed();
    console.log("MyDexTokenAllot deployed to %s[%s]", hre.network.name, allot.address);

    mdt.set(allot.address)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});