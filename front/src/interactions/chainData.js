import { ethers } from "ethers";
import * as common from "../utils/common";
import * as config from "../utils/config";

import GAME_SC_ARTIFACT from "./artifacts/contracts/Game.sol/Game.json";

const httpProvider = new ethers.providers.JsonRpcProvider();
const contracts = {
  game: new ethers.Contract(
    config.SC_ADDRESSES.game,
    GAME_SC_ARTIFACT.abi,
    httpProvider
  ),
};

const MATCH_INFO = {
  currMoveIdx: 0,
  history: [],
};

const init = ({ matchIdx }) => {
  MATCH_INFO.idx = matchIdx;
};

const updateHistory = async () => {
  const { moves } = await getCurrMove();

  moves.forEach((move) => MATCH_INFO.history.push(move));

  console.log({ history: MATCH_INFO.history });

  // if (MATCH_INFO.currMoveIdx === move.idx) {
  //   return;
  // }
};

let counter = 0;
const getCurrMove = async () => {
  const moves = [];

  const result = await contracts.game.playout(0, counter);

  counter = counter < 10 ? counter + 1 : counter;

  const { move, moveProgression } = result;

  console.log({ moveProgression });

  for (let i = 0; i < moveProgression.length; ++i) {
    const moveTemp = moveProgression[i];
    const team1_positions = [];
    const team2_positions = [];

    for (let playerId = 0; playerId < 10; ++playerId) {
      console.log(
        moveTemp.team1_y_positions[playerId],
        moveTemp.team1_y_positions[playerId].toNumber()
      );
      team1_positions.push([
        moveTemp.team1_x_positions[playerId].toNumber(),
        moveTemp.team1_y_positions[playerId].toNumber(),
      ]);
      team2_positions.push([
        moveTemp.team2_x_positions[playerId].toNumber(),
        moveTemp.team2_y_positions[playerId].toNumber(),
      ]);
    }

    const playerWithBallId = move.player_id_with_the_ball.toNumber();
    const ball_position = [
      moveTemp.team1_x_positions[playerWithBallId].toNumber(),
      moveTemp.team1_y_positions[playerWithBallId].toNumber(),
    ];

    console.log({ team1_positions });

    const moveQ = {
      idx: MATCH_INFO.idx + 1,
      team1_positions,
      team2_positions,
      team_with_ball: 0,
      player_with_ball: Math.floor(Math.random() * 2),
      action: "pass", // 'shoot' | 'none' | 'pass',
      ball_position,
    };

    moves.push(moveQ);
  }

  for (let stepId = 0; stepId < move.pass_ball_x_positions.length; ++stepId) {
    const moveTemp = move;
    const team1_positions = [];
    const team2_positions = [];

    for (let playerId = 0; playerId < 10; ++playerId) {
      team1_positions.push([
        moveTemp.team1_x_positions[playerId].toNumber(),
        moveTemp.team1_y_positions[playerId].toNumber(),
      ]);
      team2_positions.push([
        moveTemp.team2_x_positions[playerId].toNumber(),
        moveTemp.team2_y_positions[playerId].toNumber(),
      ]);
    }

    const ball_position = [
      moveTemp.pass_ball_x_positions[stepId].toNumber(),
      moveTemp.pass_ball_y_positions[stepId].toNumber(),
    ];

    const moveQ = {
      idx: MATCH_INFO.idx + 1,
      team1_positions,
      team2_positions,
      team_with_ball: 0,
      player_with_ball: Math.floor(Math.random() * 2),
      action: "pass", // 'shoot' | 'none' | 'pass'
      ball_position,
    };

    moves.push(moveQ);
  }

  return { moves };
};

export { init, updateHistory, MATCH_INFO };
