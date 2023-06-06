import * as common from "./common";

const FIELD_PADDING = 50;
const FIELD_W = common.GAME_SCENE_DIMENSIONS.width - 2 * FIELD_PADDING;
const FIELD_H = common.GAME_SCENE_DIMENSIONS.height - 2 * FIELD_PADDING;

const GOAL_H = 70;
const GOAL_W = 30;

const FIVE_METER_H = 145;
const FIVE_METER_W = 50;

const SIXTEEN_METER_H = 250;
const SIXTEEN_METER_W = 115;

const PENALTY_DISCTANCE = 85;

export const superLoop = async (team1, team2, ball) => {
  const players = [...team1.players, ...team2.players];

  const f1 = async () => {
    ball.animate();
    players.forEach(async (player) => {
      const hasTheBall = false;

      player.progress(hasTheBall);
    });
    players.forEach(async (player) => {
      // player.drawArrow();
    });
    players.forEach(async (player) => {
      player.drawOhr();
    });

    team1.goalKeeper.drawOhr();
    team2.goalKeeper.drawOhr();
  };

  await f1();
};

const scalePosition = (pos) => {
  return [
    FIELD_PADDING + (pos[0] / 1024) * FIELD_W,
    FIELD_PADDING + (pos[1] / 512) * FIELD_H,
  ];
};

class Field {
  constructor(p5, w, h) {
    this.p5 = p5;

    this.w = w - 2 * FIELD_PADDING;
    this.h = h - 2 * FIELD_PADDING;
    this.padding = FIELD_PADDING;
  }

  animate() {
    this.p5.stroke(0, 0, 0);
    this.p5.line(
      this.padding + this.w / 2,
      this.padding + 0,
      this.padding + this.w / 2,
      this.padding + this.h
    );
    this.p5.fill(255, 255, 255, 0);
    this.p5.ellipse(this.padding + this.w / 2, this.padding + this.h / 2, 200);
    this.p5.ellipse(this.padding + this.w / 2, this.padding + this.h / 2, 40);

    this.p5.ellipse(
      this.padding + PENALTY_DISCTANCE,
      this.padding + this.h / 2,
      5
    );

    this.p5.arc(
      this.padding + SIXTEEN_METER_W,
      this.padding + this.h / 2,
      50,
      100,
      -Math.PI / 2,
      +Math.PI / 2
    );

    this.p5.rect(
      this.padding + 0,
      this.padding + this.h / 2 - SIXTEEN_METER_H / 2,
      SIXTEEN_METER_W,
      SIXTEEN_METER_H
    );

    this.p5.rect(
      this.padding + 0,
      this.padding + this.h / 2 - FIVE_METER_H / 2,
      FIVE_METER_W,
      FIVE_METER_H
    );

    this.p5.rect(
      this.padding + 0 - GOAL_W,
      this.padding + this.h / 2 - GOAL_H / 2,
      GOAL_W,
      GOAL_H
    );

    this.p5.ellipse(
      this.padding + this.w - PENALTY_DISCTANCE,
      this.padding + this.h / 2,
      5
    );

    this.p5.rect(
      this.padding + this.w - SIXTEEN_METER_W,
      this.padding + this.h / 2 - SIXTEEN_METER_H / 2,
      SIXTEEN_METER_W,
      SIXTEEN_METER_H
    );
    this.p5.rect(
      this.padding + this.w - FIVE_METER_W,
      this.padding + this.h / 2 - FIVE_METER_H / 2,
      FIVE_METER_W,
      FIVE_METER_H
    );

    this.p5.rect(
      this.padding + this.w,
      this.padding + this.h / 2 - GOAL_H / 2,
      GOAL_W,
      GOAL_H
    );

    this.p5.arc(
      this.padding + this.w - SIXTEEN_METER_W,
      this.padding + this.h / 2,
      50,
      100,
      +Math.PI / 2,
      -Math.PI / 2
    );

    this.p5.rect(this.padding + 0, this.padding + 0, this.w, this.h);
  }
}

class Team {
  constructor(p5, move, whoami) {
    this.whoami = whoami;
    this.team_positions =
      whoami == 1 ? move.team1_positions : move.team2_positions;
    this.color = whoami == 1 ? "rgba(255, 0, 0, 1)" : "rgba(0, 0, 255, 1)";
    this.players = this.team_positions.map((pos, idx) => {
      pos = scalePosition(pos);
      return new Player(p5, pos[0], pos[1], 11 - idx, this.color);
    });

    const pos = scalePosition(whoami == 1 ? [0, 256] : [1024, 256]);
    this.goalKeeper = new Player(p5, pos[0], pos[1], "1", this.color);

    console.log({ teamPos: this.team_positions });
    // this.deltas = this.team_positions.map(_ => [0, 0])
  }

