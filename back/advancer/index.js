import * as sxtUtils from "./SxT/utils.js";

const main = async () => {
  const insertRes = await sxtUtils.insert();

  console.log({ insertRes, insertResBody: insertRes.body });

  const retrieveRes = await sxtUtils.retrieve();

  console.log({ retrieveRes });
};

main().then(() => {
  console.log(`Finished`);
});
