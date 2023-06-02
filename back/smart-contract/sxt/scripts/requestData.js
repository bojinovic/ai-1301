const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

const FC_ADDRESS = "0xC225Ab379985E3d02B01b68c4c695c2e42e0F639"
async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(FC_ADDRESS)

  // const result = await fc.requestData({
  //   gasLimit: 10000000,
  // })

  console.log({ latestResponse: await fc.latestResponse() })

  const dataReady = await fc.dataReady()

  console.log({ result, dataReady })
}

main().then(() => {
  console.log(`Finished!`)
})
