import React from "react";
import ReactDOM from "react-dom";
import Sketch from "react-p5";
import * as common from "../utils/common";
import { Field, Team } from "../utils/game";

// import { init } from "../utils/game";
import "../style/css/Game.css";
import { useEffect } from "react";
import { MATCH_INFO, updateHistory } from "../interactions/chainData";

let y = 0;
let direction = "^";
let ellipse;
let field;
let teams;
let flag = false;

const Game = () => {
  useEffect(async () => {
    setInterval(async () => await updateHistory(), 10000);
  }, []);

  const setup = (p5, parentRef) => {
    p5.createCanvas(
      common.GAME_SCENE_DIMENSIONS.width,
      common.GAME_SCENE_DIMENSIONS.height
    ).parent(parentRef);

    field = new Field(
      p5,
      common.GAME_SCENE_DIMENSIONS.width,
      common.GAME_SCENE_DIMENSIONS.height
    );
    const move = MATCH_INFO.history[MATCH_INFO.currMoveIdx];
    teams = [new Team(p5, move, 1), new Team(p5, move, 2)];
  };
  const draw = async (p5) => {
    p5.background("rgba(250, 250, 250, 1)");

    field.animate();

    if (teams && teams[0].players[0].moving == false) {
      if (MATCH_INFO.currMoveIdx + 1 < MATCH_INFO.history.length) {
        teams.forEach((t) =>
          t.move(MATCH_INFO.history[MATCH_INFO.currMoveIdx])
        );
        MATCH_INFO.currMoveIdx += 1;
      }
    }
    if (teams)
      teams.forEach((t) => {
        t.animate();
      });
  };

  useEffect(() => {
    // init();
  }, []);
  return (
    <div className="">
      <Sketch setup={setup} draw={draw}></Sketch>
    </div>
  );
};

export default Game;
