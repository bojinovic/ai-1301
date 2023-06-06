import { execSync } from "child_process";
import { BigNumber } from "ethers";
import fs from "fs";
import { ethers } from "ethers";
import terminalImage from "terminal-image";
import chalk from "chalk";
import figlet from "figlet";

const abi = ethers.utils.defaultAbiCoder;

const modelPath = process.env.AI_MODEL_PATH;

export const runInference = async () => {
  addToLog("\n");
  addToLog(`Running inference for the ./observation.json`);

  execSync(`${modelPath}/run-inference.sh`, { cwd: modelPath }).toString();

  await delay(1000);

  const decision = JSON.parse(
    fs.readFileSync(`${modelPath}/decision.json`).toString()
  );

  addToLog(`Decision has been made: see ./decision.json`);

  return { decision };
};

export const encodeInferenceDecision = async ({ decision }) => {
  addToLog(`Encoding the decision...`);

  const { seed, packedData } = decision;
  const reveal = abi.encode(
    [`uint`, `uint`],
    [BigNumber.from(seed), BigNumber.from(packedData)]
  );

  const commitment = abi.encode(["bytes32"], [ethers.utils.keccak256(reveal)]);

  addToLog(`\tCommitment: ${commitment}`);
  addToLog(`\tReveal: ${reveal}`);

  return { commitment, reveal, decision };
};

const delay = (ms) => new Promise((res) => setTimeout(res, ms));

let logs = [];

export const display = async () => {
  const teamId = process.env.TEAM_ID;
  const fonts = figlet.fontsSync();
  const FONT = "Ansi Shadow";

  while (true) {
    console.clear();
    console.log("\n");
    // console.log("\n");
    if (teamId == 1) {
      const teamLogo = `    ${process.env.TEAM1_NAME}    `;

      // console.log(
      //   chalk.red(
      //     figlet.textSync(teamLogo, {
      //       font: FONT, //| | Big | Priest | Doh |Doom  | Dot Matrix | Double | Epic // Grafitti
      //       width: 100,
      //       whitespaceBreak: true,
      //     })
      //   )
      // );
      // console.log(await terminalImage.file("./images/Wildcats.png"));
    } else {
      const teamLogo = `   ${process.env.TEAM2_NAME}   `;

      // console.log(
      //   chalk.blue(
      //     figlet.textSync(teamLogo, {
      //       font: FONT,
      //       width: 100,
      //       whitespaceBreak: true,
      //     })
      //   )
      // );
    }
    console.log("\tAll Systems are operational");
    // console.log("\n");
    await displayLogs();
    await delay(3000);
  }
};

export const displayLogs = async () => {
  for (let i = 0; i < logs.length && i < 50; ++i) {
    console.log(logs[Math.min(logs.length - 1, 49) - i]);
  }
};

export const addToLog = (str) => {
  logs = [str, ...logs];
};
