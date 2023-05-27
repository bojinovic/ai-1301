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

const port = process.env.API_SERVER_PORT;
const teamId = process.env.TEAM_ID;

const abi = ethers.utils.defaultAbiCoder;

let currDecision = {};

app.get(`/${teamId}/get-commitment`, async (req, res) => {
  const { decision } = await utils.runInference();
  const { commitment, reveal } = await utils.encodeInferenceDecision({
    decision,
  });

  currDecision.commitment = commitment;
  currDecision.reveal = reveal;

  return res.json({ data: commitment });
});

app.get(`/${teamId}/get-reveal`, async (req, res) => {
  return res.json({ data: currDecision.reveal });
});

app.listen(port, async () => {
  console.log(`SERVER on PORT: ${port}`);
});
