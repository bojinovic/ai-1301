import React, { useEffect } from "react";
import ReactDOM from "react-dom";

import "../style/css/MatchIntroOverlay.css";

const MatchIntroOverlay = ({ stateManager }) => {
  if (stateManager.state.loading) {
    return (
      <div className="MatchIntroOverlay">
        <div className="TextWrapper">
          <h1 className="Text">AI:1301</h1>
          <div className="TeamWrapper">
            <div className="Team">TEAM1</div>
            <div className="Team">TEAM2</div>
          </div>
        </div>
      </div>
    );
  }
};

export default MatchIntroOverlay;
