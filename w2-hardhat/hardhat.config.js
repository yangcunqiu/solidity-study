require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

const GANACHE_PRIVATEKEY = process.env.GANACHE_PRIVATEKEY;
const MUMBAI_PRIVATEKEY = process.env.MUMBAI_PRIVATEKEY;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;

module.exports = {
  solidity: "0.8.18",

  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [GANACHE_PRIVATEKEY]
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [MUMBAI_PRIVATEKEY],
      chainId: 80001
    }
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY
  }
};
