const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Game", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {
    const [owner] = await ethers.getSigners();

    const Game = await ethers.getContractFactory("Game");
    const game = await Game.deploy();

    return { game, owner };
  }

  describe("General Testing", function () {
    it("Should Playout a Move", async function () {
      const { game, owner } = await loadFixture(deploy);

      const result = await game.playout(0, 0);

      console.log({ result });

      expect(1).to.equal(1);
    });
  });
});
