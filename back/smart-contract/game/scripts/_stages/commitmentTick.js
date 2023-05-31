const common = require("../common.js");

const main = async () => {
  const { game } = await common.attach();

  console.log(`Executing the commitment stage`);

  await game.commitmentTick(process.env.MATCH_ID, { gasLimit: 30000000 - 1 });
};

main().then(() => console.log());
