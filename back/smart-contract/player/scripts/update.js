const { networks } = require("../networks.js")

const FC_ADDRESS = "0x03461Bf65763B45b41Cb6A200F004989Ab8Fc5d5"
const SUB_ID = 1500

const SRC =
  'const apiResponse = await Functions.makeHttpRequest({url: `https://0dfe-2a06-5b00-1502-c400-bc9a-7df2-4c83-da1a.ngrok-free.app/1/get-commitment`});const data = apiResponse.data.data.slice(2);const result = Buffer.from(data, "hex");return result;'

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(FC_ADDRESS)

  console.log({ SRC })

  await fc.setMetadata(SRC, SUB_ID, 250000)
}

main().then(() => {
  console.log(`Finished!`)
})
