import processing.vr.*;
import shapes3d.*;
import damkjer.ocd.*;



int W = 14; // Maze Width 
int H = 15; // Maze Height 
int S = 22;  // Block size 
int g_intDepth; 

int intIndex, x, y; 


/* Default colors */
final color WALL_COLOR = #c43f38;
final color GROUND_COLOR = #89ff93;

/* Textures */
PImage WALL_TEXTURE;
PImage GROUND_TEXTURE;
PShape box;
final float CASE_SIZE = 10;  // size of one case
final float CAMERA_Y = -5;   // camera permanent attitude

int[] Maze  = new int[W*H]; 
PShape cubes;
PShape grid;
PMatrix3D eyeMat = new PMatrix3D();
float tx, tz;
float step = 30;
PVector planeDir = new PVector();
public void setup() {

  fullScreen(STEREO);
  grid = createShape();
  grid.beginShape(LINES);
  //grid.setTexture(GROUND_TEXTURE);
  grid.stroke(0,255,0);
  grid.fill(0,255,0);
  for (int x = -10000; x < +10000; x += 500) {
    grid.vertex(x, +200, +10000);
    grid.vertex(x, +200, -10000);
  }
  for (int z = -10000; z < +10000; z += 500) {
  grid.vertex(+10000, +200, z);
  grid.vertex(-10000, +200, z);
  }
  grid.vertex(-10000, +200,  +10000);
  grid.vertex(-10000,+200,-10000);
  grid.vertex(+10000,+200,-10000);
  grid.vertex(+10000,+200,+10000);
  grid.endShape();
  box = createShape();
  
  
  /*Setup of Maze*/
  for (intIndex = 0; intIndex < (W*H)-1; intIndex++) Maze[intIndex] = 0;
  
  g_intDepth = 0; 
  
  DigMaze(Maze, 1, 1); 
  Maze[1*W+1] = 2; 
  Maze[13*W+13] = 1; 
 
  /* Load textures */
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
  //cubes.setTexture(WALL_TEXTURE);*/
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
  image(GROUND_TEXTURE,0,+200,10000,1);
  shape(grid);
  //shape(cubes);
  drawMaze();
  
  
}


void drawMaze(){
  translate(width / 2, height / 2, 0);
 
  /* Draw map */
  for (int row = 0; row < 14; row++) {
    pushMatrix();
    translate(0, 0, row * CASE_SIZE);
    
    for (int col = 0; col < 15; col++) {
      pushMatrix();
      translate(col * CASE_SIZE, 0, 0);
      
      switch (Maze[row*W+col]) {
        case 0:
          drawWall();
          break;
        default:
          drawGround();
      }

      popMatrix();
    }
    
    popMatrix();
  }
}

/**
 * Draws wall in current case.
 */

void drawWall() {
 final Box box = new Box(this, CASE_SIZE);
 box.drawMode(S3D.TEXTURE);
 box.setTexture(WALL_TEXTURE);
 
 pushMatrix();
 translate(CASE_SIZE / 2, -CASE_SIZE / 2, CASE_SIZE / 2);
 box.draw();
 popMatrix();

 noFill();
}
/**
 * Draws ground in current case.
 */
void drawGround() {
  beginShape(QUADS);
  texture(GROUND_TEXTURE);
  vertex(0, 0, 0, 0, 0);
  vertex(CASE_SIZE, 0, 0, 1, 0);
  vertex(CASE_SIZE, 0, CASE_SIZE, 1, 1);
  vertex(0, 0, CASE_SIZE, 0, 1);
  endShape();
  noFill();
}
void DigMaze(int[] Maze, int x, int y) { 
  int newx; 
  int newy; 
 
  g_intDepth = g_intDepth + 1; 
 
  Maze[y*W+x] = 1; 
 
  int intCount = ValidCount(Maze, x, y); 
 
  while (intCount > 0) { 
    switch (int(random(1)*4)) { 
      case 0: 
        if (ValidMove(Maze, x,y-2) > 0){ 
          Maze[(y-1)*W+x] = 1; 
          DigMaze(Maze, x,y-2); 
        } 
        break; 
      case 1: 
        if (ValidMove(Maze, x+2,y) > 0) { 
          Maze[y*W+x+1] = 1; 
          DigMaze (Maze, x+2,y); 
        } 
        break; 
      case 2: 
        if (ValidMove(Maze, x,y+2) > 0) { 
          Maze[(y+1)*W+x] = 1; 
          DigMaze (Maze, x,y+2); 
        } 
        break; 
      case 3: 
        if (ValidMove(Maze, x-2,y) > 0) { 
          Maze[y*W+x-1] = 1; 
          DigMaze (Maze, x-2,y); 
        } 
        break; 
    } // end switch 
    intCount = ValidCount(Maze, x, y); 
  } // end while 
 
  g_intDepth = g_intDepth - 1; 
} // end DigMaze() 
 
 
public int ValidMove(int[] Maze, int x, int y) { 
  int intResult = 0; 
  if (x>=0 && x<W && y>=0 && y<H 
           && Maze[y*W+x] == 0) intResult = 1; 
  return intResult; 
} 
 
public int ValidCount(int[] Maze, int x, int y) { 
  int intResult = 0; 
 
  intResult += ValidMove(Maze, x,y-2); 
  intResult += ValidMove(Maze, x+2,y); 
  intResult += ValidMove(Maze, x,y+2); 
  intResult += ValidMove(Maze, x-2,y); 
 
  return intResult; 
}
