import processing.video.*;

Capture feed;
color target1;
color target2;
color p1Theme;
color p2Theme;
PVector pTarg1;
PVector pTarg2;
boolean run = false;
int thresh = 40;
float yAvg1 = 0;
float yAvg2 = 0;
float scanY1;
float scanY2;
int scanThresh = 50;
int yCutOff = 25;
int playersRdy = 0;
int pixelsSkipped = 5;

boolean displayColor = false;
color col2Display;

Puck p;
Paddle pad1;
Paddle pad2;
int p1Score = 0;
int p2Score = 0;

float pad1Y;
float pad1X;
float oldPad1Y;

float pad2Y;
float pad2X;
float oldPad2Y;

int sw = 10;
float padLength = 60 + sw + 1;

int gameEnd = 3;

boolean gameOverScreenOn = false;
boolean recalibrate = false;

int clickCount = 0;

void setup() {
  size(864, 480);

  int cameraIdx = 0;
 
  String[] cameras = Capture.list();

  for (int i =0; i<cameras.length; i++) {
  if (cameras[i].contains("Logitech HD Webcam C310,size=864x480,fps=30")) {
    cameraIdx = i;
    break;
  }
  }

  if (cameraIdx == 0) {
  for (int i =0; i<cameras.length; i++) {
    if (cameras[i].contains("size=864x480,fps=30")) {
      cameraIdx = i;
      break;
    }
  }
  }

  if (cameraIdx == 0) {
  for (int i =0; i<cameras.length; i++) {
    if (cameras[i].contains("size=1280x960,fps=30")) {
      cameraIdx = i;
      break;
    }
  }
  }

  //printArray(Capture.list());
 
  feed = new Capture(this, Capture.list()[cameraIdx]);
  feed.start();

  //frameRate(60);

  pad1X = 20;
  pad2X = width - pad1X;

  p = new Puck();

  textSize(30);
  textAlign(CENTER, CENTER);
}

void captureEvent(Capture c) {
  c.read();
}

void draw() {
  background(255);

  image(feed, 0, 0);

  fill(255, 200);
  noStroke();
  rect(-5, -5, width+5, height+5);

  fill(0);
  stroke(0);
  strokeWeight(1);
  line(0, yCutOff, width, yCutOff);
  line(0, height - yCutOff, width, height - yCutOff);
  line(2 * width / 5, 0, 2 * width / 5, height);
  line(3 * width / 5, 0, 3 * width / 5, height);

  if (run) {
  float y1 = player1pos();
  float y2 = player2pos();

  stroke(pTarg1.x, pTarg1.y, pTarg1.z);
  strokeWeight(10);
  pad1.update(y1);
  pad1Y = y1;
  pad1.show();

  stroke(pTarg2.x, pTarg2.y, pTarg2.z);
  strokeWeight(10);
  pad2.update(y2);
  pad2Y = y2;
  pad2.show();

  p.update();
  p.show();

  if (p.dead) {
    p = new Puck();
    if (p1Score == gameEnd) {
      gameOver(true);
    }
    if (p2Score == gameEnd) {
      gameOver(false);
    }
  }

  oldPad1Y = pad1Y;
  oldPad2Y = pad2Y;

  fill(pTarg1.x, pTarg1.y, pTarg1.z, 200);
  text(str(p1Score), width/2-30, 40);
  fill(pTarg2.x, pTarg2.y, pTarg2.z, 200);
  text(str(p2Score), width/2+30, 40);
  } else {
  image(feed, 0, 0);
  }

  if (displayColor) {
  fill(col2Display);
  rect(0, 0, 100, 100);
  }
}

float player1pos() {
  int passed = 0;
  int yTotal = 0;
  noFill();
  strokeWeight(1);

  scanY1 = yAvg1;
  if (yAvg1 > height - scanThresh) {
  scanY1 = height - scanThresh;
  }
  if (yAvg1 < scanThresh) {
  scanY1 = scanThresh;
  }

  for (int y = int(scanY1 - scanThresh); y < int(scanY1 + scanThresh); y+=pixelsSkipped) {
  for (int x = 0; x < 2 * feed.width / 5; x+=pixelsSkipped) {
    int index = x + y * feed.width;
    color value = 0;
    value = feed.pixels[index];
    PVector pVal = new PVector(red(value), green(value), blue(value));
    if (PVector.dist(pVal, pTarg1) < thresh) {
      passed++;
      yTotal += y;
      ellipse(x, y, pixelsSkipped, pixelsSkipped);
    }
  }
  }

  if (passed < 3) {
  for (int y = 0; y < height; y+=pixelsSkipped) {
    for (int x = 0; x < 2 * feed.width / 5; x+=pixelsSkipped) {
      int index = x + y * feed.width;
      color value = 0;
      value = feed.pixels[index];
      PVector pVal = new PVector(red(value), green(value), blue(value));
      if (PVector.dist(pVal, pTarg1) < thresh) {
        passed++;
        yTotal += y;
        ellipse(x, y, pixelsSkipped, pixelsSkipped);
      }
    }
  }
  }

  if (passed != 0) {
  yAvg1 = yTotal / passed;
  }
  return yAvg1;
}

