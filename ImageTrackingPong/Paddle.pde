class Paddle {

  PVector pos;
  float l = 60;
  color c;
  int sw;
  float smoothing = 0.5;

  Paddle(float x, float l, color c, int sw) {
    pos = new PVector(x, height / 2);
    this.c = c;
    this.sw = sw;
    this.l = l;
  }

  void show() {
    stroke(c);
    strokeWeight(sw);
    line(pos.x, pos.y - l/2, pos.x, pos.y + l/2);
  }

  void update(float y) {
    pos.y = lerp(y, pos.y, smoothing);
  }
}
