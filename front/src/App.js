import { useState } from "react";
import { useEffect } from "react";
import Navbar from "./components/Navbar";
import LoadingOverlay from "./components/LoadingOverlay";
import MatchIntroOverlay from "./components/MatchIntroOverlay";
import { updateHistory } from "./interactions/chainData";

import "./style/css/App.css";

import Playout from "./pages/Playout";

import Presentation from "./pages/presentation/Presentation";
const App = () => {
  const [state, setState] = useState({
    loading: true,
    goalWasScored: false,
  });

  useEffect(async () => {
    // await updateHistory({ updateState });
    // setInterval(async () => await updateHistory({ updateState }), 3000);
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

  if (true) {
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
