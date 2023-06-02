const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")

const FC_ADDRESS = "0xB9F19407e9F5303A5dE8eEBf302dF9Ad2690f19c"
async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(FC_ADDRESS)

  const result = await fc.requestData({
    gasLimit: 700000,
  })

  const dataReady = await fc.dataReady()

  console.log({ result, dataReady })
}

main().then(() => {
  console.log(`Finished!`)
})
