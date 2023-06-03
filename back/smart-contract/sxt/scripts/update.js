const { args } = require("../Functions-request-config.js")

require("dotenv").config({ path: __dirname + "/./../../../cli/.env" })

const SRC =
  'const sqlText = args[0]; const resourceId = args[1];  const response = await Functions.makeHttpRequest({   url: "https://hackathon.spaceandtime.dev/v1/sql/dql",   method: "POST",   timeout: 9000,   headers: {     Authorization: `Bearer ' +
  process.env.SXT_ACCESS_TOKEN +
  "`" +
  ',     "Content-Type": "application/json",   },   data: {     resourceId: resourceId,     sqlText: sqlText,     biscuits: [       `EqcBCj0KDnN4dDpjYXBhYmlsaXR5CgpkZGxfY3JlYXRlCgxhaTEzMDEuZGF0YTMYAyIPCg0IgAgSAxiBCBIDGIIIEiQIABIgUMk90nrVJE6FCp8FhM7gFbYBOGxyjg37uqRCKh4SO8kaQMfznr6JtyDqdyCvgu4pxVJYm000T11EJJ_clAJ9puv_y38YbW012zyfcOjbfWDuxuRSogIHanno3ijJeCck4wkiIgogkA_TKv6fefyuHtCt8mVKRXhaa8Lsi4QE-M3Yz8to_R4=`,     ],   }, });  const responseData = response.data; const arrayResponse = Object.keys(responseData[0]).map(   (key) => `${responseData[0][key]}` );  return Functions.encodeUint256(parseInt(arrayResponse[0]));'

async function main() {
  const [owner] = await ethers.getSigners()

  const FC = await ethers.getContractFactory("FunctionsConsumer")
  const fc = await FC.attach(process.env.SXT_FUNCTION_CONSUMER_SC_ADRESS)

  await fc.setMetadata(SRC, "0x", args, process.env.SXT_SUB_ID, 250000, { gasLimit: 3000000 })
}

main().then(() => {})
