[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

cd ../smart-contract/game &&

if [ $MODE -eq 2 ] 
then
  npx hardhat run scripts/_stages/revealTick.js --network $NETWORK
fi
if [ $MODE -eq 1 ] 
then
  curl $P1_API_SERVER_URL/1/get-reveal
  curl $P2_API_SERVER_URL/2/get-reveal
  curl $P1_API_SERVER_URL/1/get-reveal
  curl $P2_API_SERVER_URL/2/get-reveal
  sleep 1
  curl $P1_API_SERVER_URL/1/get-reveal
  echo "\n"
  curl $P1_API_SERVER_URL/1/get-reveal
  sleep 1
  curl $P2_API_SERVER_URL/2/get-reveal
  curl $P2_API_SERVER_URL/2/get-reveal
  echo "\n"
fi