import React from "react";
import ReactDOM from "react-dom";
import Sketch from "react-p5";
import * as common from "../utils/common";
import { Field, Player } from "../utils/game";

// import { init } from "../utils/game";
import "../style/css/Game.css";
import { useEffect } from "react";

let y = 0;
let direction = "^";
let ellipse;
let field;
let players;
let flag = false;

const Game = () => {
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
    players = [
      new Player(p5, 50, 100, 5, "rgba(255, 0, 0, 0.5)"),
      new Player(p5, 50, 100, 1, "rgba(255, 0, 0, 0.5)"),
      new Player(p5, 50, 100, 2, "rgba(255, 0, 0, 0.5)"),
      new Player(p5, 50, 100, 3, "rgba(255, 0, 0, 0.5)"),
      new Player(p5, 50, 100, 4, "rgba(255, 0, 0, 0.5)"),
      new Player(p5, 150, 150, 1, "rgba(0, 0, 255, 0.5)"),
      new Player(p5, 250, 350, 2, "rgba(0, 0, 255, 0.5)"),
      new Player(p5, 450, 150, 3, "rgba(0, 0, 255, 0.5)"),
      new Player(p5, 550, 50, 4, "rgba(0, 0, 255, 0.5)"),
      new Player(p5, 110, 850, 5, "rgba(0, 0, 255, 0.5)"),
    ];
  };
  const draw = async (p5) => {
    p5.background("rgba(244, 244, 244, 1)");

    field.animate();

    if (players[0].moving == false) {
      players.forEach((p, k) => {
        p.move(Math.random() * 800, Math.random() * 500);
      });
    }
    players.forEach((p) => {
      p.animate();
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
