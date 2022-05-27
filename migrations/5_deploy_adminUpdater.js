const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  const config =
    allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

  try {
    if (!config.adminUpdater) {
      EvolveAdminUpdater.address;
    }
    console.log(
      `using last  admin updater address ${
        config.adminUpdater || EvolveAdminUpdater.address
      }`
    );
  } catch (e) {
    await deployer.deploy(
      EvolveAdminUpdater,
      web3.utils.toChecksumAddress(addresses[0])
    );
  }
};
