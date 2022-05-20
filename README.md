
## Installation
install [truffle](https://trufflesuite.com/docs/truffle/getting-started/installation/) on you machine.

Use the package manager [Yarn](https://yarnpkg.com/) to install foobar.

```bash
yarn install
```

## Account
create [.secret]() file in the root of the project and import you seed phrase of the owner account into file.

## Config API_KEY

open truffle-config.js file in the root of the project and find variable named KEY and set it equal to you api_key.

```javascript
const Key = "your API Key";
```


## Deploy
for deploy project on a network open truffle-config.js and add network information like bellow.
```javascript
\\\
module.exports = {
  networks: {
    testnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://data-seed-prebsc-1-s1.binance.org:8545`
        ),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
      networkCheckTimeout: 20000, // increase or decrease this depends on your network connection quality.
    },
  },
\\\
```
after setting network information you need to define arguments of contract constructor.
for achieve this open the file [migrations/1_initial_migration.js]()

```javascript
const EvolveFactory = artifacts.require("EvolveFactory");

module.exports = function (deployer) {
  try {
    deployer.deploy(
      EvolveFactory,
      "", // storage address
      "", // bulk sender
      "", // token address
      "" // _adminUpdater
    );
  } catch (e) {
    console.log(e);
  }
};

```
replace the arguments with empty strings.

then start to deploy with truffle command like bellow:
```bash
truffle migrate --network {network_name}
```
or
```
truffle migrate --network testnet
```
## Verify
after deploy get the contract address that's you you in message or you can pick it up from scanners then run command bellow to verify.
```
truffle run verify {contract_name}@{contract_address} --network {network_name}
```
like this
```
truffle run verify EvolveFactory@0xc3d0632f51F14916e88F3A4bDad94821182d2C97 --network testnet
```
## License
[MIT](https://choosealicense.com/licenses/mit/)