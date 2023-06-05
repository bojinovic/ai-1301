import express from "express";
import { ethers } from "ethers";
import chalk from "chalk";

import got from "got";
import figlet from "figlet";
import * as utils from "./utils/index.js";
import * as observer from "./observer/index.js";

import dotenv from "dotenv";
dotenv.config();

const app = express();

const teamId = process.env.TEAM_ID;

const port =
  teamId == 1 ? process.env.P1_API_SERVER_PORT : process.env.P2_API_SERVER_PORT;

let currDecision = {};

app.get(`/run-inference`, async (req, res) => {
  const { decision } = await utils.runInference();
  const { commitment, reveal } = await utils.encodeInferenceDecision({
    decision,
  });

  currDecision.commitment = commitment;
  currDecision.reveal = reveal;
  return res.json({ status: "ok!" });
});

app.get(`/${teamId}/get-commitment`, async (req, res) => {
  utils.addToLog(`[HTTP GET Request] /get-commitment`);

  return res.json({ data: currDecision.commitment });
});

app.get(`/${teamId}/get-reveal`, async (req, res) => {
  utils.addToLog(`[HTTP GET Request] /get-reveal`);

  return res.json({ data: currDecision.reveal });
});

// observer.monitor();

app.listen(port, async () => {
  const { decision } = await utils.runInference();
  const { commitment, reveal } = await utils.encodeInferenceDecision({
    decision,
  });

  currDecision.commitment = commitment;
  currDecision.reveal = reveal;
  console.log(currDecision);

  await utils.display();
});
