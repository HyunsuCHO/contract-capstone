// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./IERC4907.sol";
import {OriginalNFTOpenland2Proxy} from "./OriginalNFTOpenland2Proxy.sol";

// ERC721Upgradeble만 쓰면 ERC4907Upgradable로 쓸 수 있음
// 여기서는 OriginalNFTOpenland2의 프록시니 ERC4907Upgradable이 포함된 해당 컨트랙트 상속으로 변경
contract ERC4907CustomUpgradable is OriginalNFTOpenland2Proxy, IERC4907 {

    struct UserInfo {
        address user;
        uint64 expires;
    }

    mapping (uint256 => UserInfo) internal _users;

    // @ERC4907TempUpgradable 아래는 변경x
    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual {
        require(
        /**
         * openzepplin/contracts release 5.0.0 부터
         * _isApprovedOrOwner(address spender, uint256 tokenId) → bool가
         * function _isAuthorized(address owner, address spender, uint256 tokenId) -> bool로 변경
         */
            _isAuthorized(ownerOf(tokenId), msg.sender, tokenId),
            "setUser: setUser caller is not owner nor approved"
        );
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId,user,expires);
    }

    function userOf(uint256 tokenId) public view virtual returns (address) {
        if(uint256(_users[tokenId].expires) >=  block.timestamp){
            return _users[tokenId].user;
        } else{
            return address(0);
        }
    }

    function userExpires(uint256 tokenId) public view virtual returns (uint256) {
        return _users[tokenId].expires;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Upgradeable, IERC4907) returns (bool) {
        return interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // _beforeTokenTransfer openzepplin/contracts 5.0.0 부터 _update로 변경
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override(ERC721Upgradeable) returns (address){
        super._update(to, tokenId, auth);
        address from = _ownerOf(tokenId);
        if (auth != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
        return from;
    }
}
