import { useEffect, useState } from "react";
import "../../style/css/Presentation.css";

const PRESENTATION_LENGTH = 5;

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
          <h3 className="Content">
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
                of Football.
              </li>
              <br></br>
              <li>
                These AI models operate as the brains of a football team that
                compete against each other.
              </li>{" "}
              <br></br>
              <li>
                They position individual players and issue commands to pass the
                ball or take a shot at the opposing team's goal.
              </li>
            </ul>
          </h3>
          <h3 className="Content3">
            <img className="Image" src="/images/slide-1-img.png"></img>
          </h3>
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
