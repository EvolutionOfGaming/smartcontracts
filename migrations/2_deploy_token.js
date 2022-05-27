const ERC20 = artifacts.require("./ERC20Mock.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  const config = allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;
  // TODO : use the real EvolveToken.sol and remove config file 
  // if (!EvolveToken.address)
  if (!config.token) {
    await deployer
      .deploy(
        ERC20,
        "evolve token",
        "EVOLVE",
        web3.utils.toBN("10000000000000000000000000000000000000000")
      )
      .then(() => {
        return ERC20.deployed();
      });
  }
};