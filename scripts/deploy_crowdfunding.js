const hre = require("hardhat");

async function main() {
    // TimedConsent 컨트랙트 가져오기
    const CrowdFunding = await hre.ethers.getContractFactory("CrowdFunding");

    // TimedConsent 컨트랙트 배포
    const crowdFunding = await CrowdFunding.deploy();

    // 배포가 완료될 때까지 기다림
    // await crowdFunding.deployed();

    console.log("TimedConsent deployed to:", crowdFunding.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });