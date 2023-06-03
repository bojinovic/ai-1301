import { useEffect, useState } from "react";
import { MATCH_INFO } from "../interactions/chainData";
import * as common from "../utils/common";
import { PLAYER_NAMES } from "../utils/config";

import "../style/css/TeamInfo.css";

const TeamInfo = ({ teamId, stateManager }) => {
  if (stateManager.state.loading) {
    return <div>Loading...</div>;
  }

  const move = MATCH_INFO.history[MATCH_INFO.currMoveIdx];

  return (
    <div className={`TeamInfo Team${teamId + 1}`}>
      <table className="Lignup">
        <tr className="Head">
          <th>#</th>
          <th className="Name">Player</th>
          <th>Speed</th>
          <th>Skill</th>
          <th>Stamina</th>
        </tr>
        {PLAYER_NAMES[teamId].map((name, idx) => {
          const playerStats = move.teamState[teamId].playerStats[idx];

          const isPlayerWithTheBall =
            move.teamIdWithTheBall.toNumber() == teamId &&
            move.playerIdWithTheBall.toNumber() == idx;

          const playerNumber = 11 - idx;
          console.log({ playerNumber });
          return (
            <tr className={isPlayerWithTheBall ? "PlayerWithTheBall" : ""}>
              <td>{playerNumber}</td>
              <td className="Name">{`${name}`}</td>
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
