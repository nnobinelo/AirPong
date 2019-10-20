class Puck {

  PVector pos;
  PVector vel = new PVector();
  float r = 20;
  float speed = 5;
  boolean dead = false;
  float rebound = 6;
  color c = 0;
  float reboundScale = 0.1;

  Puck() {
    pos = new PVector(width / 2, height / 2);

    show();

    new java.util.Timer().schedule(new java.util.TimerTask() {
      @Override
        public void run() {
        randomVel();
      }
    }
    , 1000);
  }

  void show() {
    fill(c);
    noStroke();
    ellipse(pos.x, pos.y, r, r);
  }

  void update() {
    pos.x+=vel.x;
    pos.y+=vel.y;

    if (pos.x < 0 - r ) {
      dead = true;
      p2Score++;
    }
    if (pos.x > width + r) {
      dead = true;
      p1Score++;
    }

    // CHECKING PADDLE 1
    if (pos.x < pad1X + sw/2 + r/2) {
      if (pos.x < pad1X - sw) {
        return;
      }
      if (abs(pad1Y - pos.y) < padLength/2 + sw/2 && vel.x < 0) {
        if (oldPad1Y < pad1Y) {
          vel.y+=rebound * abs(oldPad1Y-pad1Y) * reboundScale;
        } else if (oldPad1Y > pad1Y) {
          vel.y-=rebound * abs(oldPad1Y-pad1Y) * reboundScale;
        }
        vel.x*=-1;
        c = color(pTarg1.x, pTarg1.y, pTarg1.z);
      }
    }

    // CHECKING PADDLE 2
    if (pos.x > pad2X - sw/2 - r/2) {
      if (pos.x > pad2X + sw) {
        return;
      }
      if (abs(pad2Y - pos.y) < padLength/2 && vel.x > 0) {
        if (oldPad2Y < pad2Y) {
          vel.y+=rebound * abs(oldPad2Y-pad2Y) * reboundScale;
        } else if (oldPad2Y > pad2Y) {
          vel.y-=rebound * abs(oldPad2Y-pad2Y) * reboundScale;
        }
        vel.x*=-1;
        c = color(pTarg2.x, pTarg2.y, pTarg2.z);
      }
    }

    // UPPER AND LOWER BOUNDS
    if (pos.y < yCutOff || pos.y > height - yCutOff) {
      vel.y*=-1;
    }
  }

  void randomVel() {
    float theta = random(-QUARTER_PI, QUARTER_PI);
    if (random(1) > 0.5) {
      theta+=PI;
    }

    vel.x = speed * cos(theta);
    vel.y = speed * sin(theta);
  }
}
