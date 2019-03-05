// Processing for Android: 
// Create Mobile, Sensor-Aware, and VR Applications Using Processing
// Andres Colubri
// http://p5android-book.andrescolubri.net/

import processing.vr.*;

PShape frame;
PShape cubes;
PShape grid;
PMatrix3D eyeMat = new PMatrix3D();
float tx, ty, tz;
float step = 10;

public void setup() {
  fullScreen(STEREO);
  
  frame = loadShape("dodecahedron.obj");  
  prepare(frame, 500);
  grid = createShape();
  grid.beginShape(LINES);
  grid.stroke(66, 206, 244);
  for (int x = -10000; x < +10000; x += 250) {
    grid.vertex(x, +1000, +10000);
    grid.vertex(x, +1000, -10000);
  }
  for (int z = -10000; z < +10000; z += 250) {
    grid.vertex(+10000, +1000, z);
    grid.vertex(-10000, +1000, z);      
  }  
  grid.endShape();
  cubes = createShape(GROUP);
  float v = 5 * width;
  for (int i = 0; i < 50; i++) {
    float x = random(-v, +v);
    float y = random(-v, +v);
    float z = random(-v, +v);
    float s = random(100, 200);
    PShape sh = createShape(BOX, s);
    sh.setFill(color(#e01111));
    sh.translate(x, y, z);    
    cubes.addChild(sh);
  }  
}

void calculate() {
  getEyeMatrix(eyeMat);
  if (mousePressed) {
    tx -= step * eyeMat.m02;
    ty -= step * eyeMat.m12;
    tz -= step * eyeMat.m22;
  }  
}

public void draw() {
  background(0);
  translate(width/2, height/2);
  lights();
  //directionalLight(200, 200, 200, 0, +1, -1);
  
  translate(tx, ty, tz);
  shape(cubes);

  eye();  
  //shape(frame);
}

void prepare(PShape sh, float s) {
  PVector min = new PVector(+10000, +10000, +10000);
  PVector max = new PVector(-10000, -10000, -10000);  
  PVector v = new PVector();
  for (int i = 0; i < sh.getChildCount(); i++) {
    PShape child = sh.getChild(i);
    for (int j = 0; j < child.getVertexCount(); j++) {
      child.getVertex(j, v);
      min.x = min(min.x, v.x); 
      min.y = min(min.y, v.y); 
      min.z = min(min.z, v.z);
      max.x = max(max.x, v.x); 
      max.y = max(max.y, v.y); 
      max.z = max(max.z, v.z);
    }
  }
  PVector center = PVector.add(max, min).mult(0.5f);
  sh.translate(-center.x, -center.y, -center.z);  
  float maxSize = max(sh.getWidth(), sh.getHeight(), sh.getDepth());
  float factor = s/maxSize;
  sh.scale(factor);  
}
