const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

const FC_ADDRESS = "0x1a2de533877a1c4786C85DC93aBFa1B734303D9E"
async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(FC_ADDRESS)

  const result = await fc.requestData({
    gasLimit: 10000000,
  })

  const dataReady = await fc.dataReady()

  console.log({ result, dataReady })
}

main().then(() => {
  console.log(`Finished!`)
})
