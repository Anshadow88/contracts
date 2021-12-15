// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require("fs");
const { ethers } = require("ethers");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const mockERC20 = await hre.ethers.getContractFactory("MockERC20");
  const token = await mockERC20.deploy();
  await token.deployed();
  console.log("mock erc20 token deployed to: ", token.address);
  // We get the contract to deploy
  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const market = await Marketplace.deploy();
  await market.deployed();
  console.log("market deployed to:", market.address);

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(market.address);
  await nft.deployed();
  console.log("NFT deployed to:", nft.address);

  let config = `
  export const nftmarketaddress = "${market.address}"
  export const nftaddress = "${nft.address}"
  `

  let data = JSON.stringify(config)
  fs.writeFileSync('config.js', JSON.parse(data))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
