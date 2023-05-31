[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

cd ../smart-contract/game && npx hardhat run scripts/_simulation/deploy.js --network $NETWORK