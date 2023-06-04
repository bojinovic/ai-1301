# Intro

- ---------just the logo---------

# Aim

- Democratize and Incentivize Artificial Intelligence (AI) Development using Blockchain technology

# Football

- To enable large scale datasets which will be used to train innovative Machine / Deep Learning (ML/DL) models it creates a completely on-chain game of Football.

- These AI models operate as the brains of a football team which compete against each other by positioning individual players and issuing commands to pass the ball or take a shot at the opposing team's goal.

- ------image--------

# Inner Workings #1

In order to achieve this, AI:1301 uses:

- **Chainlink Functions**
  - to communicate with the AI models
- **Chainlink Verifiable Randomn Function (VRFv2)**
  - source of randomness
- **Space and Time**
  - to monitor the state of a match, and perform the state update
- **Polygon (Mumbai) Ethereum Virtual Machine (EVM) blockchain**
  - supports all of the above

# Inner Workings #2

- ------image--------

---

## Highlight deployment lines

- The initial step that both players need to take is the neccessary infrastructure deployment.

- This includes a set of a smart contracts and a server that will contain:

  - a Monitoring service
  - an AI model
  - and an API service which will be called by Chainlink Decentralized Oracle Network (DON) after the request has been initiated by the player's corresponding contracts

- There are always two contracts per player.
- They act as Function Consumers that enable a commitment-reveal scheme that keeps the game fair.

## Highlight starting a match line

- After the deployment process has been completed, the first player can start a new match by registering the addresses of their contracts with the Game's main contract.

## Highlight joining a match line and VRF

- And the second player can then join the match by the same ypt of information, as well as the desired match ID.

- The second player entering the match triggers a Chainlink VRF request for a random seed that will determine the players' statistics on both teams.

## Highlight advancer line

- After the randomness has been fullfiled, the Advancer takes the responsability for the progression of a match.

## Highlight Advancer-Game line and all of the lines per stage

- There are three main stages that a match can be in:

  - Commitment
  - Reveal, and a
  - State Update stage

## Hichglight Commitment Stage

- The Commitment stage consists of simultaniously issuing two request for AI models to commit to their next move, and the time needed to get both responses by the Chainlink DON.

## Hichglight Reveal Stage

- After the models have commited, a Reveal stage can be executed in a similar maner. This will shed light on the underlying data needed to make a state update.

## Hichglight State Update Stage

- Finally, entering the State Update stage triggers a request to the Space and Time sevice which will report the next state of a match based on the data provided by the game's server.

## Hichglight Monitor

- During a match, AI models observe its state using the Space and Time service.

## Highlight Disputer line

- If the reported state is wrong, anyone can trigger a dispute which will verify whether the sequence of states is correct since all of the game logic is contained on-chain.

---

# Demo

# Upcoming Upgrades
