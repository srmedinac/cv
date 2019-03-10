import processing.vr.*;
import shapes3d.*;
import damkjer.ocd.*;
PShape cubes;
PShape grid;
PMatrix3D eyeMat = new PMatrix3D();
float tx, tz;
float step = 30;
PVector planeDir = new PVector();
PImage WALL_TEXTURE;
PImage GROUND_TEXTURE;
public void setup() {

  fullScreen(STEREO);
  grid = createShape();
  grid.beginShape(LINES);
  grid.stroke(0,255,0);
 // grid.fill(0,255,0);
  for (int x = -10000; x < +10000; x += 500) {
    grid.vertex(x, +200, +10000);
    grid.vertex(x, +200, -10000);
  }
  for (int z = -10000; z < +10000; z += 500) {
  grid.vertex(+10000, +200, z);
  grid.vertex(-10000, +200, z);
  }
  grid.endShape();
  WALL_TEXTURE = loadImage("brick-wall-texture.jpg");
  GROUND_TEXTURE = loadImage("grass-texture.png");
  textureMode(NORMAL);
  cubes = createShape(GROUP);
   //TEXTURA GRUPO
  float v = 5 * width;
  for (int i = 0; i < 600; i++) {
    float x = random(-v, +v);
    float z = random(-v, +v);
    float s = 300;
    float y = +200 - s/2;
    PShape sh = createShape(BOX, s);
    //sh.setTexture(WALL_TEXTURE); *********************textura******************
    sh.setFill(color(#69fffc));
    //sh.drawMode(S3D.TEXTURE);
   
    sh.translate(x, y, z);
    cubes.addChild(sh);
    
  }
  //cubes.setTexture(WALL_TEXTURE);
}
void calculate() {
  getEyeMatrix(eyeMat);
  if (mousePressed) {
    planeDir.set(eyeMat.m02, 0, eyeMat.m22);
    float d = planeDir.mag();
    if (0 < d) {
      planeDir.mult(1/d);
      tx -= step * planeDir.x;
      tz -= step * planeDir.z;
    }
  }
}
public void draw() {
  background(0);
  translate(width/2, height/2);
  pointLight(50, 50, 200, 0, 1000, 0);
  ambientLight(200, 200, 255, 0, +1, -1);
  translate(tx, 0, tz);
  shape(grid);
  shape(cubes);
  
}
