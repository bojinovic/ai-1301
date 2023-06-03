const common = require("./common.js");

const main = async () => {
  const { game, clf_commitmentMockup1, clf_revealMockup1 } =
    await common.attach();

  console.log(
    `Starting the match. MATCH_ID = ${(await game.matchCounter()).toNumber()}`
  );

  const tx = await game.createMatch(
    clf_commitmentMockup1.address,
    clf_revealMockup1.address
  );

  await tx.wait(2);

  console.log(
    `Match started. MATCH_ID = ${(await game.matchCounter()).toNumber() - 1}`
  );
};

main().then(() => console.log());
