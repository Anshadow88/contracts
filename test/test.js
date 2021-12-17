const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace", function () {
  it("Should create and execute market sales", async function () {
    const [_, buyer1, buyer2, admin] = await ethers.getSigners();
    const sampleERC20 = await ethers.getContractFactory("MockERC20");
    const mockerc20 = await sampleERC20.deploy(10 ^ 7);
    await mockerc20.deployed();
    console.log("token address: ", mockerc20.address);
    await mockerc20.transfer(buyer1.address, 10000);
    await mockerc20.transfer(buyer2.address, 10);
    let totalsupply = await mockerc20.totalSupply();
    console.log("total supply: ", totalsupply);
    let bal = await mockerc20.balanceOf(buyer2.address);
    console.log("balance sent when using `let bal = mockerc20.balanceOf(buyer2.address);`", bal);
    const Market = await ethers.getContractFactory("Marketplace");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;


    // NFT #1
    var tokenURI = `https://bafybeidff4iuuyvzi67olw6cbibcolmrm25gfmcyxag4ziwdpnm2wedlkq.ipfs.infura-ipfs.io/`;
    var txFeeToken = `0x0165878A594ca255338adfa4d48449f69242Eb8F`;
    var txFeeAmount = ethers.BigNumber.from(5);
    var transaction = await nft.createToken(tokenURI, txFeeToken, txFeeAmount);
    var tx = await transaction.wait();
    var event = tx.events[0];
    var value = event.args[2];
    var tokenId = value.toNumber();

    transaction = await market.list(nftContractAddress, tokenId, 1000);
    await transaction.wait();

    // NFT #2
    var tokenURI = `https://bafybeidff4iuuyvzi67olw6cbibcolmrm25gfmcyxag4ziwdpnm2wedlkq.ipfs.infura-ipfs.io/`;
    var txFeeToken = `0x0165878A594ca255338adfa4d48449f69242Eb8F`;
    var txFeeAmount = ethers.BigNumber.from(5);
    var transaction = await nft.createToken(tokenURI, txFeeToken, txFeeAmount);
    var tx = await transaction.wait();
    var event = tx.events[0];
    var value = event.args[2];
    var tokenId = value.toNumber();

    transaction = await market.list(nftContractAddress, tokenId, 2000);
    await transaction.wait();

    // NFT #3
    var tokenURI = `https://bafybeidff4iuuyvzi67olw6cbibcolmrm25gfmcyxag4ziwdpnm2wedlkq.ipfs.infura-ipfs.io/`;
    var txFeeToken = `0x0165878A594ca255338adfa4d48449f69242Eb8F`;
    var txFeeAmount = ethers.BigNumber.from(5);
    var transaction = await nft.createToken(tokenURI, txFeeToken, txFeeAmount);
    var tx = await transaction.wait();
    var event = tx.events[0];
    var value = event.args[2];
    var tokenId = value.toNumber();

    transaction = await market.list(nftContractAddress, tokenId, 3000);
    await transaction.wait();

    // fetching all NFTs
    var allNFTs = await market.fetchAllNFTs();
    console.log("All the NFTs", allNFTs);

    var ndNFT = await market.fetchIndividualNFT(2);
    console.log("second NFT", ndNFT);

    // unlist item from the marketplace
    transaction = await market.unlistItem(2);
    await transaction.wait();

    // fetching all NFTs
    var allNFTs = await market.fetchAllNFTs();
    console.log("All the NFTs", allNFTs);

    var fNFT = await market.fetchIndividualNFT(1);
    console.log("1st NFT", fNFT);

    // NFT #4
    var tokenURI = `https://bafybeidff4iuuyvzi67olw6cbibcolmrm25gfmcyxag4ziwdpnm2wedlkq.ipfs.infura-ipfs.io/`;
    var txFeeToken = `0x0165878A594ca255338adfa4d48449f69242Eb8F`;
    var txFeeAmount = ethers.BigNumber.from(5);
    var transaction = await nft.createToken(tokenURI, txFeeToken, txFeeAmount);
    var tx = await transaction.wait();
    var event = tx.events[0];
    var value = event.args[2];
    var tokenId = value.toNumber();

    transaction = await market.list(nftContractAddress, tokenId, 4000);
    await transaction.wait();

    // fetching all NFTs
    var allNFTs = await market.fetchAllNFTs();
    console.log("All the NFTs", allNFTs);


  });
});