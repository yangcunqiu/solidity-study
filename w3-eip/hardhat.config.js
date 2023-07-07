require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const aliyunPrivate1 = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
const MUMBAI_PRIVATEKEY = process.env.MUMBAI_PRIVATEKEY;
const MUMBAI_PRIVATEKEY2 = process.env.MUMBAI_PRIVATEKEY2;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    aliyun: {
      url: "http://106.14.18.18:8545",
      accounts: [aliyunPrivate1]
    }
  }
};
