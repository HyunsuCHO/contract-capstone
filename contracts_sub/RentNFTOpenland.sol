// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC4907.sol";
import "./Counters.sol";

contract RentNFTOpenland is ERC4907, OwnableUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    string private baseTokenURI;

    mapping(uint256 => bool) private allowedTokens; // 대여 가능한 토큰
    mapping(uint256 => uint256) private tokenRentPrices; // 토큰별 대여 가격

    function initialize() public initializer {
        __ERC721_init("rent_4907_openland_test", "capstone");
        __Ownable_init(msg.sender);
        baseTokenURI = "https://app.bueno.art/api/contract/ypUNbeo6odkIVlsCPEqVm/chain/1/metadata/65";
    }
    // 기존 ERC721 내용
    function mintNFT() public onlyOwner returns(uint256){
        _tokenId.increment();

        uint256 newItemId = _tokenId.current();
        _mint(msg.sender, newItemId);

        return newItemId;
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId)));
    }

    // 대여 허락한 토큰 아이디별 가격 셋팅 함수
    function setRentPrices(uint256[] memory tokenIds, uint256[] memory prices) public onlyOwner {
        require(tokenIds.length == prices.length, "Token IDs and prices array length must match");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenRentPrices[tokenIds[i]] = prices[i];
        }
    }

    function getRentPrice(uint256 tokenId) public view returns (uint256) {
        return tokenRentPrices[tokenId];
    }

    function allowedToken(uint256 tokenId, bool allowed) public onlyOwner {
        allowedTokens[tokenId] = allowed;
    }

    function checkIsAllowedToken(uint tokenId) public view returns (bool) {
        require(allowedTokens[tokenId], "ERC4907: TokenId not allowed for renting");
        return allowedTokens[tokenId];
    }

    // 가격 * 시간에 맞는 돈을 보냈는지 확인
    function checkPayment(uint256 tokenId, uint256 duration) private {
        require(msg.value >= tokenRentPrices[tokenId] * duration, "Insufficient funds sent");
    }

    function rentForThreeMonths(uint256 tokenId) public payable {
        checkIsAllowedToken(tokenId);
        checkPayment(tokenId, 3);

        // 대여 기간 설정 및 사용자 설정
        uint64 expires = uint64(block.timestamp + 90 days);
        setUser(tokenId, msg.sender, expires);
    }

    // 월 대여 가격 * 파라미터의 돈이 보내졌는지 확인
    function extendRenting(uint256 tokenId, uint256 additionalMonths) public payable {
        checkIsAllowedToken(tokenId);
        checkPayment(tokenId, additionalMonths);

        UserInfo storage info = _users[tokenId];
        require(info.user == msg.sender, "ERC4907: Caller is not current user");
        info.expires += uint64(additionalMonths * 30 days);
    }

    // 해당 토큰을 대여한 정보 리턴
    function getRentInfo(uint256 tokenId) public view returns (address user, uint256 expires) {
        UserInfo storage info = _users[tokenId];
        return (info.user, info.expires);
    }

    // 중도 취소 함수
    function cancelRent(uint256 tokenId) public {
        require(_isAuthorized(ownerOf(tokenId), msg.sender, tokenId), "ERC4907: Caller is not owner nor approved");
        UserInfo storage info = _users[tokenId];
        require(info.user != address(0), "ERC4907: No active rent to cancel");

        uint256 remainingMonths = (info.expires - block.timestamp) / 30 days;
        if (remainingMonths > 0) {
            uint256 refund = remainingMonths * tokenRentPrices[tokenId];
            payable(msg.sender).transfer(refund);
        }

        emit UpdateUser(tokenId, address(0), 0);
        delete _users[tokenId];
    }

    // 기존에 민팅한 토큰 넘버와 맞추기
    function setTokenId(uint256 currentTokenCnt) public onlyOwner {
        for (uint256 i; i <= currentTokenCnt; i++){
            _tokenId.increment();
        }
    }
}
