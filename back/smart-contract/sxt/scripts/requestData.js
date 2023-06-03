const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

require("dotenv").config({ path: __dirname + "/./../../../cli/.env" })

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  console.log(process.env.SXT_FUNCTION_CONSUMER_SC_ADRESS)

  const fc = await FC.attach(process.env.SXT_FUNCTION_CONSUMER_SC_ADRESS)

  // const result = await fc.requestData({
  //   gasLimit: 10000000,
  // })

  console.log({ latestResponse: await fc.latestResponse() })

  const dataReady = await fc.dataIsReady()
  const _source = await fc._source()
  const _secrets = await fc._secrets()

  console.log({ dataReady, _source })
  // await fc.requestData({ gasLimit: 3000000 })
}

main().then(() => {
  console.log(`Finished!`)
})
