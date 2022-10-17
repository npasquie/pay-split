// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Marketplace is ERC721Holder {
    uint256 constant public PRICE = 1 ether;
    IERC20 immutable money;

    constructor(IERC20 _money){
        money = _money;
    }

    function buy(IERC721 implem, uint256 tokenId) external {
        IERC20(money).transferFrom(msg.sender, address(this), PRICE);
        IERC721(implem).transferFrom(address(this), msg.sender, tokenId);
    }
}