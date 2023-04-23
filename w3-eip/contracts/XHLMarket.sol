// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// 使用自己发行的erc20来买卖erc721
contract XHLMarket is IERC721Receiver {
    // tokenId => token价格
    mapping(uint256 => uint256) public tokenPrice;
    address immutable token;
    address immutable nftToken;

    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
    }

    // 表明这个合约可以接收erc721token
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
      return this.onERC721Received.selector;
    }

    // 上架nft
    function list(uint256 _tokenId, uint256 amount) public {
        // 将nft从调用者地址转移到合约地址 (需要调用者事先授权)
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), _tokenId, "");
        // 转成功说明没问题, 记录
        tokenPrice[_tokenId] = amount;
    }

    function buy(uint256 _tokenId, uint256 _amount) public {
        // nft是否还在
        require(IERC721(nftToken).ownerOf(_tokenId) == address(this), "aleady selled");
        // 查看出价
        require(_amount >= tokenPrice[_tokenId], "low price");
        // 将调用者的erc20转移到合约地址 (需要调用者事先授权)
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        // 将合约的nft转移到调用者地址
        IERC721(nftToken).transferFrom(address(this), msg.sender, _tokenId);
    }

}