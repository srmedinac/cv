
int W = 49; // Maze Width 
int H = 49; // Maze Height 
int S = 6;  // Block size 
int g_intDepth; 
 
int[] Maze  = new int[W*H]; 
int intIndex, x, y; 
 
void setup() { 
  size(294,294); 
   
  for (intIndex = 0; intIndex < (W*H)-1; intIndex++) Maze[intIndex] = 0;
 
  g_intDepth = 0; 
 
  DigMaze(Maze, 1, 1); 
  //Maze[1*W+1] = 2; 
  Maze[47*W+48] = 1; 
 
  for (y = 0; y<H; y++ )  
   for (x = 0; x<W; x++ )  
 
      switch( Maze[y*W+x] ) { 
        case 0: noStroke(); fill(0); rect(x*S,y*S,x*S+S,y*S+S); break; 
        case 2: stroke(255); fill(0); rect(x*S,y*S,x*S+S,y*S+S); break; 
        case 1: stroke(255); fill(255); rect(x*S,y*S,x*S+S,y*S+S); break; 
      }; 
 
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
