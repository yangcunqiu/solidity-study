require("@nomicfoundation/hardhat-toolbox");

const GANACHE_PRIVATEKEY = process.env.GANACHE_PRIVATEKEY

module.exports = {
  solidity: "0.8.18",

  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: GANACHE_PRIVATEKEY
    }
  }
};
