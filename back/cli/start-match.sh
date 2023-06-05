[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

export TEAM_ID=1

cd ../smart-contract/game

if [ $MODE -eq 2 ] 
then
  npx hardhat run scripts/startMatch.js --network $NETWORK
fi

cd ../../api-server/ && nodemon index.js