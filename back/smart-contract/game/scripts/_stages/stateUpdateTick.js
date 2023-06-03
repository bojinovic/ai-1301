const common = require("../common.js");

const main = async () => {
  const { game } = await common.attach();

  console.log(`Executing the State Update stage`);

  await game.stateUpdateTick(process.env.MATCH_ID, { gasLimit: 5000000 - 1 });
};

main().then(() => {});
