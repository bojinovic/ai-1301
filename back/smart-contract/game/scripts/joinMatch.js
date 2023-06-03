const common = require("./common.js");

const main = async () => {
  console.log(`Joining the match. MATCH_ID = ${process.env.MATCH_ID}`);

  const { game, clf_commitmentMockup2, clf_revealMockup2 } =
    await common.attach();

  const tx = await game.joinMatch(
    process.env.MATCH_ID,
    clf_commitmentMockup2.address,
    clf_revealMockup2.address,
    { gasLimit: 8000000 }
  );

  await tx.wait(2);

  console.log(`Joined the match.`);
};

main().then(() => console.log());
