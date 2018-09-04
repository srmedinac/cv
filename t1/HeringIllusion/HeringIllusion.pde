PGraphics graph;

void setup(){
  size (800,400);
  graph = createGraphics (width, height);
}
void draw() {
  int strWidth = 15 ;
  background(230);
  noFill();
  stroke( #1647f9 );
  strokeWeight(2);
  graph.beginDraw();
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 40; j++){
      if(i == 0 || i == 2){
      line(400, 200,(i * 20 * 10) + 200,(j * 10));
      }
       if(i == 1 || i == 3){
      line(400, 200,(j * 10) + 200, ( (i - 1) * 200) );
        }
    }  
  }
   translate(((frameCount/2) % 600),0);
   for(int i = 0; i < 4 ; i++){
    stroke(#cc0e0e);
    rect( 40 + (i * 100), 0, strWidth, 400);
    rect( 0 ,40 + (i * 100),400 , strWidth);
  }
  
  graph.endDraw();
  image(graph,0,0);
}
