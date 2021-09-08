require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
// require("hardhat-watcher");

module.exports = {
  // defaultNetwork: "rinkeby",
  networks: {
    hardhat: {},

    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: ['21ece61053289747b70f0c236f8a76bcd13caf0e25be005502d78bc8290e70d6'],
    },
  },
  watcher: {
    compilation: {
      tasks: ["compile"],
      files: ["./contracts"],
      verbose: true,
    },
    ci: {
      tasks: ["clean", {command: "compile", params: {quiet: true}}, {
        command: "test",
        params: {noCompile: true, testFiles: ["testfile.ts"]}
      }],
    }
  },
  etherscan: {
    apiKey: "VTJJ86VD6ZKVE3WQBMRE1CGP7HUM4Z8KRC"             //testnet BANance
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
}