import { execSync } from "child_process";

const modelPath = process.env.AI_MODEL_PATH;

export const runInference = () => {
  const result = execSync(`${modelPath}/run-inference.sh`).toString();

  console.log({ result });
};
