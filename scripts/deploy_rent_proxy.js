const {ethers, upgrades} = require("hardhat");
const proxy = "proxy contract";

const main = async () => {
    const RentNFTOpenland = await ethers.getContractFactory("RentNFTOpenland2");
    console.log(RentNFTOpenland)

    await upgrades.upgradeProxy(proxy, RentNFTOpenland);

    console.log("Contract upgraded.");
};

main();