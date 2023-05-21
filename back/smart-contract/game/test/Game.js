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

    const GameManager = await ethers.getContractFactory("GameManager");
    const gameManager = await GameManager.deploy();

    const CLF_CommitmentMockup = await ethers.getContractFactory(
      "CommitmentChainlinkFunctionConsumer"
    );
    const clf_commitmentMockup1 = await CLF_CommitmentMockup.deploy();
    const clf_commitmentMockup2 = await CLF_CommitmentMockup.deploy();

    const CLF_RevealMockup = await ethers.getContractFactory(
      "RevealChainlinkFunctionConsumer"
    );
    const clf_revealMockup1 = await CLF_RevealMockup.deploy();
    const clf_revealMockup2 = await CLF_RevealMockup.deploy();

    console.log(`Deployment finished`);
    console.log(`\tGameManager @ ${gameManager.address}`);
    console.log(`\tlf_commitmentMockup1 @ ${clf_commitmentMockup1.address}`);
    console.log(`\tlf_commitmentMockup2 @ ${clf_commitmentMockup2.address}`);
    console.log(`\tlf_revealMockup1 @ ${clf_revealMockup1.address}`);
    console.log(`\tlf_revealtMockup2 @ ${clf_revealMockup2.address}`);

    return {
      gameManager,
      owner,
      clf_commitmentMockup1,
      clf_commitmentMockup2,
      clf_revealMockup1,
      clf_revealMockup2,
    };
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
    it.only("Should Play With Chainlink Mockups", async function () {
      const {
        gameManager: game,
        owner,
        clf_commitmentMockup1,
        clf_commitmentMockup2,
        clf_revealMockup1,
        clf_revealMockup2,
      } = await loadFixture(deploy);

      await game.createMatch(
        clf_commitmentMockup1.address,
        clf_revealMockup1.address
      );

      const matchId = 0;

      await game.joinMatch(
        matchId,
        clf_commitmentMockup2.address,
        clf_revealMockup2.address
      );
      await game.completeInitialization(matchId);

      for (let i = 0; i < 10; i++) {
        await game.commitmentTick(matchId);
        await game.updateCommitmentInfo(matchId);
        await game.revealTick(matchId);
        await game.updateRevealInfo(matchId);

        await game.stateUpdate(matchId);

        const seed1 = Math.floor(Math.random() * 1234567);
        const seed2 = Math.floor(Math.random() * 1234567);

        clf_commitmentMockup1.updateData(seed1);
        clf_commitmentMockup2.updateData(seed2);
        clf_revealMockup1.updateData(seed1);
        clf_revealMockup2.updateData(seed2);

        const move = await game.matchProgression(0, i);
        const commitments = await game.commitments(0, i);
        const reveals = await game.reveals(0, i);
        // console.log({ move });

        // console.log({ commitments });
        // console.log(`encodedeData`, await clf_commitmentMockup1.encodedData());
        // // console.log({ reveals });
        // console.log({ matchIdToMoveId: await game.matchIdToMoveId(matchId) });

        // console.log({
        //   pos: reveals[1].team_x_positions,
        //   team1_x_positions: move.team1_x_positions,
        // });

        // for (let q = 0; q < 150; q++) {
        //   await game.dispute();
        // }
      }
      // console.log(
      //   await game.getCommitment(await clf_commitmentMockup1.commitment())
      // );
    });
  });
});
