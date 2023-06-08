// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// 0x1b08e065b4Fb03766A5637E473a70A65499ee8a9
contract XHL is ERC721URIStorage {
    uint256 index;

    constructor() ERC721("testerc721", "XHL") {}

    // 铸造nft
    function mint(address _to, string memory _tokenURI) public returns(uint256) {
        uint256 tokenId = index;
        _mint(_to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        index++;
        return tokenId;
    }

}