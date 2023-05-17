import * as common from "../utils/common";

const MATCH_INFO = {
  currMoveIdx: 0,
  history: [
    {
      team1_positions: [
        [0, 100],
        [100, 300],
      ],
      team2_positions: [
        [500, 100],
        [500, 300],
      ],
      team_with_ball: 0,
      player_with_ball: 2,
      action: "shoot", // 'pass' | 'none'
    },
  ],
};

const init = ({ matchIdx }) => {
  MATCH_INFO.idx = matchIdx;
};

const updateHistory = async () => {
  const { move } = await getCurrMove();

  // if (MATCH_INFO.currMoveIdx === move.idx) {
  //   return;
  // }

  MATCH_INFO.history.push(move);
};

const getCurrMove = async () => {
  await common.delay(300);

  const move = {
    idx: MATCH_INFO.idx + 1,
    team1_positions: [
      [400 * Math.random(), 400 * Math.random()],
      [400 * Math.random(), 400 * Math.random()],
    ],
    team2_positions: [
      [400 * Math.random(), 200 * Math.random()],
      [400 * Math.random(), 200 * Math.random()],
    ],
    team_with_ball: 0,
    player_with_ball: Math.floor(Math.random() * 2),
    action: "pass", // 'shoot' | 'none' | 'pass'
  };

  return { move };
};

export { init, updateHistory, MATCH_INFO };
