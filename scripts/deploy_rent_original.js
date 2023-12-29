const { ethers, upgrades } = require("hardhat");

const main = async () => {
  const OriginalNFTOpenland = await ethers.getContractFactory("OriginalNFTOpenland2");

  console.log(OriginalNFTOpenland)
  const OriginalNFTOpenlands = await upgrades.deployProxy(OriginalNFTOpenland, [], {
    initializer: "initialize",
  });

  console.log("Contract deployed");
};
main();

