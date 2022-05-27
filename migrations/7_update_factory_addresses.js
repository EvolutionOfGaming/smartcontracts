const FactoryEvolve = artifacts.require("./EvolveFactory.sol");
const StorageEvolve = artifacts.require("./EvolveStorage.sol");
const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");
const ERC20 = artifacts.require("./ERC20Mock.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  const config =
    allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

  const storageInstance = config.storage
    ? await StorageEvolve.at(web3.utils.toChecksumAddress(config.storage))
    : await StorageEvolve.deployed();

  await storageInstance.updateFactoryAddress(FactoryEvolve.address);
  console.log("updated factory address in storage");

  const bulkSenderInstance = config.bulkSender
    ? await EvolveBulkSender.at(web3.utils.toChecksumAddress(config.bulkSender))
    : await EvolveBulkSender.deployed();
  await bulkSenderInstance.updateFactoryAddress(FactoryEvolve.address);
  console.log("updated factory address in bulk sender");

  const evolveAdminUpdaterInstance = config.adminUpdater
    ? await EvolveAdminUpdater.at(web3.utils.toChecksumAddress(config.adminUpdater))
    : await EvolveAdminUpdater.deployed();
  await evolveAdminUpdaterInstance.updateFactory(FactoryEvolve.address);
  console.log("updated factory address in admin updater");


};
