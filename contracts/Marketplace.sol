//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    uint256 platformCommission = 5;

    constructor() {
        owner = payable(msg.sender);
    }

    // defining each Market Item
    struct Item {
        uint256 itemId;
        uint256 nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        string collectible;
        bool onSale;
        bool onAuction;
    }

    mapping(uint256 => Item) private idToItem;

    // mapping(uint256 => Item) private idToMarketItem;

    // function createMarketItem(
    //     address nftContract,
    //     uint256 tokenId,
    //     uint256 price
    // ) public payable nonReentrant {
    //     require(price > 0, "Price must be more than 0");

    //     console.log("Token created by: ", msg.sender);
    //     _itemIds.increment();
    //     uint256 itemId = _itemIds.current();

    //     idToMarketItem[itemId] = MarketItem(
    //         itemId,
    //         nftContract,
    //         tokenId,
    //         payable(msg.sender),
    //         payable(address(0)),
    //         price,
    //         false
    //     );

    //     IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    //     emit MarketItemCreated(
    //         itemId,
    //         nftContract,
    //         tokenId,
    //         payable(msg.sender),
    //         payable(address(0)),
    //         price,
    //         false
    //     );
    // }

    // function createMarketSale(address nftContract, uint256 itemId)
    //     public
    //     payable
    //     nonReentrant
    // {
    //     require(
    //         msg.sender != idToMarketItem[itemId].owner,
    //         "you cannot buy this item, this is your's"
    //     );
    //     uint256 price = idToMarketItem[itemId].price;
    //     uint256 tokenId = idToMarketItem[itemId].tokenId;

    //     require(msg.value == price, "Pay the price.");

    //     idToMarketItem[itemId].seller.transfer(msg.value);
    //     IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    //     idToMarketItem[itemId].owner = payable(msg.sender);
    //     idToMarketItem[itemId].sold = true;
    //     _itemsSold.increment();
    //     // payable(owner).transfer(listingPrice);
    // }

    // function fetchMarketItems() public view returns (MarketItem[] memory) {
    //     uint256 itemCount = _itemIds.current();
    //     uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
    //     uint256 currentIndex = 0;

    //     MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    //     for (uint256 i = 0; i < itemCount; i++) {
    //         if (idToMarketItem[i + 1].owner == address(0)) {
    //             uint256 currentId = idToMarketItem[i + 1].itemId;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return items;
    // }

    // function fetchMyNFTs() public view returns (MarketItem[] memory) {
    //     uint256 totalItemCount = _itemIds.current();
    //     uint256 itemCount = 0;
    //     uint256 currentIndex = 0;
    //     console.log("Sender :", msg.sender);
    //     for (uint256 i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].owner == msg.sender) {
    //             itemCount += 1;
    //         }
    //     }

    //     MarketItem[] memory items = new MarketItem[](itemCount);
    //     for (uint256 i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].owner == msg.sender) {
    //             uint256 currentId = idToMarketItem[i + 1].itemId;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return items;
    // }

    // function fetchItemsCreated() public view returns (MarketItem[] memory) {
    //     uint256 totalItemCount = _itemIds.current();
    //     uint256 itemCount = 0;
    //     uint256 currentIndex = 0;

    //     for (uint256 i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].seller == msg.sender) {
    //             itemCount += 1;
    //         }
    //     }

    //     MarketItem[] memory items = new MarketItem[](itemCount);
    //     for (uint256 i = 0; i < totalItemCount; i++) {
    //         if (idToMarketItem[i + 1].seller == msg.sender) {
    //             uint256 currentId = idToMarketItem[i + 1].itemId;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return items;
    // }

    // Events
    event NFTforSaleEvent(uint256 indexed itemId);
}
