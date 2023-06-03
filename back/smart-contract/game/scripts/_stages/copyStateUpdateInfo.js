const common = require("../common.js");

const main = async () => {
  const { game } = await common.attach();

  console.log(`Retrievieng State Update...`);

  await game.updateStateUpdateInfo(process.env.MATCH_ID, {
    gasLimit: 1000000 - 1,
  });
};

main().then(() => {});
