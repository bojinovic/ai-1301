[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

cd ../smart-contract/game && npx hardhat run scripts/_stages/commitmentTick.js --network $NETWORK

if [ $MODE -eq 1 ] 
then
  curl $P1_API_SERVER_URL/1/get-commitment
  curl $P2_API_SERVER_URL/2/get-commitment
fi