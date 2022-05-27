const FactoryEvolve = artifacts.require("./EvolveFactory.sol");
const EvolveStorage = artifacts.require("./EvolveStorage.sol");
const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");
const ERC20 = artifacts.require("./ERC20Mock.sol");
const allConfigs = require("../configs.json");
 
async function decideAddress(configAddress, newAddress) {
  return configAddress
    ? web3.utils.toChecksumAddress(configAddress)
    : await newAddress.deployed().then((result) => result.address);;
}

module.exports = async function (deployer, network, addresses) {
  const config =
    allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

  const tokenAddress = config.token
    ? web3.utils.toChecksumAddress(config.token)
    : ERC20.address;

  const storage = await decideAddress(config.storage, EvolveStorage);

  const bulkSender = await decideAddress(config.bulkSender, EvolveBulkSender);

  const adminUpdater = await decideAddress(
    config.adminUpdater,
    EvolveAdminUpdater
  );
  console.log({
      storage,
      bulkSender,
      tokenAddress,
      adminUpdater
  })
  try {
    FactoryEvolve.address;
    console.log("factory already deployed. skipping deploy...");
  } catch (e) {
    await deployer.deploy(
      FactoryEvolve,
      storage,
      bulkSender,
      tokenAddress,
      adminUpdater
    );
  }
};
