import { useState } from "react";
import { useEffect } from "react";
import Navbar from "./components/Navbar";
import LoadingOverlay from "./components/LoadingOverlay";
import MatchIntroOverlay from "./components/MatchIntroOverlay";
import { updateHistory, MATCH_INFO } from "./interactions/chainData";

import "./style/css/App.css";

import Playout from "./pages/Playout";

import Presentation from "./pages/presentation/Presentation";

const App = () => {
  const [state, setState] = useState({
    move: MATCH_INFO.history[MATCH_INFO.currMoveIdx],
    loading: MATCH_INFO.loaded == false,
    goalWasScored: false,
    matchEnded: MATCH_INFO.ended,
    score: MATCH_INFO.score,
    scoringTeamId: MATCH_INFO.scoringTeamId,
    goalTakerId: MATCH_INFO.goalTakerId,
  });

  useEffect(async () => {
    // await updateHistory({ updateState });
    MATCH_INFO.loaded = true;
    // setInterval(async () => await updateHistory({ updateState }), 13000);
  }, []);

  const updateState = (stateChange) => {
    setState({ ...state, ...stateChange });
  };
  console.log({ loc: window.location.href });

  if (window.location.href == "http://localhost:3000/") {
    return (
      <div className="App">
        <LoadingOverlay stateManager={{ state, updateState }}></LoadingOverlay>
      </div>
    );
  }

  if (window.location.href == "http://localhost:3000/presentation") {
    return (
      <div className="App">
        <Presentation stateManager={{ state, updateState }}></Presentation>
      </div>
    );
  }

  if (state.loading) {
    return (
      <div className="App">
        <MatchIntroOverlay
          stateManager={{ state, updateState }}
        ></MatchIntroOverlay>
      </div>
    );
  }

  return (
    <div className="App">
      <Navbar></Navbar>
      <Playout stateManager={{ state, updateState }}></Playout>
    </div>
  );
};

export default App;
