import { execSync } from "child_process";
import { BigNumber } from "ethers";
import fs from "fs";
import { ethers } from "ethers";

const abi = ethers.utils.defaultAbiCoder;

const modelPath = process.env.AI_MODEL_PATH;

export const runInference = async () => {
  console.log(
    execSync(`${modelPath}/run-inference.sh`, { cwd: modelPath }).toString()
  );

  const decision = JSON.parse(
    fs.readFileSync(`${modelPath}/decision.json`).toString()
  );

  return { decision };
};

export const encodeInferenceDecision = async ({ decision }) => {
  const { seed, packedData } = decision;
  const reveal = abi.encode(
    [`uint`, `uint`],
    [BigNumber.from(seed), BigNumber.from(packedData)]
  );

  const commitment = abi.encode(["bytes32"], [ethers.utils.keccak256(reveal)]);

  return { commitment, reveal, decision };
};
