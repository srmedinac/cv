int framecount=0;
int swidth=200;
int sheight=200;
float colorcount=0;
float xwalk=0;
float ywalk=0;
float rectsizebase=20;
float rectsize=20;
float innerSquareSize = 7;
Boolean switcher=false;
int row = 0;
float[] sizes = {1, 1};

MovieClip[] allMovieClips = new MovieClip[1500];
int countMovieClips=0;

illusion[] illusions = new illusion[1500];
int countillusions=0;

illusionCirc[] illusionsCirc = new illusionCirc[1500];
int countillusionsCirc=0;

void setup() {
  size(200, 200);
  background(22,22,22);
}

void draw() {
  colorcount++;
  float r=50+(sin(colorcount/30))*50;
  float g=100+(sin(colorcount/71))*70;
  float b=170+(sin(colorcount/41))*40;
  framecount++;
  if (framecount%1==0 && ywalk<sheight) {
    illusion i=new illusion(xwalk, ywalk, rectsize, switcht());
    if (row%2 == 0) {
      illusionCirc iy=new illusionCirc(xwalk, ywalk, rectsize, !switcher);
    }
    xwalk+=rectsize;
    if (xwalk>swidth) {
      //switcht();
      ywalk+=rectsize;
      row++;
      rectsize=rectsizebase*sizes[row%2];
      xwalk=0;
    }
  }
  iterateMovieClips();
}

Boolean switcht() {
  switcher=!switcher;
  return switcher;
}

void iterateMovieClips() {
  for (int i=0; i<allMovieClips.length; i++) {
    if (allMovieClips[i]!=null) {
      allMovieClips[i].mcEnterFrame();
    }
  }
}


void mcircle(float vx, float vy) {
}

class MovieClip {

  public float x=0;
  public float y=0;
  public float width =10;
  public float height = 10;
  public PImage myView;
  public float r=255;
  public float g=255;
  public float b=0;
  public float xscale=20;
  public float yscale=20;

  MovieClip() {
    for (int i=0; i<allMovieClips.length; i++) {
      if (allMovieClips[i]==null) {
        allMovieClips[i]=this;
        countMovieClips+=1;
        break;
      }
    }
  }
  void drawMe() {  
    if (myView==null) {
    } else {
      image(myView, x, y);
    }
  }
  void mcEnterFrame() {
    enterFrame();
    drawMe();
  }
  void enterFrame() {
  }
  boolean hitTest(MovieClip e) {
    return(e.x<x+width && e.x+e.width>x && e.y<y+height && e.y+e.height>y);
  }
  void removeMovieClip() {
    for (int i=0; i<allMovieClips.length; i++) {
      if (allMovieClips[i]==this) {
        //print("found");
        allMovieClips[i]=null;
        countMovieClips-=1;
      }
    }
  }
}


class illusion extends MovieClip {
  float rotator = 0;
  float r1=255, g1=255, b1=0;
  float r2=15, g2=15, b2=143;
  float size;
  int countA = 0;
  int rotationFrames = 50;
  int countAMax = 300;
  Boolean rotating = false;
  Boolean switcher1= false;
  illusion(float x1, float y1, float size1, Boolean sw) {
    switcher1=sw;
    x=x1;
    y=y1;
    size=size1;
    for (int i=0; i<illusions.length; i++) {
      if (illusions[i]==null) {
        illusions[i]=this;
        countillusions+=1;
        break;
      }
    }
  }
  void enterFrame() {
    drawMe();
    if (countA>countAMax) {
      countA = 0;
      rotating=!rotating;
    }
    countA++;
    if (countA == countAMax-rotationFrames+2) {
      rotating=!rotating;
    }
    if (rotating) {
      //rotator+=((Math.PI*3)/rotationFrames);
    }
  }
  void drawMe() {
    pushMatrix();
    translate(x, y);
    rotate(rotator);
    stroke(255*0.38, 255*0.38, 255*0.38);
    if (switcher1) {
      fill(r1, g1, b1);
    } else {
      fill(r2, g2, b2);
    }
    rect(0, 0, size, size);
    popMatrix();
  }
}

class illusionCirc extends MovieClip {
  float rotator = 0;
  float r1=255, g1=255, b1=0;
  float r2=15, g2=15, b2=143;
  float size;
  int countA = 0;
  int rotationFrames = 50;
  int countAMax = 250;
  Boolean moving = false;
  Boolean switcher1= false;
  int movescount = 0;
  illusionCirc(float x1, float y1, float size1, Boolean sw) {
    switcher1=sw;
    x=x1;
    y=y1;
    size=size1;
    for (int i=0; i<illusions.length; i++) {
      if (illusionsCirc[i]==null) {
        illusionsCirc[i]=this;
        countillusionsCirc+=1;
        break;
      }
    }
  }
  void enterFrame() {
    drawMe();
    if (countA>countAMax) {
      countA = 0;
      moving=!moving;
    }
    countA++;
    if (countA == countAMax-rotationFrames+2) {
      moving=!moving;
      movescount++;
    }
    if (moving) {
      switch((movescount-1)%4) {
      case 0:
        x+=((size-2-innerSquareSize+1)/rotationFrames);
        break;
      case 1:
        y+=((size-2-innerSquareSize+1)/rotationFrames);
        break;
      case 2: 
        x-=((size-2-innerSquareSize+1)/rotationFrames);
        break;
      case 3: 
        y-=((size-2-innerSquareSize+1)/rotationFrames);
        break;
      }
    }
  }
  void drawMe() {
    pushMatrix();
    translate(x, y);
    rotate(rotator);
    stroke(255*0.38, 255*0.38, 255*0.38, 0);
    if (switcher1) {
      fill(r1, g1, b1);
    } else {
      fill(r2, g2, b2);
    }
    rect(1, 1, innerSquareSize, innerSquareSize);
    popMatrix();
  }
}
