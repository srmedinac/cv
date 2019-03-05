import damkjer.ocd.*;
import shapes3d.*;

/* Default colors */
final color SKY_COLOR = #adccff;
final color WALL_COLOR = #c43f38;
final color GROUND_COLOR = #89ff93;
final color WATER_COLOR = #325fff;
final color TREE_COLOR = #3a8725;

/* Textures */
PImage WALL_TEXTURE;
PImage GROUND_TEXTURE;
PImage WATER_TEXTURE;
PImage TREE_TEXTURE;

final float CASE_SIZE = 10;  // size of one case
final float CAMERA_Y = -5;   // camera permanent attitude

// TODO: remove it later
float ldX, ldY, ldZ = 0;

char[][] map;  // loaded map
Camera camera;

void setup() {
  size(1000, 600, P3D);
  noStroke();
  
  /* Load map from file */
  final String[] lines = loadStrings("default.map");
  
  map = new char[lines.length][lines[0].length()];
  
  for (int row = 0; row < lines.length; row++) {
    for (int col = 0; col < lines[row].length(); col++) {
      map[row][col] = lines[row].charAt(col);
    }
  }
  
  /* Setup camera */
  camera = new Camera(this, 30, CAMERA_Y, 30);
  
  /* Load textures */
  WALL_TEXTURE = loadImage("brick-wall-texture.jpg");
  GROUND_TEXTURE = loadImage("grass-texture.png");
  WATER_TEXTURE = loadImage("water-texture.jpg");
  TREE_TEXTURE = loadImage("tree-texture.jpg");
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
    
    /* If we are in non allowed area (wall, tree or water) cancel the movement */
    if (!isAllowedCase(camera)) {
      camera.jump(position[0], CAMERA_Y, position[2]);  // reset previous position
    }
  }
  
  /* Pose camera */
  camera.feed();
  
  /* Draw map */
  for (int row = 0; row < map.length; row++) {
    pushMatrix();
    translate(0, 0, row * CASE_SIZE);
    
    for (int col = 0; col < map[row].length; col++) {
      pushMatrix();
      translate(col * CASE_SIZE, 0, 0);
      
      switch (map[row][col]) {
        case '#':
          drawWall();
          break;
        case '$':
          drawTree();
          break;
        case '~':
          drawWater();
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
  return map[caseIds[0]][caseIds[1]];
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
 * Draws tree in current case.
 */
void drawTree() {
  drawGround();
  
  final Ellipsoid tree = new Ellipsoid(this, 20, 30);
  tree.setTexture(TREE_TEXTURE);
  tree.drawMode(Shape3D.TEXTURE);
  tree.setRadius(CASE_SIZE / 2);

  pushMatrix();
  translate(CASE_SIZE / 2, -CASE_SIZE / 2, CASE_SIZE / 2);
  tree.draw();
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

/**
 * Draws water in current case.
 */
void drawWater() {
  beginShape(QUADS);
  texture(WATER_TEXTURE);
  vertex(0, 0, 0, 0, 0);
  vertex(CASE_SIZE, 0, 0, 1, 0);
  vertex(CASE_SIZE, 0, CASE_SIZE, 1, 1);
  vertex(0, 0, CASE_SIZE, 0, 1);
  endShape();
  noFill();
}

/**
 * Draws sphere in current case.
 */
void drawSphere() {
  pushMatrix();
  translate(CASE_SIZE / 2, -CASE_SIZE / 2, CASE_SIZE / 2);
  sphere(CASE_SIZE / 2);
  popMatrix();
}
