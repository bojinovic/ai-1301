[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

export TEAM_ID=1

cd ../smart-contract/game && npx hardhat run scripts/startMatch.js --network $NETWORK

cd ../../api-server/ && node index.js