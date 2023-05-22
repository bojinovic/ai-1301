const express = require("express");
const ethers = require("ethers");

const app = express();
const abi = ethers.utils.defaultAbiCoder;

const port = 3000;

const RESPONSE_LENGTH = 10;

const randomData = () => {
  const arr = [];
  for (let i = 0; i < RESPONSE_LENGTH; ++i) {
    arr.push(ethers.BigNumber.from(Math.floor(Math.random() * 255)));
  }
  return arr;
};

let currData = randomData();
let currEncodedData = abi.encode(["uint8[10]"], [currData]);

app.get("/p1/generate-random-data", async (req, res) => {
  currData = randomData();
  currEncodedData = abi.encode(["uint8[10]"], [currData]);
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

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
