import * as common from "./common";

const META = {};

class Field {
  constructor(p5, w, h) {
    this.p5 = p5;

    this.w = w;
    this.h = h;
  }

  animate() {
    const GOAL_H = 130;
    const GOAL_W = 60;
    this.p5.stroke(0, 0, 0);
    this.p5.line(this.w / 2, 0, this.w / 2, this.h);
    this.p5.fill(255, 255, 255, 0);
    this.p5.ellipse(this.w / 2, this.h / 2, 200);
    this.p5.rect(0, this.h / 2 - GOAL_H / 2, GOAL_W, GOAL_H);
    this.p5.rect(this.w - GOAL_W, this.h / 2 - GOAL_H / 2, GOAL_W, GOAL_H);
    this.p5.rect(0, 0, this.w, this.h);
  }
}

class Team {
  constructor(p5, move, whoami) {
    this.whoami = whoami;
    this.team_positions =
      whoami == 1 ? move.team1_positions : move.team2_positions;
    this.color = whoami == 1 ? "rgba(255, 0, 0, 0.2)" : "rgba(0, 0, 255, 0.2)";
    this.players = this.team_positions.map((pos, idx) => {
      return new Player(p5, pos[0], pos[1], idx, this.color);
    });
    // this.deltas = this.team_positions.map(_ => [0, 0])
  }

  move(move) {
    this.next_team_positions =
      this.whoami == 1 ? move.team1_positions : move.team2_positions;
    this.players.forEach((p, k) => {
      p.move(this.next_team_positions[k][0], this.next_team_positions[k][1]);
    });
  }

  animate() {
    this.players.forEach((p, k) => {
      p.animate();
    });
  }
}

class Player {
  constructor(p5, _x, _y, number, color) {
    this.p5 = p5;

    this.x = _x;
    this.y = _y;
    this.number = number;
    this.color = color;

    this.delta = [0, 0];
    this.steps = 20;
    this.currStep = 0;

    this.moving = false;

    this.animationCounter = 0;
    this.ANIMATION_MAX = 10;
  }

  move(_x, _y) {
    this.delta = [(_x - this.x) / this.steps, (_y - this.y) / this.steps];
    this.nextX = _x;
    this.nextY = _y;
    this.currStep = 0;
    this.moving = true;
  }

  animate() {
    this.currStep = (this.currStep + 1) % this.steps;

    if (this.moving == true && this.currStep != 0) {
      this.x += this.delta[0];
      this.y += this.delta[1];
    } else {
      this.x = this.nextX;
      this.y = this.nextY;
      this.delta = [0, 0];
      this.moving = false;
    }

    if (this.moving == false) {
      this.animationCounter = (this.animationCounter + 1) % this.ANIMATION_MAX;
      this.p5.fill(this.color);
      this.p5.ellipse(this.x, this.y, 10 + this.animationCounter);
    }

    this.p5.fill(this.color);
    this.p5.ellipse(this.x, this.y, 10);
    this.drawArrow();
    this.drawRectInfo();
    this.drawNumber();
  }

  drawArrow() {
    this.p5.stroke(0, 0, 0);
    this.p5.fill(0, 0, 0, 0.2);
    this.p5.line(this.x, this.y, this.nextX, this.nextY);
    this.p5.ellipse(this.nextX, this.nextY, 2);
  }

  drawRectInfo() {
    const RECT_H = 30;
    const RECT_W = 40;
    this.p5.stroke(this.color);
    this.p5.fill("rgba(255,255,255,0.9)");
    this.p5.rect(this.x - RECT_W / 2, this.y - 20 - RECT_H, RECT_W, RECT_H);
    this.p5.triangle(
      this.x,
      this.y - 10,
      this.x - 17,
      this.y - 15,
      this.x + 17,
      this.y - 15
    );
    this.p5.stroke(0, 0, 0);
  }

  drawNumber() {
    this.p5.textSize(32);
    this.p5.fill(this.color);
    this.p5.text(`${this.number}`, this.x - 8, this.y - 23);
  }
}

export { Field, Team, Player };
