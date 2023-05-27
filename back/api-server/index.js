import express from "express";
import { ethers } from "ethers";
import chalk from "chalk";
import terminalImage from "terminal-image";
import got from "got";
import figlet from "figlet";
import * as utils from "./utils/index.js";
import dotenv from "dotenv";
dotenv.config();
const app = express();
const abi = ethers.utils.defaultAbiCoder;

const port = 3000;

const RESPONSE_LENGTH = 6;

const randomData = () => {
  const arr = [];
  for (let i = 0; i < RESPONSE_LENGTH; ++i) {
    arr.push(ethers.BigNumber.from(Math.floor(Math.random() * 255)));
  }
  return arr;
};

let currData = randomData();
let currEncodedData = abi.encode(["uint256[6]"], [currData]);

app.get("/p1/run-inference", async (req, res) => {
  return utils.runInference();
});

app.get("/p1/generate-random-data", async (req, res) => {
  currData = randomData();
  currEncodedData = abi.encode(["uint256[6]"], [currData]);
  return res.json({ data: currData, encoded: currEncodedData });
});
app.get("/p1/get-commitment", async (req, res) => {
  const data = abi.encode(
    ["bytes32"],
    [ethers.utils.keccak256(currEncodedData)]
  );
  return res.json({ data });
});

app.get("/p1/get-reveal", async (req, res) => {
  return res.json({ data: currEncodedData });
});

app.listen(port, async () => {
  const delay = (ms) => new Promise((res) => setTimeout(res, ms));
  // const img1 = await got(
  //   "https://freeiconshop.com/wp-content/uploads/edd/key-flat-128x128.png"
  // ).buffer();

  // const img2 = await got(
  //   "https://d1nhio0ox7pgb.cloudfront.net/_img/g_collection_png/standard/128x128/ok.png"
  // ).buffer();
  const fonts = figlet.fontsSync();
  // for (const font of fonts.slice(100)) {
  //   // console.clear();
  //   // let body = img1;
  //   // console.log(await terminalImage.buffer(body, { height: 5 }));

  //

  //   // await delay(2000);
  //   // console.clear();

  //   // body = img2;

  //   // console.log(await terminalImage.buffer(body, { height: 5 }));
  //   console.log(
  //     chalk.red(
  //       figlet.textSync("AI.v1", {
  //         font,
  //         width: 100,
  //         whitespaceBreak: true,
  //       })
  //     )
  //   );
  //   console.log({ font });
  //   //ANSI Shadow | 'Big Chief' | Big Money | 'DOS Rebel'
  //   // await delay(2000);
  //   // console.clear();
  // }

  const strs = [" Calmdogs"];

  let logs = [];

  while (true) {
    for (const str of strs) {
      console.clear();

      console.log("\n");

      console.log(
        chalk.blue(
          figlet.textSync(str, {
            font: "DOS Rebel",
            width: 100,
            whitespaceBreak: true,
          })
        )
      );

      for (let i = 0; i < logs.length && i < 15; ++i) {
        console.log(logs[Math.min(logs.length - 1, 14) - i]);
      }

      await delay(2000);

      logs = [`STR: ${Math.floor(Math.random() * 23456781123)}`, ...logs];
      if (Math.random() > 0.3) {
        logs = [
          `Chosen move: [12, 341, 5116, 2346 , 24124 , 67,356 , 1234 12]`,
          ...logs,
        ];
      }

      if (Math.random() > 0.3) {
        logs = [`Match state has been updated and observed`, ...logs];
      }
    }
  }
});
