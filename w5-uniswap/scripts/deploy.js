const hre = require("hardhat");

async function main() {
    const HL = await hre.ethers.getContractFactory("TokenMarket");
    const token = "";
    const WETH = "";
    const uniswapV2Route02 = ""; 

    const hl = await HL.deploy(token, WETH, uniswapV2Route02);
    await hl.deployed();
    console.log("HL deployed to: %s[%s]", hre.network.name, hl.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})