# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

# Marketplace Contracts
```sol
getListingPrice() public view returns (uint256)

createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant 
    
createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
        
fetchMarketItems() public view returns (MarketItem[] memory)

fetchMyNFTs() public view returns (MarketItem[] memory)

fetchItemsCreated() public view returns (MarketItem[] memory)
```
