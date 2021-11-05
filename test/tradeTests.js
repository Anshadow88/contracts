const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace", function () {
  it("Should create and execute market sales", async function () {
    const Market = await ethers.getContractFactory("Marketplace");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    // let listingPrice = await market.getListingPrice();
    // listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits('1', 'ether');

    // sample test image

    const tokenURI = `https://ipfs.infura.io/ipfs/QmfUBp86GDvxRxruDur5uJmUfi5BK3gyYSYK5iSrrTzbtA`;
    let transaction = await nft.createToken(tokenURI);
    let tx = await transaction.wait();
    let event = tx.events[0];
    let value = event.args[2];
    let tokenId = value.toNumber();

    console.log("tokenId: ", tokenId);
    // await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice });
    transaction = await market.listItemForSale(nftContractAddress, tokenId, auctionPrice, true);
    await transaction.wait();
    //await market.createMarketItem(nftContractAddress, 1, auctionPrice);

    const [_, buyerAddress] = await ethers.getSigners();

    var items = await market.fetchMarketItems()
    // console.log(items);
    // items = await Promise.all(items.map(async i => {
    //   const tokenUri = await nft.tokenURI(i.tokenId)
    //   let item = {
    //     price: i.price.toString(),
    //     tokenId: i.tokenId.toString(),
    //     seller: i.seller,
    //     owner: i.owner,
    //     tokenUri
    //   }
    // }))
    console.log("items before sale", items);

    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice })

    items = await market.fetchMarketItems()
    console.log("after sale: ", items);

    items = await market.fetchMyNFTs()
    console.log("My items: ", items);
  });
});