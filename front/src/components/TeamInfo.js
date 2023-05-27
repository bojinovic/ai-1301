import { useEffect, useState } from "react";
import { MATCH_INFO } from "../interactions/chainData";
import * as common from "../utils/common";

import "../style/css/TeamInfo.css";
const PLAYER_NAMES = [
  "Milutinovic",
  "Kezman",
  "Zigic",
  "AGAGHJJJJ",
  "Kezman",
  "ASFAS",
  "Milutinovic",
  "Kezman",
  "Zigic",
  "KQWERQTQ",
];

const TeamInfo = ({ teamId }) => {
  const [move, setMove] = useState(null);

  useEffect(async () => {
    while (!move) {
      await common.delay(1000);
      if (MATCH_INFO.history[MATCH_INFO.currMoveIdx]) {
        setMove(MATCH_INFO.history[MATCH_INFO.currMoveIdx]);
        break;
      }
    }

    setInterval(() => setMove(MATCH_INFO.history[MATCH_INFO.currMoveIdx]), 500);
  }, []);

  if (!move) {
    return <div>Loading...</div>;
  }

  return (
    <div className={`TeamInfo Team${teamId + 1}`}>
      <table className="Lignup">
        <tr className="Head">
          <th className="Name">Name</th>
          <th>Speed</th>
          <th>Skill</th>
          <th>Stamina</th>
        </tr>
        {PLAYER_NAMES.map((name, idx) => {
          const playerStats = move.teamState[teamId].playerStats[idx];

          const isPlayerWithTheBall =
            move.teamIdWithTheBall.toNumber() == teamId &&
            move.playerIdWithTheBall.toNumber() == idx;
          return (
            <tr className={isPlayerWithTheBall ? "PlayerWithTheBall" : ""}>
              <td className="Name">{name}</td>
              <td>{playerStats.speed.toNumber()}</td>
              <td>{playerStats.skill.toNumber()}</td>
              <td>{playerStats.stamina.toNumber()}</td>
            </tr>
          );
        })}
      </table>
    </div>
  );
};

export default TeamInfo;
