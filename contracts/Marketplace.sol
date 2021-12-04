//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    // Counters.Counter private _itemsSold;

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemListed(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address payable seller,
        address payable owner,
        uint256 price
    );

    event MarketItemUnlisted(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address payable seller,
        address payable owner,
        uint256 price
    );

    function listItemForSale(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be more than 0");
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(owner),
            price
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemListed(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(owner),
            price
        );
    }

    function unlistItemfromMarket(address nftContract, uint256 tokenId)
        public
        nonReentrant
    {
        require(idToMarketItem[tokenId].seller == msg.sender);
        address seller = idToMarketItem[tokenId].seller;
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        _itemIds.decrement();
        emit MarketItemUnlisted(
            itemId,
            nftContract,
            tokenId,
            payable(seller),
            payable(owner),
            price
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        require(
            msg.sender != idToMarketItem[itemId].owner,
            "you cannot buy this item, this is your's"
        );
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Pay the price.");
        console.log("msg.value", msg.value); // gwei
        idToMarketItem[itemId].seller.transfer((msg.value * 95) / 100);
        console.log(
            "Price paid to idToMarketItem[itemId].seller",
            (msg.value * 95) / 100
        );

        owner.transfer((msg.value * 5) / 100);
        console.log("Price paid to owner", (msg.value * 5) / 100);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].forSale = false;
        _itemsSold.increment();
        // payable(owner).transfer(listingPrice);
    }

    function fetchTokensForSale() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        console.log("Sender :", msg.sender);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // function fetchOwners() public view returns (address[] memory) {
    // }
}
