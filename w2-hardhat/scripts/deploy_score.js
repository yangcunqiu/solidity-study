const hre = require("hardhat");

async function main() {
  const Teacher = await hre.ethers.getContractFactory("Teacher");
  const teacher = await Teacher.deploy();
  await teacher.deployed();
  console.log("Teacher deployed to: %s[%s]", hre.network.name, teacher.address);
  
  const Score = await hre.ethers.getContractFactory("Score");
  const score = await Score.deploy(teacher.address);
  await score.deployed();
  console.log("Score deployed to: %s[%s]", hre.network.name, score.address);  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});