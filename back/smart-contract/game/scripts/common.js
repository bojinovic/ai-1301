const deploy = async () => {
  const [owner] = await ethers.getSigners();

  const Game = await ethers.getContractFactory("GameLogic");
  const game = await Game.deploy();

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
  console.log(`\tgame @ ${game.address}`);
  console.log(`\tclf_commitmentMockup1 @ ${clf_commitmentMockup1.address}`);
  console.log(`\tclf_commitmentMockup2 @ ${clf_commitmentMockup2.address}`);
  console.log(`\tclf_revealMockup1 @ ${clf_revealMockup1.address}`);
  console.log(`\tclf_revealtMockup2 @ ${clf_revealMockup2.address}`);

  return {
    game,
    owner,
    clf_commitmentMockup1,
    clf_commitmentMockup2,
    clf_revealMockup1,
    clf_revealMockup2,
  };
};

module.exports = { deploy };
