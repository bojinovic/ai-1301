import React from "react";
import ReactDOM from "react-dom";

import "../style/css/LoadingOverlay.css";

const LoadingOverlay = ({ stateManager }) => {
  return (
    <div className="LoadingOverlay">
      <div className="TextWrapper">
        <h1 className="Text">AI:1301</h1>
        <div class="Spinner">
          <div></div>
          <div></div>
          <div></div>
        </div>
      </div>
    </div>
  );
};

export default LoadingOverlay;
