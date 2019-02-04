class Face {
  
  Vector vertex1;
  Vector vertex2;
  Vector vertex3;
  
  public Face(Vector v1, Vector v2, Vector v3) {
    this.vertex1 = v1;
    this.vertex2 = v2;
    this.vertex3 = v3;
  }
  
    public void immediate(){
    beginShape(TRIANGLE);
      vertex(vertex1.x(),vertex1.y(),vertex1.z());
      vertex(vertex2.x(),vertex2.y(),vertex2.z());
      vertex(vertex3.x(),vertex3.y(),vertex3.z());
    endShape();
  }
}
