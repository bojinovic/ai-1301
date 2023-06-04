import "../style/css/MatchInfo.css";

const MatchInfo = () => {
  return (
    <div className="MatchInfo">
      <div className="Meta">
        <div className="T T1 T1_Color">
          <h1 className="Name">Wildcats</h1>
          <div className="Crest">
            <img className="Img" src="/images/Wildcats.png"></img>
          </div>
        </div>
        <div className="Score">
          <h1 className="T1">1</h1>
          <h1 className="Separator">{` : `}</h1>
          <h1 className="T2">2</h1>
        </div>
        <div className="T T2 T2_Color">
          <div className="Crest T2">
            <img className="Img" src="/images/Calmdogs.png"></img>
          </div>

          <h1 className="Name">Calmdogs</h1>
        </div>
      </div>
    </div>
  );
};

export default MatchInfo;
