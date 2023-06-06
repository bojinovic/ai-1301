import React, { useState } from "react";
import ReactDOM from "react-dom";
import { MATCH_INFO, currentMove } from "../interactions/chainData";
import "../style/css/Event.css";
import { PLAYER_NAMES } from "../utils/config";

const Event = ({ stateManager }) => {
  const [matchStarting, setMatchStarting] = useState(true);

  setTimeout(() => {
    setMatchStarting(false);
  }, 3000);

  if (matchStarting) {
    return (
      <div className="Event">
        <table className="Text">
          <tr>
            <td>MATCH IS STARTING</td>
          </tr>
        </table>
      </div>
    );
  }

  if (stateManager.state.goalWasScored) {
    console.log({ s: stateManager.state });
    return (
      <div className="Event">
        <table className="Text">
          <tr>
            <td>GOAL WAS SCORED</td>
          </tr>
        </table>

        <div
          className={
            stateManager.state.scoringTeamId == 0
              ? "Subtext"
              : "Subtext SubtextT2"
          }
        >
          {`${11 - stateManager.state.goalTakerId} ${
            PLAYER_NAMES[stateManager.state.scoringTeamId][
              stateManager.state.goalTakerId
            ]
          }
          `}
        </div>
      </div>
    );
  }

  if (stateManager.state.matchEnded) {
    return (
      <div className="Event">
        <table className="Text">
          <tr>
            <td>MATCH FINISHED</td>
          </tr>
        </table>
      </div>
    );
  }
};

export default Event;
