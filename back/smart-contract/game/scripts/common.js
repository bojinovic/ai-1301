const deploy = async () => {
  const [owner] = await ethers.getSigners();

  const Game = await ethers.getContractFactory("GameLogic");
  const game = await Game.deploy();

  const SxTF_Mockup = await ethers.getContractFactory("SxTFunctionConsumer");

  const sxt_mockup = await SxTF_Mockup.deploy();

  await game.setSxT(sxt_mockup.address);

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
    sxt_mockup,
  };
};

const hre = require("hardhat");

const attach = async () => {
  const Game = await hre.ethers.getContractFactory("GameLogic");
  const game = await Game.attach(process.env.GAME_SC_ADDRESS);

  let clf_commitmentMockup1,
    clf_commitmentMockup2,
    clf_revealMockup1,
    clf_revealMockup2,
    sxt_mockup;

  try {
    const SxTF_Mockup = await ethers.getContractFactory("SxTFunctionConsumer");

    sxt_mockup.attach(process.env.SxT_FUNCITON_CONSUMER_SC_ADDRESS);
    const CLF_CommitmentMockup = await ethers.getContractFactory(
      "CommitmentChainlinkFunctionConsumer"
    );
    clf_commitmentMockup1 = await CLF_CommitmentMockup.attach(
      process.env.P1_COMMITMENT_FUNCTION_CONSUMER_SC_ADRESS
    );
    clf_commitmentMockup2 = await CLF_CommitmentMockup.attach(
      process.env.P2_COMMITMENT_FUNCTION_CONSUMER_SC_ADRESS
    );

    const CLF_RevealMockup = await ethers.getContractFactory(
      "RevealChainlinkFunctionConsumer"
    );
    clf_revealMockup1 = await CLF_RevealMockup.attach(
      process.env.P1_REVEAL_FUNCTION_CONSUMER_SC_ADRESS
    );
    clf_revealMockup2 = await CLF_RevealMockup.attach(
      process.env.P2_REVEAL_FUNCTION_CONSUMER_SC_ADRESS
    );
  } catch (err) {
    console.log({ err });
  }

  return {
    game,
    clf_commitmentMockup1,
    clf_commitmentMockup2,
    clf_revealMockup1,
    clf_revealMockup2,
  };
};

module.exports = { deploy, attach };
