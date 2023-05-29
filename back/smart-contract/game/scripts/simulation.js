const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const common = require("./common.js");

const main = async () => {
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

  const matchId = 0; //(await game.matchCounter()).toNumber() - 1;

  await game.joinMatch(
    matchId,
    clf_commitmentMockup2.address,
    clf_revealMockup2.address
  );

  for (let i = 0; i < 135; ++i) {
    seed = ethers.BigNumber.from(ethers.utils.randomBytes(32));
    await clf_commitmentMockup1.updateData(seed);
    await clf_revealMockup1.updateData(seed);
    seed = ethers.BigNumber.from(ethers.utils.randomBytes(32));
    await clf_commitmentMockup2.updateData(seed);
    await clf_revealMockup2.updateData(seed);
    await game.commitmentTick(matchId, { gasLimit: 30000000 - 1 });
    await game.updateCommitmentInfo(matchId, { gasLimit: 30000000 - 1 });
    await game.revealTick(matchId, { gasLimit: 30000000 - 1 });
    await game.updateRevealInfo(matchId, { gasLimit: 30000000 - 1 });

    // const res = await fetch("http://localhost:3000/0/get-commitment");

    await game.stateUpdate(matchId, { gasLimit: 30000000 - 1 });
    const progression = await game.getProgression(matchId, i);
    console.log({ xPos: progression[0].teamState[0].xPos });
    // console.log({
    //   getTeamStateProgression: await game.getTeamStateProgression(
    //     matchId,
    //     i,
    //     0
    //   ),
    // });
  }
};

main().then(() => console.log(`Simulation finished`));
