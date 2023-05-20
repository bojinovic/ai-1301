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

      const result = await game.playout(0, 3);

      // console.log({ result });

      for (let i = 0; i < 5; ++i) {
        const step = result.moveProgression[i];
        // console.log({ step });
      }

      expect(1).to.equal(1);
    });
    it("Should player 0 fromt team 1 should not move", async function () {
      const { game, owner } = await loadFixture(deploy);

      const { move: firstMove } = await game.playout(0, 0);

      for (let id = 3; id < 10; ++id) {
        const { move: lastMove, moveProgression: lastMoveProgression } =
          await game.playout(0, id);
        for (let j = 0; j < 5; ++j)
          console.log({ t1X: lastMoveProgression[j].team1_x_positions });
      }

      expect(lastMove.team1_x_positions[0]).to.equal(
        firstMove.team1_x_positions[0]
      );
      expect(lastMove.team1_y_positions[0]).to.equal(
        firstMove.team1_y_positions[0]
      );
    });
  });
});
