require("@nomicfoundation/hardhat-toolbox");

aliyunPrivate1 = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    aliyun: {
      url: "http://106.14.18.18:8545",
      accounts: [aliyunPrivate1]
    }
  }
};
