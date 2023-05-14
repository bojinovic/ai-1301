import React from "react";
import ReactDOM from "react-dom";
import Sketch from "react-p5";
import * as common from "../utils/common";
import { Player } from "../utils/game";

// import { init } from "../utils/game";
import "../style/css/Game.css";
import { useEffect } from "react";

let y = 0;
let direction = "^";
let ellipse;
let player;

const Game = () => {
  const setup = (p5, parentRef) => {
    p5.createCanvas(
      common.GAME_SCENE_DIMENSIONS.width,
      common.GAME_SCENE_DIMENSIONS.height
    ).parent(parentRef);
    player = new Player(p5, 1, 0);
    console.log({ player });
  };
  const draw = (p5) => {
    console.log({ player });
    p5.background(255, 255, 255);
    {
      y = (y + 1) % 100;

      player.move(0, y);

      player.animate();
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
