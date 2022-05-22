const FactoryEvolve = artifacts.require("./EvolveFactory.sol");
const StorageEvolve = artifacts.require("./EvolveStorage.sol");
const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");
const EvolveAccessControll = artifacts.require("./EvolveAccessControll.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");
const ERC20 = artifacts.require("./ERC20Mock.sol");
const allConfigs = require("../configs.json");

module.exports = async function (deployer, network, addresses) {
  try {
    const config =
      allConfigs[network.replace(/-fork$/, "")] || allConfigs.bscTest;

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

    const tokenAddress = config.token
      ? web3.utils.toChecksumAddress(config.token)
      : ERC20.address;

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
    //     /* -------------------------------------------------------------------------- */

    if (!config.adminUpdater)
      await deployer.deploy(EvolveAdminUpdater, addresses[0]);

    const evolveAdminUpdaterInstance = config.adminUpdater
      ? EvolveAdminUpdater.at(web3.utils.toChecksumAddress(config.adminUpdater))
      : await EvolveAdminUpdater.deployed();

    await deployer
      .deploy(EvolveAccessControll, evolveAdminUpdaterInstance.address)
      .then(() => EvolveAccessControll.deployed());

    await deployer
      .deploy(
        FactoryEvolve,
        storageInstance.address,
        bulkSenderInstance.address,
        tokenAddress,
        EvolveAdminUpdater.address
      )
      .then(() => FactoryEvolve.deployed());

    await evolveAdminUpdaterInstance.updateFactory(FactoryEvolve.address);

    // /* -------------------------------------------------------------------------- */
    // /*                      change factory address in storage                     */
    await storageInstance.updateFactoryAddress(FactoryEvolve.address);
    // /* -------------------------------------------------------------------------- */

    // /* -------------------------------------------------------------------------- */
    // /*                    update factory address of bulkSender                    */
    await bulkSenderInstance.updateFactoryAddress(FactoryEvolve.address);
    // /* -------------------------------------------------------------------------- */

    return deployer;
  } catch (e) {
    console.error(e);
  }
};
