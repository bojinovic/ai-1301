import Game from "../components/Game";
import MatchInfo from "../components/MatchInfo";
import TeamInfo from "../components/TeamInfo";

import "../style/css/Playout.css";

const Playout = () => {
  return (
    <div className="Playout">
      <Game></Game>
      <MatchInfo></MatchInfo>
      <div className="TeamInfosWrapper">
        <TeamInfo teamId={0}></TeamInfo>
        <TeamInfo teamId={1}></TeamInfo>
      </div>
    </div>
  );
};

export default Playout;
