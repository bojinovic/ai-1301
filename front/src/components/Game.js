import React from "react";
import ReactDOM from "react-dom";
import Sketch from "react-p5";
import * as common from "../utils/common";
import { Field, Team, Ball, superLoop } from "../utils/game";

import "../style/css/Game.css";
import { useEffect } from "react";
import { MATCH_INFO, updateHistory } from "../interactions/chainData";

let field;
let teams;
let ball;

const Game = () => {
  useEffect(async () => {
    await updateHistory();
    setInterval(async () => await updateHistory(), 3000);
  }, []);

  const setup = async (p5, parentRef) => {
    p5.createCanvas(
      common.GAME_SCENE_DIMENSIONS.width,
      common.GAME_SCENE_DIMENSIONS.height
    ).parent(parentRef);

    field = new Field(
      p5,
      common.GAME_SCENE_DIMENSIONS.width,
      common.GAME_SCENE_DIMENSIONS.height,
      50
    );

    while (!MATCH_INFO.history[0]) await common.delay(1000);
    const move = MATCH_INFO.history[0];
    teams = [new Team(p5, move, 0), new Team(p5, move, 1)];
    ball = new Ball(p5, 0, 10);
  };
  const draw = async (p5) => {
    p5.background("rgba(250, 250, 250, 1)");

    field.animate();

    if (teams && teams[0].isInMotion() == false) {
      if (
        MATCH_INFO.currMoveIdx + 1 < MATCH_INFO.history.length &&
        MATCH_INFO.history[MATCH_INFO.currMoveIdx]
      ) {
        // console.log({
        //   shotWasTaken: MATCH_INFO.history[MATCH_INFO.currMoveIdx].shotWasTaken,
        //   goalWasScored:
        //     MATCH_INFO.history[MATCH_INFO.currMoveIdx].goalWasScored,
        // });
        teams.forEach((t) =>
          t.move(MATCH_INFO.history[MATCH_INFO.currMoveIdx])
        );

        ball.move(
          true,
          MATCH_INFO.history[MATCH_INFO.currMoveIdx].ball_position[0],
          MATCH_INFO.history[MATCH_INFO.currMoveIdx].ball_position[1]
        );

        MATCH_INFO.currMoveIdx += 1;
      }
    }

    if (teams) {
      await superLoop(teams[0], teams[1], ball);
    }
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
