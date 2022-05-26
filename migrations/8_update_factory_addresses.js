const FactoryEvolve = artifacts.require("./EvolveFactory.sol");
const StorageEvolve = artifacts.require("./EvolveStorage.sol");
const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");

module.exports = async function (deployer, network, addresses) {
  const storageInstance = await StorageEvolve.deployed();
  const bulkSenderInstance = await EvolveBulkSender.deployed();
  const evolveAdminUpdaterInstance = await EvolveAdminUpdater.deployed();

  await evolveAdminUpdaterInstance.updateFactory(FactoryEvolve.address);
  console.log('updated factory address in admin updater')
  await storageInstance.updateFactoryAddress(FactoryEvolve.address);
  console.log('updated factory address in storage')
  await bulkSenderInstance.updateFactoryAddress(FactoryEvolve.address);
  console.log('updated factory address in bulk sender')

};
