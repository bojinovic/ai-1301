const common = require("../common.js");

const main = async () => {
  const {
    clf_commitmentMockup1,
    clf_commitmentMockup2,
    clf_revealMockup1,
    clf_revealMockup2,
  } = await common.attach();

  console.log(`Updating the data in the Function Consumers...`);

  let seed = ethers.BigNumber.from(ethers.utils.randomBytes(32));
  await clf_commitmentMockup1.updateData(seed);
  await clf_revealMockup1.updateData(seed);

  seed = ethers.BigNumber.from(ethers.utils.randomBytes(32));
  await clf_commitmentMockup2.updateData(seed);
  await clf_revealMockup2.updateData(seed);

  console.log(`Updated the data in the Function Consumers...`);
};

main().then(() => console.log());
