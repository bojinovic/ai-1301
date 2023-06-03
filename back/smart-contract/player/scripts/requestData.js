const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

require("dotenv").config({ path: __dirname + "/./../../../cli/.env" })

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(process.env.P1_REVEAL_FUNCTION_CONSUMER_SC_ADRESS)

  // const result = await fc.requestData({
  //   gasLimit: 700000,
  // })

  const dataReady = await fc.dataIsReady()
  const latestResponse = await fc.latestResponse()

  console.log({ dataReady, latestResponse })
}

main().then(() => {
  console.log(`Finished!`)
})
