const hre = require("hardhat");

async function main() {
    const mockERC20 = await hre.ethers.getContractFactory("MockERC20");
    const token = await mockERC20.deploy(1000000000);
    await token.deployed();
    console.log("mock erc20 token deployed to: ", token.address);

}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });