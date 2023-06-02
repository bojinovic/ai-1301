const common = require("../common.js");

const main = async () => {
  const { game } = await common.attach();

  console.log(`Executing the State Update stage`);

  await game.stateUpdate(process.env.MATCH_ID, { gasLimit: 10000000 - 1 });
};

main().then(() => console.log());
