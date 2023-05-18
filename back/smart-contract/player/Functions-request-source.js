const apiResponse = await Functions.makeHttpRequest({
  url: `https://random-data-api.com/api/users/random_user`,
  // Get a free API key from https://coinmarketcap.com/api/
  // headers: { "X-CMC_PRO_API_KEY": secrets.apiKey },
})

const uint8_array = new Uint8Array(20)
for (let i = 0; i < 20; ++i) {
  uint8_array[i] = (1301 * i) % 40
}

const result = Buffer.from(uint8_array)

return result
