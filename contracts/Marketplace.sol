//SPDX-License-Identifier:  GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {
    uint256 private itemIds;
    // Counters.Counter private _itemIds;
    // Polygon WETH: 0x7ceb23fd6bc0add59e62ac25578270cff1b9f619
    IERC20 private constant WETH =
        IERC20(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);

    //IERC20 private constant WETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
    address private constant CreateLabs =
        0x32362F1fc149ce0B5c2B6ccE6aa70628012674cD;

    constructor() {
        itemIds = 0;
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address seller;
        uint256 price;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => bool) private itemIdToBoolean; // true if the itemId exists, false otherwise

    event MarketItemListed(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    event MarketItemUnlisted(
        uint256 itemId,
        address nftContract,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    function list(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public nonReentrant {
        require(price > 0, "Price must be more than 0");
        itemIds++;
        uint256 itemId = itemIds;
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            price
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        itemIdToBoolean[itemId] = true;
        emit MarketItemListed(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            price
        );
    }

    function unlistItem(uint256 itemId)
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
        address nftContract = idToMarketItem[itemId].nftContract;
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        itemIdToBoolean[itemId] = false;
        emit MarketItemUnlisted(
            itemId,
            nftContract,
            tokenId,
            payable(seller),
            price
        );
    }

    function buyNFT(uint256 itemId) public nonReentrant {
        require(
            msg.sender != idToMarketItem[itemId].seller,
            "you cannot buy this item, this is your's"
        );
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address nftContract = idToMarketItem[itemId].nftContract;

        require(WETH.balanceOf(msg.sender) >= price, "Insufficient balance");

        uint256 allow = WETH.allowance(msg.sender, address(this));
        require(allow >= price, "Insufficient allowance");

        WETH.transferFrom(
            msg.sender,
            idToMarketItem[itemId].seller,
            (price * 95) / 100
        );

        WETH.transferFrom(msg.sender, CreateLabs, (price * 5) / 100);
        // console.log("Price paid to owner", (msg.value * 5) / 100);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        itemIdToBoolean[itemId] = false;
    }

    function fetchIndividualNFT(uint256 itemId)
        public
        view
        returns (MarketItem memory)
    {
        require(itemId <= itemIds && itemIdToBoolean[itemId] == true, "Index not found.");
        return idToMarketItem[itemId];
    }

    function fetchAllNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = 0;
        uint256 currentIndex = 0;
        console.log("total items.");
        console.log(totalItemCount);
        for(uint256 i = 1; i <= itemIds; i++) {
            if(itemIdToBoolean[i] == true) {
                totalItemCount++;
            }
        } 
        MarketItem[] memory items = new MarketItem[](totalItemCount);
        for (uint256 i = 1; i <= itemIds; i++) {
            if (itemIdToBoolean[i] == true) {
                items[currentIndex] = idToMarketItem[
                    idToMarketItem[i].itemId
                ];
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = itemIds;
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
}
