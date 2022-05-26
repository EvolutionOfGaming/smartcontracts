const FactoryEvolve = artifacts.require("./EvolveFactory.sol");
const StorageEvolve = artifacts.require("./EvolveStorage.sol");
const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");
const ERC20 = artifacts.require("./ERC20Mock.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  const config = allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

  const tokenAddress = config.token
    ? web3.utils.toChecksumAddress(config.token)
    : ERC20.address;

  try {
    FactoryEvolve.address
    console.log('factory already deployed. skipping deploy...')
  } catch (e) {
    await deployer
      .deploy(
        FactoryEvolve,
        StorageEvolve.address,
        EvolveBulkSender.address,
        tokenAddress,
        EvolveAdminUpdater.address
      )
  }
};
