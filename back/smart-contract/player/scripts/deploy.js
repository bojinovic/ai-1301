const { networks } = require("../networks.js")

const fs = require("fs")

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  let fc = await FC.deploy(networks.polygonMumbai.functionsOracleProxy)

  console.log(`Commitment Function Consumer deployed at: ${fc.address}`)

  fc = await FC.deploy(networks.polygonMumbai.functionsOracleProxy)

  console.log(`Reveal Function Consumer deployed at: ${fc.address}`)
}

main().then(() => {})
