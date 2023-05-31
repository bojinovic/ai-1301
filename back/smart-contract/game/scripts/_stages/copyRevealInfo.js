const common = require("../common.js");

const main = async () => {
  const { game } = await common.attach();

  await game.updateRevealInfo(process.env.MATCH_ID, {
    gasLimit: 30000000 - 1,
  });
};

main().then(() => console.log());
