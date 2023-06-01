const sqlText = args[0]
const resourceId = args[1]

const response = await Functions.makeHttpRequest({
  url: "https://hackathon.spaceandtime.dev/v1/sql/dql",
  method: "POST",
  timeout: 9000,
  headers: {
    Authorization: `Bearer ${secrets.accessToken}`,
    "Content-Type": "application/json",
  },
  data: { resourceId: resourceId, sqlText: sqlText, biscuits: [secrets.biscuits] },
})
console.log({ response })

const responseData = response.data
const arrayResponse = Object.keys(responseData[0]).map((key) => `${responseData[0][key]}`)

console.log("Full response from SxT API:", response)
console.log("Value we'll send on-chain:", parseInt(arrayResponse[0]))

return Functions.encodeUint256(parseInt(arrayResponse[0]))
