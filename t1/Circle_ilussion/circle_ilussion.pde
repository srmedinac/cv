int number_loops=0;
float x = 480;
float x1 = 220;
float x2 = 392;
float y2 = 312;
float x3 = 405;
float y3 = 155;
int dir = 1;//0 es ir hacia abajo, 1 es ir hacia arriba
int dir1 = 1;
int dir2 = 1;
int dir3 = 0;
int cliked =0;

void setup(){
  size(640,480);
  frameRate(200);
}

boolean valid_distance(){
  float dist =dist(x,240,x2,y2);
  float dist2 =dist(320,x1,x2,y2);
  if((dist>117.48023)||(dist<97.48023)){
    return false;
  }
  if((dist2>117.48023)||(dist2<97.48023)){
    return false;
  }
  return true;
}



void point1(){
  fill(255,255,255);
  ellipse(x,240,30,30);
  if(x==480.0){
    dir=1;
    number_loops+=1;
  }
  else{
    if(x==160){
      dir=0;
    }  
  }
  if((x>190)&&(x<450) && (dir==1)){
    x=x-1;
  }
  else{
    if((x>190)&&(x<450) && (dir==0)){
      x=x+1;
    }  
  }
  if((((x<=190)&&(x>=160)) || ((x<=480)&&(x>=450))) && (dir==1)){
    x-= 0.5 ;
  }
  else{
    if((((x<=190)&&(x>=160)) || ((x<=480)&&(x>=450))) && (dir==0)){
      x+= 0.5;
    }  
  }
}

void point2(){
  fill(255,255,255);
  ellipse(320,x1,30,30);
  if(x1==400.0){
    dir1=1;
  }
  else{
    if(x1==80){
      dir1=0;
    }  
  }
  if((x1>110)&&(x1<370) && (dir1==1)){
    x1=x1-1;
  }
  else{
    if((x1>110)&&(x1<370) && (dir1==0)){
      x1=x1+1;
    }  
  }
  if((((x1<=110)&&(x1>=80)) || ((x1<=400)&&(x1>=370))) && (dir1==1)){
    x1-= 0.5 ;
  }
  else{
    if((((x1<=110)&&(x1>=80)) || ((x1<=400)&&(x1>=370))) && (dir1==0)){
      x1+= 0.5;
    }  
  }
}

void point3(){
  fill(255,255,255);
  ellipse(x2,y2,30,30);
  if(x2==433){
    dir2=1;
  }
  else{
    if(x2==207){
      dir2=0;
    }  
  }
  if((x2>237)&&(x2<403) && (dir2==1) &&(valid_distance())){
    x2=x2-1;
    y2=x2-80;
  }
  else{
    if((x2>237)&&(x2<403) && (dir2==0)&&(valid_distance())){
      x2=x2+1;
      y2=x2-80;
    }  
  }
  if((((x2<=237)&&(x2>207)) || ((x2<=433)&&(x2>=403))) && (dir2==1)&&(valid_distance())){
    x2-= 0.5 ;
    y2=x2-80;
  }
  else{
    if((((x2<=237)&&(x2>=207)) || ((x2<=433)&&(x2>=403))) && (dir2==0)&&(valid_distance())){
      x2+= 0.5;
      y2=x2-80;
    }  
  }
}

void point4(){
  fill(255,255,255);
  ellipse(x3,y3,30,30);  
  if((x3<=434.7)&&(x3>=433)){
    dir3=1;
  }
  else{
    if((x3<=207.69975)&&(x3>=206.69975)){
      dir3=0;
    }  
  }
  if((x3>237)&&(x3<403) && (dir3==1) ){
    x3=x3-0.7;
    y3=-x3+560;
  }
  else{
    if((x3>237)&&(x3<403) && (dir3==0) ){
      x3=x3+0.7;
      y3=-x3+560;
    }  
  }
  
  if((((x3<=237)&&(x3>207)) || ((x3<=434.1997)&&(x3>=403))) && (dir3==1) ){
    x3-= 0.4 ;
    y3=-x3+560;
  }
  else{
    if( (((x3<=237)&&(x3>=207)) || ((x3<=434.1997)&&(x3>=403))) && (dir3==0) ){
      x3+= 0.4;
      y3=-x3+560;
    }  
  }
}

//Al hacer click se eliminan las lineas de contorno para ver mejor la ilusion
//Si hace click de nuevo ,el contorno vuelve

void mouseClicked() {
  if(cliked==0){
    stroke(128,0,0);
    cliked=1;
  }else{
    stroke(0,0,0);
    cliked=0;
  }
}

void draw(){
  background(155);
  strokeWeight(2);
  fill(128,0,0);
  ellipse(320,240,350,350);
  
  line(145, 240, 495, 240);
  point1();
  if(number_loops>=2){
    line(320, 65, 320, 415);
    point2();
  }
  if(number_loops>=3){
    line(444,364, 197, 117);
    point3();
  }
  if(number_loops>=4){
    line(196,364, 443, 117);
    point4();
  }
   
}
