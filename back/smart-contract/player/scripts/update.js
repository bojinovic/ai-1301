const { networks } = require("../networks.js")

require("dotenv").config({ path: __dirname + "/./../../../cli/.env" })

const commitmentSrc = () => {
  return (
    "const apiResponse = await Functions.makeHttpRequest({url: `" +
    process.env.ADAPTER_BASE_URL +
    "/" +
    process.env.TEAM_ID +
    '/get-commitment`});const data = apiResponse.data.data.slice(2);const result = Buffer.from(data, "hex");return result;'
  )
}

const revealSrc = () => {
  return (
    "const apiResponse = await Functions.makeHttpRequest({url: `" +
    process.env.ADAPTER_BASE_URL +
    "/" +
    process.env.TEAM_ID +
    '/get-reveal`});const data = apiResponse.data.data.slice(2);const result = Buffer.from(data, "hex");return result;'
  )
}

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")

  if (process.env.TEAM_ID == "1") {
    let fc = await FC.attach(process.env.P1_COMMITMENT_FUNCTION_CONSUMER_SC_ADRESS)

    await fc.setMetadata(commitmentSrc(), process.env.P1_COMMITMENT_SUB_ID, 250000)

    fc = await FC.attach(process.env.P1_REVEAL_FUNCTION_CONSUMER_SC_ADRESS)

    await fc.setMetadata(revealSrc(), process.env.P1_REVEAL_SUB_ID, 250000)
  } else {
    let fc = await FC.attach(process.env.P2_COMMITMENT_FUNCTION_CONSUMER_SC_ADRESS)

    await fc.setMetadata(commitmentSrc(), process.env.P2_COMMITMENT_SUB_ID, 250000)

    fc = await FC.attach(process.env.P2_REVEAL_FUNCTION_CONSUMER_SC_ADRESS)

    await fc.setMetadata(revealSrc(), process.env.P2_REVEAL_SUB_ID, 250000)
  }
}

main().then(() => {
  console.log(`Finished!`)
})
