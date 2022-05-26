const StorageEvolve = artifacts.require("./EvolveStorage.sol");

module.exports = async function (deployer, network, addresses) {
  try {
    StorageEvolve.address
    console.log('storage already deployed. skipping deploy...')
  } catch (e) {
    await deployer.deploy(StorageEvolve)
  }
};
