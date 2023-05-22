const { networks } = require("../networks.js")

const fs = require("fs")

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.deploy(networks.polygonMumbai.functionsOracleProxy)

  console.log({ fc: fc.address })
}

main().then(() => {
  console.log(`Finished!`)
})
