import java.util.List;
import java.util.Map;

public class Boid {
  public Frame frame;
  PShape boid;
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
  Face face1, face2, face3, face4;
  Vector vertex1, vertex2, vertex3, vertex4;
  //Creation of Face-Vertex data structure
  List<Face> faces = new ArrayList<Face>();
  List<Vector> vertices = new ArrayList<Vector>();
  FV faceVertex;
  VV vertexVertex;
  
  Boid(Vector inPos, int rep, int render) { //added representation and render mode to choose either FV/VV or Immediate/Retained
    this.rep = rep;
    this.render = render;
    position = new Vector();
    position.set(inPos);
    frame = new Frame(scene) {
      // Note that within visit() geometry is defined at the
      // frame local coordinate system.
      @Override
        public void visit() {
        if (animate)
          run(flock);
        render();
      }
    };
    frame.setPosition(new Vector(position.x(), position.y(), position.z()));
    velocity = new Vector(random(-1, 1), random(-1, 1), random(1, -1));
    acceleration = new Vector(0, 0, 0);
    neighborhoodRadius = 100;
  }
  //representation builders
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
      if(this.render == 1){
        this.boid = faceVertex.retained();
      } else if(this.render == 0){
        faceVertex.immediate();
        faceVertex = null;
      }
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
    vertex1 = new Vector(3 * sc, 0, 0);
    vertex2 = new Vector(-3 * sc, 2 * sc, 0);
    vertex3 = new Vector(-3 * sc, -2 * sc, 0);
    vertex4 = new Vector(-3 * sc, 0, 2 * sc);
    face1 = new Face(vertex1, vertex2, vertex3);
    face2 = new Face(vertex1, vertex2, vertex4);
    face3 = new Face(vertex1, vertex4, vertex3);
    face4 = new Face(vertex4, vertex2, vertex3);
    faces.add(face1);
    faces.add(face2);
    faces.add(face3);
    faces.add(face4);
    vertices.add(vertex1);
    vertices.add(vertex2);
    vertices.add(vertex3);
    vertices.add(vertex4);
    buildRep();
    if(render == 1)
      shape(boid);
  }
}
