[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

cd ../smart-contract/game

if [ $MODE -eq 2 ] 
then
  npx hardhat run scripts/_stages/copyStateUpdateInfo.js --network $NETWORK
fi