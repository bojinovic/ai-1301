import "../style/css/MatchInfo.css";

const MatchInfo = () => {
  return (
    <div className="MatchInfo">
      <div className="Meta">
        <div className="T T1 T1_Color">
          <h1 className="Name">Wildcats</h1>
          <img className="Crest" src="/images/crestPlaceholder.png"></img>
        </div>
        <div className="Score">
          <h1 className="T T1">1</h1>
          <h1 className="Separator">{` : `}</h1>
          <h1 className="T T2">2</h1>
        </div>
        <div className="T T2 T2_Color">
          <img className="Crest" src="/images/crestPlaceholder.png"></img>
          <h1 className="Name">Calmdogs</h1>
        </div>
      </div>
    </div>
  );
};

export default MatchInfo;
