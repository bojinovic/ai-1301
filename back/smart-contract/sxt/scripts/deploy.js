const { networkConfig } = require("../network-config.js")

const fs = require("fs")

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.deploy(networkConfig.mumbai.functionsOracleProxy)

  console.log(`SxT Function consumer deployed at:`)
  console.log(fc.address)
}

main().then(() => {
  console.log(`Finished!`)
})
