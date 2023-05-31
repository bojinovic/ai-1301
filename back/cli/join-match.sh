[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

export TEAM_ID=2

cd ../smart-contract/game && npx hardhat run scripts/joinMatch.js --network $NETWORK

cd ../../api-server/ && node index.js