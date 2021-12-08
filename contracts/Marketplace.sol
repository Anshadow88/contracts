//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IWETH.sol";

import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    uint256[] itemsSoldOrUnlisted;

    address payable owner;
    IERC20 public weth;
    address public WETHAddress = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public CreateLabs = 0x77D2538297DC7a67c39B77bDbAD7c5267E0a156c;

    /**
    Polygon WETH: 0x7ceb23fd6bc0add59e62ac25578270cff1b9f619
     */

    constructor() {
        owner = payable(msg.sender);
        weth = ERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
    }

    // uint8 royalty = 8;

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable creator;
        uint256 price;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => bool) private itemIdToBoolean;

    event MarketItemListed(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address payable seller,
        address payable creator,
        uint256 price
    );

    event MarketItemUnlisted(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address payable seller,
        address payable creator,
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
            payable(msg.sender),
            price
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemListed(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(msg.sender),
            price
        );
    }

    function unlistItemfromMarket(address nftContract, uint256 itemId)
        public
        nonReentrant
    {
        require(
            idToMarketItem[itemId].seller == msg.sender,
            "Cannot unlist, not the owner."
        );
        address seller = idToMarketItem[itemId].seller;
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address creator = idToMarketItem[itemId].creator;
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        itemIdToBoolean[itemId] = false;
        emit MarketItemUnlisted(
            itemId,
            nftContract,
            tokenId,
            payable(seller),
            payable(creator),
            price
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        require(
            msg.sender != idToMarketItem[itemId].seller,
            "you cannot buy this item, this is your's"
        );
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        require(weth.balanceOf(msg.sender) >= price, "Pay the price.");

        weth.transferFrom(
            msg.sender,
            idToMarketItem[itemId].seller,
            (price * 95) / 100
        );

        weth.transferFrom(msg.sender, CreateLabs, (price * 5) / 100);
        console.log("Price paid to owner", (msg.value * 5) / 100);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].creator = payable(msg.sender);
    }

    function fetchIndividualNFT(uint256 itemId)
        public
        view
        returns (MarketItem memory)
    {
        return idToMarketItem[itemId];
    }

    function fetchAllNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](totalItemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (itemIdToBoolean[i + 1] == true) {
                items[currentIndex] = idToMarketItem[
                    idToMarketItem[i + 1].itemId
                ];
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
}
