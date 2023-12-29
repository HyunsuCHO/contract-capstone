//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Counters.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OriginalNFTOpenland2 is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenId;
    string internal baseTokenURI;

    function initialize() public initializer {
        __ERC721_init("openland2_test", "capstone");
        baseTokenURI = "https://app.bueno.art/api/contract/ypUNbeo6odkIVlsCPEqVm/chain/1/metadata/";
        __Ownable_init(msg.sender);
    }

    function mintNFT() public onlyOwner returns(uint256){
        _tokenId.increment();

        uint256 newItemId = _tokenId.current();
        _mint(msg.sender, newItemId);

        return newItemId;
    }

    function transfer(address to, uint256 tokenId) public onlyOwner {
        _transfer(msg.sender, to, tokenId);
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId)));
    }

    function getCurrentTokenId() public view returns(uint256) {
        return _tokenId.current();
    }
}