import damkjer.ocd.*;
import shapes3d.*;


int W = 14; // Maze Width 
int H = 15; // Maze Height 
int S = 22;  // Block size 
int g_intDepth; 

int intIndex, x, y; 


/* Default colors */
final color SKY_COLOR = #adccff;
final color WALL_COLOR = #c43f38;
final color GROUND_COLOR = #89ff93;

/* Textures */
PImage WALL_TEXTURE;
PImage GROUND_TEXTURE;

final float CASE_SIZE = 10;  // size of one case
final float CAMERA_Y = -5;   // camera permanent attitude



// TODO: remove it later
float ldX, ldY, ldZ = 0;



int[] Maze  = new int[W*H]; 
Camera camera;



void setup() {
  size(1000, 600, P3D);
  noStroke();
  
  /*Setup of Maze*/
  for (intIndex = 0; intIndex < (W*H)-1; intIndex++) Maze[intIndex] = 0;
  
  g_intDepth = 0; 
  
  DigMaze(Maze, 1, 1); 
  Maze[1*W+1] = 2; 
  Maze[13*W+13] = 1; 
 
  /* Setup camera */
  camera = new Camera(this, 30, CAMERA_Y, 30);
  
  /* Load textures */
  WALL_TEXTURE = loadImage("brick-wall-texture.jpg");
  GROUND_TEXTURE = loadImage("grass-texture.png");
  textureMode(NORMAL);
}

void draw() {
  
  /* Clear & translate */
  background(SKY_COLOR);
  translate(width / 2, height / 2, 0);
  
  // TODO: remove this part after found optimal light direction
  if (keyPressed && key != CODED) {
    switch (key) {
      case 'x':
        ldX -= 0.5;
        break;
      case 'X':
        ldX += 0.5;
        break;
      case 'y':
        ldY -= 0.5;
        break;
      case 'Y':
        ldY += 0.5;
        break;
      case 'z':
        ldZ -= 0.5;
        break;
      case 'Z':
        ldZ += 0.5;
    }
    
    println("ldX=" + ldX + "; ldY=" + ldY + "; ldZ=" + ldZ);
  }
  ambientLight(200, 200, 200);
  directionalLight(255, 255, 255, ldX, ldY, ldZ);
  
  
  /* Navigate camera */
  if (keyPressed && key == CODED) {
    final float[] position = camera.position();
    
    switch (keyCode) {
      case UP:
        onStepForward(camera);
        break;
      case DOWN:
        onStepBackward(camera);
        break;
      case LEFT:
        onStepLeft(camera);
        break;
      case RIGHT:
        onStepRight(camera);
        break;
    }
    
    /* If we are in non allowed area (wall) cancel the movement */
    if (!isAllowedCase(camera)) {
      camera.jump(position[0], CAMERA_Y, position[2]);  // reset previous position
    }
  }
  
  /* Pose camera */
  camera.feed();
  /*
  System.out.println(map.length);
  System.out.println(map[0].length);
  System.out.println(Maze.length);
  */
  
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

// TODO: remake it
void mouseMoved() {
  camera.look(radians(mouseX - pmouseX) / 2.0, radians(mouseY - pmouseY) / 2.0);
}

/**
 * Handler of command to move camera forward.
 *
 * @param camera camera object
 */
void onStepForward(final Camera camera) {
  camera.dolly(-0.5);
  final float[] position = camera.position();
  camera.jump(position[0], CAMERA_Y, position[2]);  // force attitude
}

/**
 * Handler of command to move camera backward.
 *
 * @param camera camera object
 */
void onStepBackward(final Camera camera) {
  camera.dolly(0.5);
  final float[] position = camera.position();
  camera.jump(position[0], CAMERA_Y, position[2]);  // force attitude
}

/**
 * Handler of command to move camera left.
 *
 * @param camera camera object
 */
void onStepLeft(final Camera camera) {
  camera.truck(-0.5);
}

/**
 * Handler of command to move camera right.
 *
 * @param camera camera object
 */
void onStepRight(final Camera camera) {
  camera.truck(0.5);
}

/**
 * Checks if camera is in allowed map case.
 *
 * @param camera camera object
 *
 * @return true - camera is in allowed map case, false - not.
 */
boolean isAllowedCase(final Camera camera) {
  final char caseContent = caseContent(camera);
  return caseContent == ' '
    || caseContent == 'S'
    || caseContent == 'F';
}

/**
 * Returns the content of current case of the map.
 *
 * @param camera camera object
 *
 * @return character of content of the current case of the map
 */
char caseContent(final Camera camera) {
  final int[] caseIds = currentCase(camera);
  return ' ';
  //return Maze[caseIds[0] * W + caseIds[1]];
}

/**
 * Returns the case (row & col) in which camera is currently situated.
 *
 * @param camera camera object
 *
 * @return array with row & col in which camera currently situated
 */
int[] currentCase(final Camera camera) {
  final float[] position = camera.position();
  
  return new int[]{
    (int) (position[2] / CASE_SIZE),
    (int) (position[0] / CASE_SIZE) };
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

void loop() { 
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
