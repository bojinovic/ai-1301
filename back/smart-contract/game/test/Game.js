const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const common = require("../scripts/common.js");

describe("Game", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  describe("General Testing", function () {
    it("Should Playout a Move", async function () {
      const { game, owner } = await loadFixture(common.deploy);

      const result = await game.getProgression(0, 0);

      // console.log({ result });

      for (let i = 0; i < 5; ++i) {
        const step = result.moveProgression[i];
        // console.log({ step });
      }

      expect(1).to.equal(1);
    });
    it("Should player 0 fromt team 1 should not move", async function () {
      const { game, owner } = await loadFixture(common.deploy);

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

    it.only("Should teams start in correct positions", async function () {
      const {
        game,
        owner,
        clf_commitmentMockup1,
        clf_commitmentMockup2,
        clf_revealMockup1,
        clf_revealMockup2,
      } = await loadFixture(common.deploy);
      const matchId = 0;
      await game.createMatch(
        clf_commitmentMockup1.address,
        clf_revealMockup1.address
      );

      await game.joinMatch(
        matchId,
        clf_commitmentMockup2.address,
        clf_revealMockup2.address
      );
      console.log({ matchInfo: await game.matchInfo(matchId) });
      seed = Math.floor(Math.random() * 123712361278);
      await clf_commitmentMockup1.updateData(seed);
      await clf_revealMockup1.updateData(seed);
      seed = Math.floor(Math.random() * 123712361278);
      await clf_commitmentMockup2.updateData(seed);
      await clf_revealMockup2.updateData(seed);
      await game.commitmentTick(matchId);
      await game.updateCommitmentInfo(matchId);
      await game.revealTick(matchId);
      await game.updateRevealInfo(matchId);

      const progression = await game.getProgression(0, 0);

      // console.log({ progression });

      console.log(await game.getPlayerPos(0, 0, 0, 0));

      expect(progression[0].teamState[0].xPos[0]).to.equal(512);
    });
    it.only("Should Play With Chainlink Mockups", async function () {
      const {
        game,
        owner,
        clf_commitmentMockup1,
        clf_commitmentMockup2,
        clf_revealMockup1,
        clf_revealMockup2,
      } = await loadFixture(common.deploy);

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
      // await game.completeInitialization(matchId);

      let seed;
      for (let i = 0; i < 5; i++) {
        console.log({ matchInfo: await game.matchInfo(matchId) });
        seed = Math.floor(Math.random() * 123712361278);
        await clf_commitmentMockup1.updateData(seed);
        await clf_revealMockup1.updateData(seed);
        seed = Math.floor(Math.random() * 123712361278);
        await clf_commitmentMockup2.updateData(seed);
        await clf_revealMockup2.updateData(seed);
        await game.commitmentTick(matchId);
        await game.updateCommitmentInfo(matchId);
        await game.revealTick(matchId);
        await game.updateRevealInfo(matchId);

        await game.stateUpdate(matchId);

        const progression = await game.getProgression(matchId, 0);

        console.log({ qwe: progression[0].teamState[0] });

        // const seed1 = Math.floor(Math.random() * 1234567);
        // const seed2 = Math.floor(Math.random() * 1234567);

        // clf_commitmentMockup1.updateData(seed1);
        // clf_commitmentMockup2.updateData(seed2);
        // clf_revealMockup1.updateData(seed1);
        // clf_revealMockup2.updateData(seed2);

        // const move = await game.matchProgression(0, i);
        // const commitments = await game.commitments(0, i);
        // const reveals = await game.reveals(0, i);
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
