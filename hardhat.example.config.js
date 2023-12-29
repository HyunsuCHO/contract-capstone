require("@nomicfoundation/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

const pvkey =
    "";

module.exports = {
  solidity: "0.8.22",
  networks: {
    goerli: {
      url: `[infura goerli endpoint]`,
      accounts: [pvkey],
    },
  },
  etherscan: {
    apiKey: "[option]",
  },
};