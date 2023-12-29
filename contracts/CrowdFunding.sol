// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CrowdFunding is ERC721URIStorage, Ownable {
    using Strings for uint256;

    uint256 public constant REQUIRED_CONSENTS = 5;
    uint256 public constant MAX_MINTS_PER_ADDRESS = 5; // 각 주소당 최대 민팅 가능한 NFT 수
    uint256 public constant MINT_PRICE = 0.01 ether;
    uint256 public constant EARLY_BIRD_MINT_PRICE = 0.05 ether;

    uint256 public consentDeadline;
    uint256 public mintingDeadline;
    uint256 public earlyBirdConsentStartTime;
    uint256 public earlyBirdConsentEndTime;

    uint256 public _tokenId = 1;
    uint256 public totalConsents = 0;
    bool private mintAtOnce = false;
    bool private mintEach = false;

    string private baseTokenURI = "https://app.bueno.art/api/contract/ypUNbeo6odkIVlsCPEqVm/chain/1/metadata/65";
    string private revealedTokenURI = "";
    bool public revealed = false;

    address[] private consenters;
    mapping(address => bool) public hasConsented;
    mapping(address => uint256) public consentedTokens; // 각 주소별 동의한 NFT 수
    mapping(address => bool) public hasMinted;
    mapping(address => uint256) public fundRaised;
    string public _tokenURI;

    constructor()
    ERC721('Openland_crowdFunding', 'capstone')
    Ownable(msg.sender)
    {}

    function consentToSponsor(uint256 numConsents) public payable {
        require(block.timestamp < consentDeadline, "Consent deadline passed");
        require(msg.value == MINT_PRICE * numConsents, "Incorrect value sent");
        require(numConsents > 0 && numConsents <= MAX_MINTS_PER_ADDRESS, "Invalid number of consents");

        updateConsentStatus(msg.sender, numConsents);
        totalConsents += numConsents;
        fundRaised[msg.sender] += msg.value;
    }

    function consentToEarlyBirdSponsor(uint256 numConsents) public payable {
        require(block.timestamp >= earlyBirdConsentStartTime && block.timestamp < earlyBirdConsentEndTime, "Outside of early bird period");
        require(msg.value == EARLY_BIRD_MINT_PRICE * numConsents, "Incorrect value sent");
        require(numConsents > 0 && numConsents <= MAX_MINTS_PER_ADDRESS, "Invalid number of consents");

        updateConsentStatus(msg.sender, numConsents);
        totalConsents += numConsents;
        fundRaised[msg.sender] += msg.value;
    }

    function updateConsentStatus(address consenter, uint256 numConsents) private {
        if (hasConsented[consenter]) {
            require(consentedTokens[consenter] + numConsents <= MAX_MINTS_PER_ADDRESS, "Exceeds max consents per address");
            consentedTokens[consenter] += numConsents;
        } else {
            hasConsented[consenter] = true;
            consentedTokens[consenter] = numConsents;
            consenters.push(consenter);
        }
    }

    function checkFundingIsSuccess() public view returns (bool) {
        return totalConsents >= REQUIRED_CONSENTS;
    }

    // 옐로우리스트랑 퍼블릭민트랑 한번에 되도록하고 이건 컨트랙트 오너만 가능
    // 추가로 외부에서 누구나 호출 가능한 mint함수 제작 - 당연히 미리 펀딩했는지 체크 있어야함
    function mintNFTatOnce() public onlyOwner  {
        require(checkFundingIsSuccess(), "You can't withdraw, funding is failed");
        require(block.timestamp >= mintingDeadline, "It's not time yet");
        require(!mintAtOnce && !mintEach, "Minting already in progress");

        for (uint256 j = 0; j < consenters.length; j++) {
            address consenter = consenters[j];
            if (hasConsented[consenter]) {
                for (uint256 i = 0; i < consentedTokens[consenter]; i++) {
                    _mint(consenter, _tokenId);
                    _tokenId++;
                }
            }
        }

        mintAtOnce = true;
    }

    function mintNFTEach() public {
        require(checkFundingIsSuccess(), "You can't withdraw, funding is failed");
        require(block.timestamp >= mintingDeadline, "It's not time yet");
        require(consentedTokens[msg.sender] <= 0, "No tokens consented");
        require(!hasMinted[msg.sender], "Already minted your tokens");

        for (uint256 i = 0; i < consentedTokens[msg.sender]; i++) {
            _mint(msg.sender, _tokenId);
            _tokenId++;
        }

        hasMinted[msg.sender] = true; // Update the status to prevent future minting
        mintEach = true;
    }

    function withdrawFundRaised() public payable {
        require(!checkFundingIsSuccess(), "You can't withdraw, funding is success");
        require(block.timestamp >= mintingDeadline, "It's not time yet");

        uint256 balance = fundRaised[msg.sender];
        fundRaised[msg.sender] = 0;
        _transferFund(payable(msg.sender), balance);
    }

    function _transferFund(address payable to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        require(to != address(0), 'Error, cannot transfer to address(0)');

        (bool transferSent, ) = to.call{value: amount}("");
        require(transferSent, "Error, failed to send Ether");
    }

    // 민팅 관련 시간 설정 함수
    function setMintingTimes(uint256 _mintingDeadline, uint256 _consentDeadline , uint256 _earlyBirdStart, uint256 _earlyBirdEnd) public onlyOwner {
        mintingDeadline = _mintingDeadline;
        consentDeadline = _consentDeadline;
        earlyBirdConsentStartTime = _earlyBirdStart;
        earlyBirdConsentEndTime = _earlyBirdEnd;
    }

    // 설정된 값들을 읽는 함수
    function getMintingInfo() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, bool) {
        return (
            REQUIRED_CONSENTS,
            MAX_MINTS_PER_ADDRESS,
            MINT_PRICE,
            EARLY_BIRD_MINT_PRICE,
            mintingDeadline,
            consentDeadline,
            earlyBirdConsentStartTime,
            earlyBirdConsentEndTime,
            totalConsents,
            mintAtOnce,
            mintEach
        );
    }

    function setRevealedTokenURI(string memory _newTokenURI) public onlyOwner {
        revealedTokenURI = _newTokenURI;
        revealed = true;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        if(revealed) {
            return string(abi.encodePacked(revealedTokenURI, tokenId.toString()));
        } else {
            return baseTokenURI;
        }
    }
}
