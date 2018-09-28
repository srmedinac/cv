Pattern pt1, pt2;
float angle = 0.0;
 
void setup(){
  size (550, 550);
  background (255);
}
void draw() {
  background (0); //reestablece la pantalla
  fill (255);
  ellipse(width/2, height/2, width-50, height-50); //circunferencia sobre la que se mueve el patrón
  pt1 = new Pattern(width/2, height/2); // patrón de fondo que está fijo
  pt1.display();
  angle += 0.004; // este valor determina la velocidad de rotación
  translate (width/2, height/2);
  rotate (angle); 
  pt2 = new Pattern(7, 7); //patrón superior que se mueve
    pt2.display();
  }
// =======================================================
 
class Pattern { //patrón
  float p1, p2;
 
  Pattern(float p1_, float p2_) { //fijan el centro del patrón
 
  p1 = p1_;
  p2 = p2_;
 
  }
 
  void display() {
    pushMatrix();
    translate(p1, p2);  // centra el dibujo
      for (int i = 0; i < 180; i++) {  // repeticiones
        rotate(PI/90);    // rotación
        fill (0); //color de los radios
        noStroke (); //sin bordes
        triangle (0, 0, width/2, -2.5, width/2, 2.5); //tamaño de los radios
    }
   popMatrix();
 }
}
