const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const common = require("../common.js");

const main = async () => {
  await loadFixture(common.deploy);
};

main().then(() => {});
