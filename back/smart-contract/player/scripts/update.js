const { networks } = require("../networks.js")

const fs = require("fs")

const FC_ADDRESS = "0x1a2de533877a1c4786C85DC93aBFa1B734303D9E"
const SUB_ID = 1108
// const SRC = fs
//   .readFileSync("Functions-request-commitment-source.js", { encoding: "utf8", flag: "r" })
//   .replace("\n", ";")

const SRC =
  'const apiResponse = await Functions.makeHttpRequest({url: `https://4232-2a06-5b00-1502-c400-9c6c-24a3-d23d-5fe7.ngrok-free.app/p1/get-commitment`});const data = apiResponse.data.data.slice(2);const result = Buffer.from(data, "hex");return result;'

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(FC_ADDRESS)

  console.log({ SRC })

  await fc.setMetadata(SRC, SUB_ID, 100000)
}

main().then(() => {
  console.log(`Finished!`)
})
