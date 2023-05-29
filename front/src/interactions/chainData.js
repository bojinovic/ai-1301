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

export const currentMove = () => {
  return MATCH_INFO.history[MATCH_INFO.currMoveIdx];
};

const MATCH_INFO = {
  lastStateFetched: -1,
  currMoveIdx: 0,
  history: [],
};

const init = ({ matchIdx }) => {
  MATCH_INFO.idx = matchIdx;
};

let goalWasScored = false;
let fireOnce = true;
const updateHistory = async ({ updateState }) => {
  const { moves } = await getCurrMove();

  let firstMove = true;
  if (moves && moves[0].id > MATCH_INFO.lastStateFetched) {
    moves.forEach((move, idx) => {
      if (goalWasScored && firstMove) {
        for (let i = 0; i < 3; ++i) MATCH_INFO.history.push(move);
        firstMove = false;
      }
      goalWasScored = move.goalWasScored;

      if (idx == moves.length - 1) {
        move.goalTakerId =
          moves[moves.length - 3].playerIdWithTheBall.toNumber();
        move.scoringTeamId =
          moves[moves.length - 3].teamIdWithTheBall.toNumber();
      }

      MATCH_INFO.history.push(move);
    });

    MATCH_INFO.lastStateFetched = moves[0].id;
  }

  if (fireOnce) updateState({ loading: false });
  fireOnce = false;
};

let stateCounter = 0;
let processingStateCounter = -1;
let proccesedState = true;
const getCurrMove = async () => {
  const moves = [];

  const currMatchStateCount = (
    await contracts.game.matchIdToMatchStateId(matchId)
  ).toNumber();

  console.log({ stateCounter, currMatchStateCount });

  if (stateCounter >= currMatchStateCount - 1) {
    return {};
  }

  if (proccesedState == false) {
    return {};
  }

  proccesedState = false;

  // if (await contracts.game.stateShouldBeSkipped(matchId, stateCounter)) {
  //   stateCounter += 1;
  //   proccesedState = true;
  //   return {};
  // }
  const progression = await contracts.game.getProgression(
    matchId,
    stateCounter
  );

  if (stateCounter == 0) {
    // console.log({ progression });
  }

  // console.log({
  //   move,
  //   moveProgression,
  //   M: await contracts.game.matchProgression(0, 3),
  // });

  for (let i = 0; i < progression.length; ++i) {
    const progressionStep = progression[i];
    const team1_positions = [];
    const team2_positions = [];

    if (stateCounter == 0) {
      // console.log({ x: progressionStep.teamState[0].xPos[0].toNumber() });
    }
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

    const moveQ = {
      ...progressionStep,
      idx: MATCH_INFO.idx + 1,
      team1_positions,
      team2_positions,
      ball_position,
      id: stateCounter,
      ball_is_being_passed: i > 5 && i < 12,
    };

    // if (i == 0 && stateCounter == 0) {
    //   console.log({ moveQ });
    //   console.log({ x: progressionStep.teamState[0].xPos[0].toNumber() });
    // }

    moves.push(moveQ);
  }

  // moves.forEach((move) => {
  //   console.log({ ball_position: move.ball_position });
  // });
  stateCounter += 1;

  proccesedState = true;

  return { moves };
};

export { init, updateHistory, MATCH_INFO };
