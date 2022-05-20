const FactoryEvolve = artifacts.require("./EvolveFactory.sol");
const StorageEvolve = artifacts.require("./EvolveStorage.sol");
const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const EvolveAccessControll = artifacts.require("./EvolveAccessControll.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  try {
    const config =
      allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

    /* -------------------------------------------------------------------------- */
    /*                           deploy and get storage                           */
    if (!config.storage) await deployer.deploy(StorageEvolve);
    const storageInstance = config.storage
      ? StorageEvolve.at(web3.utils.toChecksumAddress(config.storage))
      : await StorageEvolve.deployed();
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                    deploy or get bulkSender from config                    */
    if (!config.bulkSender) await deployer.deploy(EvolveBulkSender);

    const bulkSenderInstance = config.bulkSender
      ? EvolveBulkSender.at(web3.utils.toChecksumAddress(config.bulkSender))
      : await EvolveBulkSender.deployed();
    console.log("affter setTimeOut");
    //     /* -------------------------------------------------------------------------- */

    if (!config.token)
      // check token address in config
      throw new Error("need token address for deploying factory!");

    const evolveAdminUpdaterInstance = await deployer
      .deploy(EvolveAdminUpdater, addresses[0])
      .then(() => EvolveAdminUpdater.deployed());

    await deployer
      .deploy(EvolveAccessControll, EvolveAdminUpdater.address)
      .then(() => EvolveAccessControll.deployed());

    // deployer.link(EvolveAccessControll, FactoryEvolve);

    await deployer
      .deploy(
        FactoryEvolve,
        storageInstance.address,
        bulkSenderInstance.address,
        web3.utils.toChecksumAddress(config.token),
        EvolveAdminUpdater.address
      )
      .then(() => FactoryEvolve.deployed());

    await evolveAdminUpdaterInstance.updateFactory(FactoryEvolve.address);

    /* -------------------------------------------------------------------------- */
    /*                      change factory address in storage                     */
    await storageInstance.updateFactoryAddress(FactoryEvolve.address);
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                    update factory address of bulkSender                    */
    await bulkSenderInstance.updateFactoryAddress(FactoryEvolve.address);
    /* -------------------------------------------------------------------------- */

    return deployer;
  } catch (e) {
    console.error(e);
  }
};