  move(move) {
    this._move = move;
    this.next_team_positions =
      this.whoami == 1 ? move.team1_positions : move.team2_positions;
    this.players.forEach((p, k) => {
      p.move(
        move.ball_is_being_passed,
        this.next_team_positions[k][0],
        this.next_team_positions[k][1]
      );
    });
  }

  animate() {
    this.players.forEach((p, k) => {
      const hasTheBall =
        this.whoami == this._move.team_with_the_ball.toNumber() &&
        k == this._move.player_id_with_the_ball.toNumber();
      if (hasTheBall) console.log(`${k} has the ball`);
      p.progress(hasTheBall);
    });
    this.players.forEach((p, k) => {
      p.drawArrow();
    });
    this.players.forEach((p, k) => {
      p.drawOhr();
    });

    this.players.forEach((p, k) => {
      // p.drawRectInfo();
    });
    this.players.forEach((p, k) => {
      // p.drawNumber();
    });
    this.goalKeeper.drawOhr();
  }
  isInMotion() {
    return this.players[0].moving;
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
    this.ANIMATION_MAX = 20;
    this.dir = false;
  }

  move(ball_is_being_passed, _x, _y) {
    [_x, _y] = scalePosition([_x, _y]);
    this.delta = [(_x - this.x) / this.steps, (_y - this.y) / this.steps];
    this.nextX = _x;
    this.nextY = _y;
    this.currStep = 0;
    this.moving = true;
    this.ball_is_being_passed = ball_is_being_passed;
  }

  animate() {}

  progress(hasTheBall) {
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
    if (hasTheBall) {
      this.p5.stroke(0, 0, 0);
      this.p5.fill(0, 255, 0);
      this.p5.ellipse(this.x, this.y, 8);
    }
  }

  drawOhr() {
    const OHR_DIAMETER = 15;

    this.p5.fill(this.color);
    this.p5.ellipse(this.x, this.y, OHR_DIAMETER);
    if (this.ball_is_being_passed) {
      if (this.dir) {
        this.animationCounter = Math.min(
          this.animationCounter + 1,
          this.ANIMATION_MAX
        );
        if (this.animationCounter == this.ANIMATION_MAX) {
          this.dir = !this.dir;
        }
      } else {
        this.animationCounter = Math.max(this.animationCounter - 0.5, 0);
        if (this.animationCounter == 0) {
          this.dir = !this.dir;
        }
      }

      this.p5.fill(this.color.replace("1", "0.2"));
      this.p5.ellipse(this.x, this.y, OHR_DIAMETER + 3 + this.animationCounter);
    }

    this.p5.textSize(10);
    this.p5.fill("rgba(255,255,255,1)");
    if (this.number < 10) {
      this.p5.text(`${this.number}`, this.x - 3, this.y + 3);
    } else {
      this.p5.text(`${this.number}`, this.x - 6, this.y + 3);
    }

    this.p5.fill("rgba(255,255,255,1)");
    this.p5.stroke(0, 0, 0);
  }

  drawArrow() {
    this.p5.stroke(0, 0, 0);
    this.p5.fill(0, 0, 0, 0.7);
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

class Ball {
  constructor(p5, x, y) {
    this.p5 = p5;
    this.x = x;
    this.y = y;
    this.nextX = x;
    this.nextY = y;
    this.delta = [0, 0];
    // this.intendedX = x;
    // this.intendedY = y;

    this.steps = 15;
  }

  move(ball_is_being_passed, _x, _y) {
    [_x, _y] = scalePosition([_x, _y]);
    this.delta = [(_x - this.x) / this.steps, (_y - this.y) / this.steps];
    this.nextX = _x;
    this.nextY = _y;
    this.currStep = 0;
    // this.intendedX = i_x;
    // this.intendedY = i_y;
    this.moving = true;
    this.ball_is_being_passed = ball_is_being_passed;
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
    if (this.ball_is_being_passed) {
      this.p5.stroke(0, 0, 0);
      this.p5.fill(0, 0, 0);
      this.p5.ellipse(this.x, this.y, 5);
    }
  }
}

export { Field, Team, Player, Ball };
