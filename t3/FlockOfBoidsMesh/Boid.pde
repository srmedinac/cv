import java.util.List;
import java.util.Map;

public class Boid {
  public Frame frame;
  PShape boid;
  PShape shapeFaceFV;
  int rep, render;
  // fields
  Vector position, velocity, acceleration, alignment, cohesion, separation; // position, velocity, and acceleration in
  // a vector datatype
  float neighborhoodRadius; // radius in which it looks for fellow boids
  float maxSpeed = 4; // maximum magnitude for the velocity vector
  float maxSteerForce = .1f; // maximum magnitude of the steering vector
  float sc = 3; // scale factor for the render of the boid
  float flap = 0;
  float t = 0;
  
  Vector vertex_id0, vertex_id1, vertex_id2, vertex_id3, vertex_id4, vertex_id5, vertex_id6, vertex_id7;
  //Creation of Face-Vertex data structure
  ArrayList<Face> faces = new ArrayList<Face>();
  HashMap<Integer,FV> vertexList = new HashMap<Integer,FV>();
  ArrayList<Vector> vertexListMesh = new ArrayList<Vector>();
  FV faceVertex;
  VV vertexVertex;
  Boid(Vector inPos, int rep) { //added representation and render mode to choose either FV/VV or Immediate/Retained
    this.rep = rep;
 
    position = new Vector();
    position.set(inPos);
    frame = new Frame(scene) {
      // Note that within visit() geometry is defined at the
      // frame local coordinate system.
      @Override
        public void visit() {
        if (animate)
          if (count < 30){
            run(flock);
          }
        render();
      }
    };
    frame.setPosition(new Vector(position.x(), position.y(), position.z()));
    velocity = new Vector(random(-1, 1), random(-1, 1), random(1, -1));
    acceleration = new Vector(0, 0, 0);
    neighborhoodRadius = 100;
    buildRep();
    this.shapeFaceFV = createShape();
    fillShape();
  }
  public void run(ArrayList<Boid> bl) {
    t += .1;
    flap = 10 * sin(t);
    // acceleration.add(steer(new Vector(mouseX,mouseY,300),true));
    // acceleration.add(new Vector(0,.05,0));
    if (avoidWalls) {
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), flockHeight, position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), 0, position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(flockWidth, position.y(), position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(0, position.y(), position.z())), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), 0)), 5));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), flockDepth)), 5));
    }
    flock(bl);
    move();
    checkBounds();
  }

  Vector avoid(Vector target) {
    Vector steer = new Vector(); // creates vector for steering
    steer.set(Vector.subtract(position, target)); // steering vector points away from
    steer.multiply(1 / sq(Vector.distance(position, target)));
    return steer;
  }

  //-----------behaviors---------------

  void flock(ArrayList<Boid> boids) {
    //alignment
    alignment = new Vector(0, 0, 0);
    int alignmentCount = 0;
    //cohesion
    Vector posSum = new Vector();
    int cohesionCount = 0;
    //separation
    separation = new Vector(0, 0, 0);
    Vector repulse;
    for (int i = 0; i < boids.size(); i++) {
      Boid boid = boids.get(i);
      //alignment
      float distance = Vector.distance(position, boid.position);
      if (distance > 0 && distance <= neighborhoodRadius) {
        alignment.add(boid.velocity);
        alignmentCount++;
      }
      //cohesion
      float dist = dist(position.x(), position.y(), boid.position.x(), boid.position.y());
      if (dist > 0 && dist <= neighborhoodRadius) {
        posSum.add(boid.position);
        cohesionCount++;
      }
      //separation
      if (distance > 0 && distance <= neighborhoodRadius) {
        repulse = Vector.subtract(position, boid.position);
        repulse.normalize();
        repulse.divide(distance);
        separation.add(repulse);
      }
    }
    //alignment
    if (alignmentCount > 0) {
      alignment.divide((float) alignmentCount);
      alignment.limit(maxSteerForce);
    }
    //cohesion
    if (cohesionCount > 0)
      posSum.divide((float) cohesionCount);
    cohesion = Vector.subtract(posSum, position);
    cohesion.limit(maxSteerForce);

    acceleration.add(Vector.multiply(alignment, 1));
    acceleration.add(Vector.multiply(cohesion, 3));
    acceleration.add(Vector.multiply(separation, 1));
  }

  void move() {
    velocity.add(acceleration); // add acceleration to velocity
    velocity.limit(maxSpeed); // make sure the velocity vector magnitude does not
    // exceed maxSpeed
    position.add(velocity); // add velocity to position
    frame.setPosition(position);
    frame.setRotation(Quaternion.multiply(new Quaternion(new Vector(0, 1, 0), atan2(-velocity.z(), velocity.x())), 
      new Quaternion(new Vector(0, 0, 1), asin(velocity.y() / velocity.magnitude()))));
    acceleration.multiply(0); // reset acceleration
  }

  void checkBounds() {
    if (position.x() > flockWidth)
      position.setX(0);
    if (position.x() < 0)
      position.setX(flockWidth);
    if (position.y() > flockHeight)
      position.setY(0);
    if (position.y() < 0)
      position.setY(flockHeight);
    if (position.z() > flockDepth)
      position.setZ(0);
    if (position.z() < 0)
      position.setZ(flockDepth);
  }
  
  void render() {
    pushStyle();

    // uncomment to draw boid axes
    //scene.drawAxes(10);

    strokeWeight(2);
    stroke(color(40, 255, 40));
    fill(color(0, 255, 0, 125));

    // highlight boids under the mouse
    if (scene.trackedFrame("mouseMoved") == frame) {
      stroke(color(0, 0, 255));
      fill(color(0, 0, 255));
    }

    // highlight avatar
    if (frame ==  avatar) {
      stroke(color(255, 0, 0));
      fill(color(255, 0, 0));
    }
    //!!
    
    if(retainedMode){
      renderRetained();
      
    } else {
      renderImmediate();
    }

  }
  //representation builders
  

 public void renderImmediate(){
   pushStyle();

    // uncomment to draw boid axes
    //scene.drawAxes(10);

    strokeWeight(2);
    stroke(color(40, 255, 40));
    fill(color(0, 255, 0, 125));

    // highlight boids under the mouse
    if (scene.trackedFrame("mouseMoved") == frame) {
      stroke(color(0, 0, 255));
      fill(color(0, 0, 255));
    }

    // highlight avatar
    if (frame ==  avatar) {
      stroke(color(255, 0, 0));
      fill(color(255, 0, 0));
    }
   beginShape(TRIANGLES);
   
   for (Face face: faces){
        //print(" ",vertexList.get(face.vertex1_id).vector.x(), vertexList.get(face.vertex1_id).vector.y(),vertexList.get(face.vertex1_id).vector.z());
        curveVertex(vertexList.get(face.vertex1_id).vector.x(), vertexList.get(face.vertex1_id).vector.y(),vertexList.get(face.vertex1_id).vector.z());      
        curveVertex(vertexList.get(face.vertex2_id).vector.x(), vertexList.get(face.vertex2_id).vector.y(),vertexList.get(face.vertex2_id).vector.z()); 
        curveVertex(vertexList.get(face.vertex3_id).vector.x(), vertexList.get(face.vertex3_id).vector.y(),vertexList.get(face.vertex3_id).vector.z()); 
    }
   
   endShape();   
  }
  void fillShape(){
    shapeFaceFV.beginShape(TRIANGLES);
    int a=0;
    for(Face face : faces) {
      //print(" ",vertexList.get(face.vertex1_id).vector.x(), vertexList.get(face.vertex1_id).vector.y(),vertexList.get(face.vertex1_id).vector.z());
      //print(a);
      //print("- ",face.vertex1_id,face.vertex2_id,face.vertex3_id,"-- ");
      shapeFaceFV.vertex(vertexList.get(face.vertex1_id).vector.x(), vertexList.get(face.vertex1_id).vector.y(),vertexList.get(face.vertex1_id).vector.z());
      shapeFaceFV.vertex(vertexList.get(face.vertex2_id).vector.x(), vertexList.get(face.vertex2_id).vector.y(),vertexList.get(face.vertex2_id).vector.z());
      shapeFaceFV.vertex(vertexList.get(face.vertex3_id).vector.x(), vertexList.get(face.vertex3_id).vector.y(),vertexList.get(face.vertex3_id).vector.z()); 
      a++;
    }

    shapeFaceFV.endShape();
  }
  void renderRetained(){
    // highlight avatar
    if (frame ==  avatar) {
      stroke(color(255, 0, 0));
      fill(color(255, 0, 0));
    }
    shapeFaceFV.setStrokeWeight(2);
    shapeFaceFV.setStroke(color(40, 255, 40));
    shapeFaceFV.setFill(color(0, 255, 0, 125));
    shape(shapeFaceFV);
  }
  public void buildRep(){
    if(inFacevertex){
      vertex_id0 = new Vector(0, 0, 0);
      vertex_id1 = new Vector(0, 0, 3 * sc);
      vertex_id2 = new Vector(0, 3 * sc, 0);
      vertex_id3 = new Vector(0, 3 * sc, 3 * sc);
      vertex_id4 = new Vector(3 * sc, 0, 0);
      vertex_id5 = new Vector(3 * sc, 0, 3 * sc);
      vertex_id6 = new Vector(3 * sc, 3 * sc, 0);
      vertex_id7 = new Vector(3 * sc, 3 * sc, 3 * sc);
      
      faces.add(new Face(0, 1, 3));//face_id0 
      faces.add(new Face(0, 2, 3));//face_id1
      faces.add(new Face(1, 3, 7));//face_id2
      faces.add(new Face(1, 5, 7));//face_id3
      faces.add(new Face(4, 5, 6));//face_id4
      faces.add(new Face(4, 5, 7));//face_id5
      faces.add(new Face(0, 2, 4));//face_id6
      faces.add(new Face(2, 4, 6));//face_id7
      faces.add(new Face(0, 4, 5));//face_id8
      faces.add(new Face(0, 1, 5));//face_id9
      faces.add(new Face(2, 3, 7));//face_id10
      faces.add(new Face(2, 6, 7));//face_id11
      int[] fv0={0,1,6,8,9};
      int[] fv1={0,2,3,9};
      int[] fv2={1,6,7,10,11};
      int[] fv3={1,2,3,10};
      int[] fv4={4,5,6,7,8};
      int[] fv5={3,4,5,8,9};
      int[] fv6={4,7,11};
      int[] fv7={2,3,5,10,11};

      vertexList.put(0,new FV(vertex_id0, fv0));
      vertexList.put(1,new FV(vertex_id1, fv1));
      vertexList.put(2,new FV(vertex_id2, fv2));
      vertexList.put(3,new FV(vertex_id3, fv3));
      vertexList.put(4,new FV(vertex_id4, fv4));
      vertexList.put(5,new FV(vertex_id5, fv5));
      vertexList.put(6,new FV(vertex_id6, fv6));
      vertexList.put(7,new FV(vertex_id7, fv7));
   
    }
    else{
    //  Stack myStack = new Stack();
      /*
          beginShape();

    //cube in inmediat mode
    vvmesh.clearMesh();
    Stack myStack = new Stack();
    int currVertexId;
    VVVertex currVertex;
    VVVertex nextVertex;
    int i, j;
    Contiguo contiguo;

    myStack.push(new Integer(0));
    currVertexId = (Integer) myStack.peek();
    currVertex = vvmesh.getVertices().get(currVertexId);
    vertex(currVertex.getX(), currVertex.getY(), currVertex.getZ());


    while (!myStack.empty()) {
      currVertexId = (Integer) myStack.peek();
      currVertex = vvmesh.getVertices().get(currVertexId);

      for (i=0; i<currVertex.getContiguous().size(); i++) {
        contiguo = currVertex.getContiguous().get(i);

        if (!contiguo.getVisited()) {
          myStack.push(new Integer(contiguo.getId()));
          nextVertex = vvmesh.getVertices().get(contiguo.getId());

          vertex(nextVertex.getX(), nextVertex.getY(), nextVertex.getZ());

          currVertex.increaseTraveled();
          nextVertex.increaseTraveled();
          contiguo.setVisited(true);
          for (j= 0; j<nextVertex.getContiguous().size(); j++) {
            if (nextVertex.getContiguous().get(j).getId() == currVertexId) {
              nextVertex.getContiguous().get(j).setVisited(true);
              break;
            }
          }
          break;
        }
      }
      if (i == currVertex.getContiguous().size()) {
        for (i=0; i<currVertex.getContiguous().size(); i++) {
          contiguo = currVertex.getContiguous().get(i);
          if (!vvmesh.getVertices().get(contiguo.getId()).isFull()) {
            myStack.push(new Integer(contiguo.getId()));
            nextVertex = vvmesh.getVertices().get(contiguo.getId());

            vertex(nextVertex.getX(), nextVertex.getY(), nextVertex.getZ());
            break;
          }
        }
      }

      if (i == currVertex.getContiguous().size()) {
        myStack.pop();
        if (!myStack.empty()) {
          currVertexId = (Integer) myStack.peek();
          currVertex = vvmesh.getVertices().get(currVertexId);
          vertex(currVertex.getX(), currVertex.getY(), currVertex.getZ());
        }
      }
    }  
    endShape();
      */
      
    }
  }
    
}

