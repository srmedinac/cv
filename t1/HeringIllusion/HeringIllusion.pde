PGraphics pg;
PGraphics pgAux;
PImage img;
  
void setup(){
  size (800,400);
  pg = createGraphics (width, height);
}

void draw() {
  int ancho = 20 ;
  background(250);

  noFill();
  stroke( #0066ff );
  strokeWeight(3);

   pg.beginDraw();

   for(int i = 0; i < 4; i++){
    for(int j = 0; j < 40; j++){
      if(i == 0 || i == 2){
      line(400,200,(i*20*10)+200,(j*10));
      }
       if(i == 1 || i == 3){
      line(400,200,(j*10)+200, ((i-1)*200));
      }
  }
  }
   translate(((frameCount/2)%600),0);
   
   for(int i = 0; i < 4 ; i++){
     stroke(#990000);
    rect( 40 + (i*100),0,ancho, 400);
    rect( 0 ,40 + (i*100),400 , ancho);
  }
  
  pg.endDraw();
  
  
  image (pg,0,0);


}
