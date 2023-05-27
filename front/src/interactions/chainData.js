import { ethers } from "ethers";
import * as common from "../utils/common";
import * as config from "../utils/config";

import GAME_SC_ARTIFACT from "./artifacts/contracts/GameLogic.sol/GameLogic.json";

const matchId = 0;

const httpProvider = new ethers.providers.JsonRpcProvider();
const contracts = {
  game: new ethers.Contract(
    config.SC_ADDRESSES.game,
    GAME_SC_ARTIFACT.abi,
    httpProvider
  ),
};

const MATCH_INFO = {
  lastStateFetched: 0,
  currMoveIdx: 0,
  history: [],
};

const init = ({ matchIdx }) => {
  MATCH_INFO.idx = matchIdx;
};

const updateHistory = async () => {
  const { moves } = await getCurrMove();

  if (moves && moves[0].id > MATCH_INFO.lastStateFetched) {
    moves.forEach((move) => MATCH_INFO.history.push(move));
    MATCH_INFO.lastStateFetched = moves[0].id;
  }

  // if (MATCH_INFO.currMoveIdx === move.idx) {
  //   return;
  // }
};

let stateCounter = 0;
const getCurrMove = async () => {
  const moves = [];

  const currMatchStateCount = (
    await contracts.game.matchIdToMatchStateId(matchId)
  ).toNumber();

  if (stateCounter >= currMatchStateCount - 1) {
    return {};
  }

  const progression = await contracts.game.getProgression(
    matchId,
    stateCounter
  );

  // console.log({
  //   move,
  //   moveProgression,
  //   M: await contracts.game.matchProgression(0, 3),
  // });

  for (let i = 0; i < progression.length; ++i) {
    const progressionStep = progression[i];
    const team1_positions = [];
    const team2_positions = [];

    for (let playerId = 0; playerId < 10; ++playerId) {
      team1_positions.push([
        progressionStep.teamState[0].xPos[playerId].toNumber(),
        progressionStep.teamState[0].yPos[playerId].toNumber(),
      ]);
      team2_positions.push([
        progressionStep.teamState[1].xPos[playerId].toNumber(),
        progressionStep.teamState[1].yPos[playerId].toNumber(),
      ]);
    }

    const playerWithBallId = progressionStep.playerIdWithTheBall.toNumber();
    const ball_position = [
      progressionStep.ballXPos.toNumber(),
      progressionStep.ballYPos.toNumber(),
    ];

    console.log({ playerWithBallId });

    const moveQ = {
      ...progressionStep,
      idx: MATCH_INFO.idx + 1,
      team1_positions,
      team2_positions,
      ball_position,
      ball_is_being_passed: false,
      id: stateCounter - 1,
      ball_is_being_passed: i > 6,
    };

    moves.push(moveQ);
  }

  // moves.forEach((move) => {
  //   console.log({ ball_position: move.ball_position });
  // });
  stateCounter += 1;

  return { moves };
};

export { init, updateHistory, MATCH_INFO };
