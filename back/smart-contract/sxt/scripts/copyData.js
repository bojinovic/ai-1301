const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

const FC_ADDRESS = "0x1a2de533877a1c4786C85DC93aBFa1B734303D9E"
async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(FC_ADDRESS)

  const dataReady = await fc.dataReady()

  const latestResponse = await fc.latestResponse()

  // const result = await fc.copyData({
  //   gasLimit: 1000000,
  // })

  console.log({ dataReady, latestResponse })
}

main().then(() => {
  console.log(`Finished!`)
})
