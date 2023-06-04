import { useEffect, useState } from "react";
import "../../style/css/Presentation.css";

const PRESENTATION_LENGTH = 16;

const Presentation = ({ stateManager }) => {
  const [state, setState] = useState({ slide: 0 });

  useEffect(() => {
    document.onkeydown = () => updateSlide(state, updateState);
  });

  const updateState = (newState) => {
    setState({ ...state, ...newState });
  };

  if (state.slide === 0) {
    return (
      <div className="Presentation">
        <div className="Intro">
          <h1 className="Logo">AI:1301</h1>
          <h4 className="SubText">Chainlink 2023 Spring Hackathon</h4>
        </div>
      </div>
    );
  } else if (state.slide === 1) {
    return (
      <div className="Presentation">
        <div className="Slide">
          <h2 className="Header">Aim</h2>
          <h3 className="Content Aim">
            Democratize and Incentivize{" "}
            <b>
              <u> Artificial Intelligence (AI)</u>
            </b>{" "}
            development using <br></br> <br></br>
            <b>
              <u>Blockchain</u>
            </b>{" "}
          </h3>
        </div>
      </div>
    );
  } else if (state.slide === 2) {
    return (
      <div className="Presentation">
        <div className="Slide">
          <h2 className="Header">Football</h2>
          <h3 className="Content2">
            <ul>
              <li>
                Enables large scale datasets used to train innovative{" "}
                <b>
                  <u>Machine / Deep Learning (ML/DL) models</u>
                </b>{" "}
                by creating an{" "}
                <b>
                  <u>on-chain game</u>
                </b>{" "}
                of Football
              </li>
              <br></br>
              <li>
                These AI models operate as the brains of a football team that
                compete against each other
              </li>{" "}
              <br></br>
              <li>
                They position individual players and issue commands to pass the
                ball or take a shot at the opposing team's goal
              </li>
            </ul>
          </h3>
          <h3 className="Content3">
            <img className="Image" src="/images/slide-1-img.png"></img>
          </h3>
        </div>
      </div>
    );
  } else if (state.slide === 3) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-1.png",
      undertitle: "Full diagram",
    });
  } else if (state.slide === 4) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-deployment.png",
      undertitle: "Deployment",
    });
  } else if (state.slide === 5) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-start-match.png",
      undertitle: "Starting a match",
    });
  } else if (state.slide === 6) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-join-match.png",
      undertitle: "Joining a match",
    });
  } else if (state.slide === 7) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-advancer.png",
      undertitle: "Advancer",
    });
  } else if (state.slide === 8) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-commitment-stage.png",
      undertitle: "Commitment Stage",
    });
  } else if (state.slide === 9) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-reveal-stage.png",
      undertitle: "Reveal Stage",
    });
  } else if (state.slide === 10) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-state-update-stage.png",
      undertitle: "State Update Stage",
    });
  } else if (state.slide === 11) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-monitoring.png",
      undertitle: "Monitoring",
    });
  } else if (state.slide === 12) {
    return repeatedSlide({
      imgSrc: "/images/AI-1301-flow-disputer.png",
      undertitle: "Disputer",
    });
  } else if (state.slide === 13) {
    return (
      <div className="Presentation">
        <div className="Intro">
          <h1 className="Logo">DEMO</h1>
        </div>
      </div>
    );
  } else if (state.slide === 14) {
    return (
      <div className="Presentation">
        <div className="Slide">
          <h2 className="Header">Upgrades</h2>
          <h3 className="Content2">
            <div className="Container">
              <ul>
                <li>
                  {"  "}
                  <b>
                    <u>Multi-agent game modes</u>
                  </b>
                  <ul>
                    <li>Collaborative and Competitive environments</li>
                  </ul>
                </li>{" "}
                <li>
                  {"  "}
                  <b>
                    <u>Parallel matches</u>
                  </b>
                  <ul>
                    <li>Bundle moves for multiple matches</li>
                  </ul>
                </li>{" "}
                <li>
                  {"  "}
                  <b>
                    <u>Monte Carlo simulations</u>
                  </b>
                  <ul>
                    <li>Testing of AI models</li>
                  </ul>
                </li>{" "}
                <li>
                  {"  "}
                  <b>
                    <u>Data APIs</u>
                  </b>
                  <ul>
                    <li>Standarize collected match data</li>
                  </ul>
                </li>{" "}
              </ul>{" "}
            </div>
            <div className="Container">
              <ul>
                <li>
                  {"  "}
                  <b>
                    <u>Dynamically evolving NFTs</u>
                  </b>
                  <ul>
                    <li>Players with non-constant performance statistics</li>
                  </ul>
                </li>{" "}
                <li>
                  {"  "}
                  <b>
                    <u>Tokenomics</u>
                  </b>
                  <ul>
                    <li>Enable Play-to-Earn (P2E) mechanism</li>
                  </ul>
                </li>{" "}
                <li>
                  {"  "}
                  <b>
                    <u>AI infrastructure</u>
                  </b>
                  <ul>
                    <li>Cloud AI model training/deployment</li>
                  </ul>
                </li>{" "}
                <li>
                  {"  "}
                  <b>
                    <u>Tournaments / Leagues</u>
                  </b>
                  <ul>
                    <li>Community evolution</li>
                  </ul>
                </li>{" "}
              </ul>{" "}
            </div>
          </h3>
        </div>
      </div>
    );
  } else if (state.slide === 15) {
    return (
      <div className="Presentation">
        <div className="Intro">
          <h1 className="Logo">AI:1301</h1>
          <h4 className="SubText">Chainlink 2023 Spring Hackathon</h4>
        </div>
      </div>
    );
  }
};

export default Presentation;

const updateSlide = (state, updateState) => {
  const nSlide =
    state.slide + 1 < PRESENTATION_LENGTH ? state.slide + 1 : state.slide;
  updateState({ slide: nSlide });
};

const repeatedSlide = ({ imgSrc, undertitle }) => {
  return (
    <div className="Presentation">
      <div className="Slide">
        <h2 className="Header">Inner Workings</h2>
        <h3 className="Content2">
          <div className="Container">
            <div className="Wrapper">
              In order to achieve this, <div className="Logo">AI:1301</div>{" "}
              uses:
            </div>
            <ul>
              <li>
                <img src="/images/chainlink.png"></img>
                {"  "}
                <b>
                  <u>Chainlink Functions</u>
                </b>
                <ul>
                  <li>to communicate with the AI models</li>
                </ul>
              </li>{" "}
              <li>
                <img src="/images/chainlink.png"></img>
                {"  "}
                <b>
                  <u>Chainlink Verifiable Randomness Function (VRFv2)</u>
                </b>
                <ul>
                  <li>source of randomness </li>
                </ul>
              </li>
              <li>
                <img src="/images/space-and-time.png"></img>
                {"  "}
                <b>
                  <u>Space and Time service</u>
                </b>
                <ul>
                  <li>
                    to monitor the state of a match, and perform the state
                    update{" "}
                  </li>
                </ul>
              </li>
              <li>
                <img src="/images/polygon.png"></img>
                {"  "}
                <b>
                  <u>Polygon (Mumbai) blockchain</u>
                </b>
                <ul>
                  <li>enables all of the above</li>
                </ul>
              </li>
            </ul>
          </div>
          <div className="Container">
            <img className="Flow" src={imgSrc}></img>
            <h1>{undertitle}</h1>
          </div>
        </h3>
      </div>
    </div>
  );
};
