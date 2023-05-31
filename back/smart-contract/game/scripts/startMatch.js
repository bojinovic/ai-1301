const common = require("./common.js");

const main = async () => {
  const { game, clf_commitmentMockup1, clf_revealMockup1 } =
    await common.attach();

  console.log(
    `Staring the match. MATCH_ID = ${(await game.matchCounter()).toNumber()}`
  );

  await game.createMatch(
    clf_commitmentMockup1.address,
    clf_revealMockup1.address
  );

  console.log(
    `Match created. MATCH_ID = ${(await game.matchCounter()).toNumber() - 1}`
  );
};

main().then(() => console.log());
