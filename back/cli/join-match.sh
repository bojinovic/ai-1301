[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

export TEAM_ID=2

cd ../smart-contract/game 

if [ $MODE -eq 2 ] 
then
  npx hardhat run scripts/joinMatch.js --network $NETWORK
fi

cd ../../api-server/ && nodemon index.js