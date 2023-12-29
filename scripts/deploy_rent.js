const { ethers} = require('ethers');
// const abi = require("./ProxyUpgradableABI.json");
// const abi = require("./OrginalNFTOpenland.json");
const abi = require("../ABI/UpgradableProxy.json");
// 프로바이더 설정
const provider = new ethers.providers.JsonRpcProvider('');

// 프록시 컨트랙트 인스턴스 생성
const proxyContractAddress = ''; // 프록시 컨트랙트 주소
 // 프록시 컨트랙트의 ABI
const proxyContract = new ethers.Contract(proxyContractAddress, abi, provider);

const privateKey ="";

// 지갑 생성 및 프로바이더 연결
const wallet = new ethers.Wallet(privateKey, provider);
const signer = wallet.connect(provider);

// 프록시 컨트랙트 인스턴스에 서명자 연결
const proxyContractWithSigner = proxyContract.connect(signer);

// 비동기 함수 정의 및 호출
async function mintNFT() {
    // 트랜잭션 보내기
    // const txResponse = await proxyContractWithSigner.setTokenURI({
    //     gasLimit: 6721975
    // });

    const uri = await proxyContractWithSigner.getInplementation();
    console.log("Token URI for token ID is", uri);
    return uri;
    // console.log("Transaction sent! Hash:", txResponse.hash);
    //
    // // 트랜잭션 영수증 기다리기
    // const receipt = await txResponse.wait();
    //
    // // 영수증 정보 출력
    // console.log("Transaction confirmed! Block number:", receipt.blockNumber);
    // console.log(receipt); // 전체 영수증 정보 출력
}

mintNFT();
