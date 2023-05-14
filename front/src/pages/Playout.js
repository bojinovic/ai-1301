import Navbar from "../components/Navbar";
import Game from "../components/Game";
import MatchInfo from "../components/MatchInfo";
import TeamInfo from "../components/TeamInfo";

const Playout = () => {
  return (
    <div className="Playout">
      <Navbar></Navbar>
      <Game></Game>
      <MatchInfo></MatchInfo>
      <div className="TeamInfosWrapper">
        <TeamInfo></TeamInfo>
        <TeamInfo></TeamInfo>
      </div>
    </div>
  );
};

export default Playout;
