class FV {
    List<Face> faces;
    List<Vector> vertices;
    Map<Vector, Face[]> neighbors;
    public FV(List<Face> faces, List<Vector> vertices, Map<Vector, Face[]> neighbors) {
        this.faces = faces;
        this.vertices = vertices;
        this.neighbors = neighbors;
    }
    void immediate(){
      for(Face face : faces) {
        face.immediate();
       }       
        faces = null;
        vertices = null;
    }
    PShape retained(){
      PShape shapeFace = createShape();
      shapeFace.beginShape();
      for(Face face : faces) {
        shapeFace.vertex(face.vertex1.x(), face.vertex1.y(), face.vertex1.z());
        shapeFace.vertex(face.vertex2.x(), face.vertex2.y(), face.vertex2.z());
        shapeFace.vertex(face.vertex3.x(), face.vertex3.y(), face.vertex3.z());
      }
      shapeFace.endShape();
      return shapeFace;
    }
}
