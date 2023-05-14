import * as common from "./common";

const META = {};

class Player {
  constructor(p5, _x, _y) {
    this.x = _x;
    this.y = _y;

    this.delta = [0, 0];
    this.steps = 20;
    this.p5 = p5;
  }

  move(_x, _y) {
    this.delta = [(_x - this.x) / this.steps, (_y - this.y) / this.steps];
    if (isNaN(this.delta[0])) {
      throw Error("err");
    }
  }

  animate() {
    this.x += this.delta[0];
    this.y += this.delta[1];
    this.p5.fill(127, 21);
    this.p5.ellipse(this.x, this.y, 50);
  }
}

export { Player };
