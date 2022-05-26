const EvolveBulkSender = artifacts.require("./EvolveBulkSender.sol");

module.exports = async function (deployer, network, addresses) {
  try {
    EvolveBulkSender.address
    console.log('bulk sender already deployed. skipping deploy...')
  } catch (e) {
    await deployer.deploy(EvolveBulkSender)
  }
};
