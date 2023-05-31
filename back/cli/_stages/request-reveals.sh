[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

cd ../smart-contract/game && npx hardhat run scripts/_stages/revealTick.js --network $NETWORK

if [ $MODE -eq 1 ] 
then
  curl $P1_API_SERVER_URL/1/get-reveal
  curl $P2_API_SERVER_URL/2/get-reveal
fi