const common = require("../common.js");

const main = async () => {
  const { game } = await common.attach();

  console.log(`Retrievieng Commitments...`);

  await game.updateCommitmentInfo(process.env.MATCH_ID, {
    gasLimit: 1000000 - 1,
  });
};

main().then(() => console.log());