/*
public void buildRep(){
    if(this.rep == 0) { //if representation is Face-Vertex
      Map<Vector, Face[]> neighbors = new HashMap<Vector, Face[]>();
      Face[] f1 = {face2,face3,face4};
      Face[] f2 = {face1,face3,face4};
      Face[] f3 = {face1,face2,face4};
      Face[] f4 = {face2,face3,face4};
      neighbors.put(vertices.get(0), f1);
      neighbors.put(vertices.get(1), f2);
      neighbors.put(vertices.get(2), f3);
      neighbors.put(vertices.get(3), f4);
      faceVertex = new FV(faces, vertices, neighbors);

    }
    if(this.rep == 1){
        Map <Integer, Integer[]> neighbors = new HashMap<Integer, Integer[]>();
        neighbors.put( 0, new Integer[]{1, 2, 3});
        neighbors.put( 1, new Integer[]{0, 2, 3});
        neighbors.put( 2, new Integer[]{0, 1, 3});
        neighbors.put( 3, new Integer[]{0, 1, 2});
        VV vertexVertex = new VV(vertices, neighbors);
        if(this.render == 0){
          vertexVertex.immediate();
          vertexVertex = null;
        }
        else{
          this.boid = vertexVertex.retained();
      }
    }
  }
*/
class CubicHermitCurve{
  