float player2pos() {
  int passed = 0;
  int yTotal = 0;
  scanY2 = yAvg2;
  noFill();
  strokeWeight(1);
  stroke(0);

  if (yAvg2 > height - scanThresh) {
  scanY2 = height - scanThresh;
  }
  if (yAvg2 < scanThresh) {
  scanY2 = scanThresh;
  }
  for (int y = int(scanY2 - scanThresh); y < int(scanY2 + scanThresh); y+=pixelsSkipped) {
  for (int x = 3 * feed.width / 5; x < feed.width; x+=pixelsSkipped) {
    int index = x + y * feed.width;
    color value = 0;
    value = feed.pixels[index];
    PVector pVal = new PVector(red(value), green(value), blue(value));
    if (PVector.dist(pVal, pTarg2) < thresh) {
      passed++;
      yTotal += y;
      ellipse(x, y, pixelsSkipped, pixelsSkipped);
    }
  }
  }

  if (passed < 3) {
  for (int y = 0; y < feed.height; y+=pixelsSkipped) {
    for (int x = 3 * feed.width / 5; x < feed.width; x+=pixelsSkipped) {
      int index = x + y * feed.width;
      color value = 0;
      value = feed.pixels[index];
      PVector pVal = new PVector(red(value), green(value), blue(value));
      if (PVector.dist(pVal, pTarg2) < thresh) {
        passed++;
        yTotal += y;
        ellipse(x, y, pixelsSkipped, pixelsSkipped);
      }
    }
  }
  }

  if (passed != 0) {
  yAvg2 = yTotal / passed;
  }
  return yAvg2;
}

void mousePressed() {
  if (!run)
  {
  if (gameOverScreenOn)
  {   
    background(0);
    loop();

    p1Score = 0;
    p2Score = 0;

    gameOverScreenOn = false;
  } else
  {    
    if (playersRdy==0)
    {
      target1 = get(mouseX, mouseY);
      println("TARGET 1: ACQUIRED");
      pTarg1 = new PVector(red(target1), green(target1), blue(target1));
      pad1 = new Paddle(pad1X, padLength, color(pTarg1.x, pTarg1.y, pTarg1.z), sw);

      col2Display = color(pTarg1.x, pTarg1.y, pTarg1.z);
      displayColor = true;

      new java.util.Timer().schedule(new java.util.TimerTask() {
        @Override
          public void run() {
          displayColor = false;
        }
      }
      , 1000);

      playersRdy++;
    } else if (playersRdy == 1)
    {
      target2 = get(mouseX, mouseY);
      println("TARGET 2: ACQUIRED");
      pTarg2 = new PVector(red(target2), green(target2), blue(target2));
      pad2 = new Paddle(pad2X, padLength, color(pTarg2.x, pTarg2.y, pTarg2.z), sw);

      col2Display = color(pTarg2.x, pTarg2.y, pTarg2.z);
      displayColor = true;

      playersRdy++;

      new java.util.Timer().schedule(new java.util.TimerTask() {
        @Override
          public void run() {
          displayColor = false;
        }
      }
      , 1000);

      run = true;
    }
  }
  }
}

void keyPressed() {
  if (run) {
  run = false;
  playersRdy = 0;
  //recalibrate = true;
  }
}

void gameOver(boolean bool) {
  noLoop();
  background(255);
  textSize(100);
  String s;
  fill(0);
  if (bool == true) {
  s = "Player 1 Wins!";
  } else {
  s = "Player 2 Wins!";
  }
  text("GAME OVER.", width/2, height/2);
  textSize(75);
  text(s, width/2, height/2 + 100);
  textSize(25);
  text("Click anywhere to restart ;)", width/2, height/2 + 170);
  textSize(30);

  restart();
}

void restart() {
  playersRdy = 0;
  gameOverScreenOn = true;
  run = false;
}
