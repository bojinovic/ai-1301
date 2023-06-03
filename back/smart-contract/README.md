# Setup steps:

Follow these sequence of steps to make a correct arrangement of all contracts' links.

1. **Chainlink Function Consumers:**

- `cd player && npx env-enc set-pw`
  - If its running the first time set up all the needed env-enc variables
- (repeat 2 times)
  - `export TEAM_ID=<1/2>`
  - `npx hardhat run scripts/deploy.js --network polygonMumbai`
    - copy the output's addresses
  - set its addresses (`P<1/2>_COMMITMENT_FUNCTION_CONSUMER_SC_ADRESS` and `P<1/2>_REVEAL_FUNCTION_CONSUMER_SC_ADRESS`) in the `../cli/.env`
  - repeat for both commitment and reveal:
    - `npx hardhat functions-sub-create --network polygonMumbai --amount 5 --contract <P<1/2>_<COMMITMENT/REVEAL>_FUNCTION_CONSUMER_SC_ADRESS>`
  - set the `P<1/2>_<COMMITMENT/REVEAL>_SUB_ID` variables in the .env file
  - `npx hardhat run scripts/update.js --network polygonMumbai`

2. **SxT Function Consumer:**

- `cd sxt && npx env-enc set-pw`

  - If its running the first time set up all the needed env-enc variables

- `npx hardhat run scripts/deploy.js --network mumbai`
  - copy the output's address
- set its address (`SXT_FUNCTION_CONSUMER_SC_ADRESS`) in the `../cli/.env`
- `npx hardhat functions-sub-create --network mumbai --amount 5 --contract <SXT_FUNCTION_CONSUMER_SC_ADRESS>`
- set the `SXT_SUB_ID` variable in the .env file
- check the `./scripts/update.js` for the correct `SRC` content
  - Notice: Access token is valid for only 30 minutes
- `npx hardhat run scripts/update.js --network mumbai`

3. **Game:**

- `cd game && npx env-enc set-pw`
  - If its running the first time set up all the needed env-enc variables
- `npx hardhat run scripts/deploy.js --network mumbai`
  - copy the output's address
- set its address (`GAME_SC_ADDRESS`) in the `../cli/.env`
- send 0.5 LINK to this contract (used for Chainlink's VRF)
- verify contract:
  - `export POLYGON_MUMBAI_RPC_URL="https://polygon-mumbai-bor.publicnode.com" && export POLYGONSCAN_API_KEY="26A2Y9ARFB38U8J6B5RVCASAG2JVCVVF87" && npx hardhat verify <GAME_SC_ADDRESS> --network mumbai`

`npx hardhat functions-sub-fund --subid 1519 --amount 1 --network polygonMumbai`
