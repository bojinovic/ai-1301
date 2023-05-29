import React from "react";
import ReactDOM from "react-dom";
import { currentMove } from "../interactions/chainData";
import "../style/css/Event.css";
import { PLAYER_NAMES } from "../utils/config";

const Event = ({ stateManager }) => {
  if (stateManager.state.goalWasScored) {
    return (
      <div className="Event">
        <div className="Text">GOAL WAS SCORED</div>
        <div
          className={
            currentMove().scoringTeamId == 0 ? "Subtext" : "Subtext SubtextT2"
          }
        >
          {`${11 - currentMove().goalTakerId} ${
            PLAYER_NAMES[currentMove().scoringTeamId][currentMove().goalTakerId]
          }
          `}
        </div>
      </div>
    );
  }
};

export default Event;
