const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace", function () {
  it("Should create and execute market sales", async function () {
    //const admin, creator, buyer1, buyer2, buyer3;
    // const sampleToken = await ethers.getContractFactory("MockERC20");
    // const mockerc20 = await sampleToken.deploy();
    // await mockerc20.deployed();
    // console.log("token deployed");
    // token.transfer(buyer1.address, ethers.utils.parseUnits('500', 'ethers'));
    // token.transfer(buyer2.address, ethers.utils.parseUnits('500', 'ethers'));

    //console.log(token.balanceOf(buyer1.address));

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

    // const auctionPrice = ethers.utils.parseUnits('1', 'ether');

    var tokenURI = `https://bafybeidff4iuuyvzi67olw6cbibcolmrm25gfmcyxag4ziwdpnm2wedlkq.ipfs.infura-ipfs.io/`;
    var transaction = await nft.createToken(tokenURI,);

    // await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice });
    transaction = await market.listItemForSale(nftContractAddress, tokenId, 2);
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


    await market.connect(buyerAddress).listItemForSale(nftContractAddress, 1,)

    items = await market.fetchMarketItems()
    console.log("after sale: ", items);

    items = await market.fetchMyNFTs()
    console.log("My items: ", items);
  });
});