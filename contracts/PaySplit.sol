// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IKairos, OfferArgs, Root, Offer } from "kairos/interface/IKairos.sol";

import "./mocks/FlashLender.sol";
import "./mocks/Marketplace.sol";

contract PaySplit is FlashBorrower {
    IKairos immutable kairos;
    Marketplace immutable marketplace;
    FlashLender immutable flashLender;
    IERC20 immutable money;

    constructor (IKairos _kairos, Marketplace _marketplace, FlashLender _flashLender, IERC20 _money) {
        kairos = _kairos;
        marketplace = _marketplace;
        flashLender = _flashLender;
        money = _money;
    }

    function buyInSplits(IERC721 implem, uint256 tokenId, OfferArgs calldata offerArgs) external {
        uint256 toPayNow = marketplace.PRICE() - offerArgs.amount;
        bytes memory data = abi.encode(implem, tokenId, offerArgs);

        money.transferFrom(msg.sender, address(this), toPayNow);
        flashLender.borrow(marketplace.PRICE(), data);
    }

    function flashCallback(bytes calldata data) external {
        (IERC721 implem, uint256 tokenId, OfferArgs memory offerArgs) = abi.decode(data, (IERC721, uint256, OfferArgs));
        OfferArgs[] memory kairosArgs = new OfferArgs[](1);
        kairosArgs[0] = offerArgs;

        marketplace.buy(implem, tokenId);
        IERC721(implem).safeTransferFrom(address(this), address(kairos), tokenId, abi.encode(kairosArgs)); // borrow from kairos
        money.transfer(address(flashLender), marketplace.PRICE());
    }
}