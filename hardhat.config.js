require("@nomiclabs/hardhat-waffle");

const projectId = require("./projectId").projectId;
const fs = require("fs");
const privateKey = fs.readFileSync(".key").toString();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/klOlNm_rQCabx94IjAdS_ZBHzNCkRXFX",
      //url: "https://rpc-mumbai.matic.today",
      //url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts: [privateKey],
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${projectId}`,
      accounts: [privateKey],
    },
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/77Wy8P0Ua9eWbtADqxk67t_anh5pHPAv`,
      accounts: [privateKey],
    }
  },
  solidity: "0.8.4",
};
