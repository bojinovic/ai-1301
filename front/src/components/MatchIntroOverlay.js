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
            <div className="Team T1">
              <h2>Wildcats</h2>
              <img className="Img" src="/images/Wildcats.png"></img>
            </div>
            <div className="Team T2">
              {" "}
              <h2>Calmdogs</h2>
              <img className="Img" src="/images/Calmdogs.png"></img>
            </div>
          </div>
          <h3>Match starting...</h3>
        </div>
      </div>
    );
  }
};

export default MatchIntroOverlay;
