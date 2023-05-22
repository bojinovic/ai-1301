const apiResponse = await Functions.makeHttpRequest({
  url: `https://4232-2a06-5b00-1502-c400-9c6c-24a3-d23d-5fe7.ngrok-free.app/p1/get-commitment`,
})
const data = apiResponse.data.data.slice(2)
const result = Buffer.from(data, "hex")
return result
