import LoadingOverlay from "../components/LoadingOverlay";
import Game from "../components/Game";
import Event from "../components/Event";
import MatchInfo from "../components/MatchInfo";
import TeamInfo from "../components/TeamInfo";

import "../style/css/Playout.css";

const Playout = ({ stateManager }) => {
  return (
    <div className="Playout">
      <Event stateManager={stateManager}></Event>
      <Game stateManager={stateManager}></Game>
      <MatchInfo></MatchInfo>
      <div className="TeamInfosWrapper">
        <TeamInfo teamId={0} stateManager={stateManager}></TeamInfo>
        <TeamInfo teamId={1} stateManager={stateManager}></TeamInfo>
      </div>
    </div>
  );
};

export default Playout;
