require("@nomicfoundation/hardhat-toolbox");

aliyunPrivate1 = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
ganachePrivate = "0x05c584860a76edc4695f7c16173c74c5b5fca507016cad5530bc60b08cfc8555"

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
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [ganachePrivate]
    },
    aliyun: {
      url: "http://106.14.18.18:8545",
      accounts: [aliyunPrivate1]
    }
  }
};
