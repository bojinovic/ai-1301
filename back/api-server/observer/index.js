import { execSync } from "child_process";
import { BigNumber } from "ethers";
import fs from "fs";
import { ethers } from "ethers";

const abi = ethers.utils.defaultAbiCoder;

const modelPath = process.env.AI_MODEL_PATH;

const lastObservedState = {
  id: 0,
};

const delay = async (ms) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

export const monitor = async () => {
  while (true) {
    await delay(Math.floor(Math.random() * 1000));
    const { state } = await getCurrentState();

    if (lastObservedState.id < state.id) {
      fs.writeFileSync(`${modelPath}/observation.json`, JSON.stringify(state));
      lastObservedState.id = state.id;
    }
  }
};
export const getCurrentState = async () => {
  const id = lastObservedState.id + (Math.random() > 0.6 ? 1 : 0);
  const state = {
    id,
    t1Score: 1,
    t2Score: 2,
    teamIdWithTheBall: 0,
    playerIdWithTheBall: 6,
    t1PlayerXPos: [],
    t1PlayerYPos: [],
    t2PlayerXPos: [],
    t2PlayerYPos: [],
  };

  return { state };
};
