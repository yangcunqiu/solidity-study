require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// const MUMBAI_PRIVATEKEY = process.env.MUMBAI_PRIVATEKEY;
// const MUMBAI_PRIVATEKEY2 = process.env.MUMBAI_PRIVATEKEY2;
// const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  // networks: {
  //   mumbai: {
  //     url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
  //     accounts: [MUMBAI_PRIVATEKEY, MUMBAI_PRIVATEKEY2],
  //     chainId: 80001
  //   }
  // }
};
