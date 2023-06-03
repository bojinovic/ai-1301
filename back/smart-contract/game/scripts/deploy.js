const hre = require("hardhat");

require("dotenv").config({ path: __dirname + "/./../../../cli/.env" });

async function main() {
  const Game = await hre.ethers.getContractFactory("GameLogic");
  const game = await Game.deploy();

  await game.deployed();

  console.log(`Game deployed to ${game.address}`);

  const tx = await game.setSxT(process.env.SXT_FUNCTION_CONSUMER_SC_ADRESS);

  await tx.wait(2);

  console.log(`SxT Function Consumer address set!`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
