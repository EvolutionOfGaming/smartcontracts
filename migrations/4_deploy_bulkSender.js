const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  const config =
    allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

  try {
    if (!config.bulkSender) {
      EvolveBulkSender.address;
    }
    console.log(
      `using last bulk sender address ${
        config.bulkSender || EvolveBulkSender.address
      }`
    );
  } catch (e) {
    await deployer.deploy(EvolveBulkSender);
  }
};
