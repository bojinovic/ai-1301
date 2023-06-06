[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

cd ../smart-contract/game 

if [ $MODE -eq 1 ] 
then
  curl $P1_API_SERVER_URL/run-inference
  sleep 2
  curl $P2_API_SERVER_URL/run-inference
  sleep 2
fi
if [ $MODE -eq 2 ] 
then
  npx hardhat run scripts/_stages/stateUpdateTick.js --network $NETWORK
fi