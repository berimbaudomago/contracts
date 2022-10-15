require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
let secrets = require("./secrets.json");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: secrets.url,
      accounts: [secrets.key],
    },
    goerliOptimism: {
      url: secrets["optimism-url"],
      accounts: [secrets.key]
    }
  },

  etherscan: {
    apiKey: {
      goerli: secrets.apiKey
    } 
  },
};
