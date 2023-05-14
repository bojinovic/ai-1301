import "../style/css/MatchInfo.css";

const MatchInfo = () => {
  return (
    <div className="MatchInfo">
      <div className="Meta">
        <div className="T T1">
          <img
            className="Crest"
            src="/images/TeamCrestPlaceholde.svg.webp"
          ></img>
          <div className="Name">Wildcats</div>
        </div>
        <div className="Separator"> </div>
        <div className="T T2">
          <img
            className="Crest"
            src="/images/TeamCrestPlaceholde.svg.webp"
          ></img>
          <div className="Name">Calmdogs</div>
        </div>
      </div>
      <div className="Score">
        <div className="T T1">1</div>
        <div className="Separator">:</div>
        <div className="T T2">2</div>
      </div>
    </div>
  );
};

export default MatchInfo;
