const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");

module.exports = async function (deployer, network, addresses) {
  try {
    EvolveAdminUpdater.address
    console.log('admin updater already deployed. skipping deploy...')
  } catch (e) {
    await deployer.deploy(EvolveAdminUpdater, web3.utils.toChecksumAddress(addresses[0]))
  }
};