  int n_controPoints;
  CubicHermitCurve(int n_controPoints){
    this.n_controPoints = n_controPoints;
  }
  void cubicHermitSplines3d(){
        
    pushStyle();
    noFill();
    strokeWeight(7);
    stroke(255,0,255);
    beginShape(POINTS);
    for (int i=1;i<n_controPoints-2;i++){
      for (float mu=0;mu<=1;mu=mu+0.05){
        float x= (float)cubicHermitSplines1d(controlPoints[i-1].x(),controlPoints[i].x(),controlPoints[i+1].x(),controlPoints[i+2].x(),mu,0);
        float y= (float)cubicHermitSplines1d(controlPoints[i-1].y(),controlPoints[i].y(),controlPoints[i+1].y(),controlPoints[i+2].y(),mu,0);
        float z=(float)cubicHermitSplines1d(controlPoints[i-1].z(),controlPoints[i].z(),controlPoints[i+1].z(),controlPoints[i+2].z(),mu,0);
        vertex(x, y,z);       
      }
    }

    endShape();
    popStyle();
    
  }
  double cubicHermitSplines1d(double y0,double y1,double y2,double y3,float mu,double tension){
    double m0,m1,mu2,mu3;
    double a0,a1,a2,a3;
    
    mu2 = pow(mu,2);
    mu3 = mu2 * mu;
    m0  = (y2-y0)*(1-tension)/2;
    m1  = (y3-y1)*(1-tension)/2;
    a0 =  2*mu3 - 3*mu2 + 1;
    a1 =    mu3 - 2*mu2 + mu;
    a2 =  mu3 -   mu2;
    a3 = -2*mu3 + 3*mu2;
    
    return(a0*y1+a3*y2+m0*a1+m1*a2);
  }

}
class BezierCurve{
  int n_controPoints;
  BezierCurve(int n_controPoints){
    this.n_controPoints = n_controPoints;
  }
  void bezierCubicSplines(){
   
    pushStyle();
    noFill();
    strokeWeight(7);
    if(n_controPoints == 3){
      stroke(255,0,0);}
    else{
      stroke(0,0,255);
    }
    beginShape(POINTS);
    for (float mu=0;mu<=1;mu=mu+0.02){
      Vector p_u= Bezier(controlPoints2,n_controPoints-1,mu);

      vertex(p_u.x(), p_u.y(),p_u.z());       
    }
    endShape();
    popStyle();
  }

  Vector Bezier(Vector[] p,int n,float mu){
     int k;
     double blend,muk,munk;
     muk = 1;
     munk = pow(1-mu,(float)n);
       float x1=0,x2=0,x3=0;
     for (k=0;k<=n;k++) {
        blend = muk * munk;
        muk *= mu;
        munk /= (1-mu);
        blend *= combinatoria(n,k);
        
        x1 += p[k].x() * blend;
        x2 += p[k].y() * blend;
        x3 += p[k].z() * blend;
     }
    Vector b = new Vector(x1,x2,x3) ;
    return(b);
  }
  int combinatoria( int n , int r ){
    if( r == 0 || r == n)
        return 1;
    if( r > n)
        return 0;
    int a , b;
    a = combinatoria ( n - 1 , r -1 );
    b = combinatoria ( n - 1 , r );
    return a + b;
  }
}
