const EvolveAccessControll = artifacts.require("./EvolveAccessControll.sol");
const EvolveAdminUpdater = artifacts.require("./EvolveAdminUpdater.sol");

module.exports = async function (deployer, network, addresses) {
  try {
    EvolveAccessControll.address
    console.log('access control already deployed. skipping deploy...')
  } catch (e) {
    await deployer.deploy(EvolveAccessControll, EvolveAdminUpdater.address)
  }
};
