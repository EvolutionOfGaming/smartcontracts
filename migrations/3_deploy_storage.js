const EvolveStorage = artifacts.require("./EvolveStorage.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  const config =
    allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

  try {
    if (!config.storage) {
      EvolveStorage.address;
    } 
    
        console.log(
        `using last storage address ${config.storage || EvolveStorage.address}`
      );
      
  } catch (e) {
    await deployer.deploy(EvolveStorage)
  }
};
