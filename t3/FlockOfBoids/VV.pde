class VV {
  
   Map<Integer, Integer[]> neighbors;
    List<Vector> vertices;
    PShape shapeVertex = createShape();

    public VV(List<Vector> vertices, Map<Integer, Integer[]> neighbors) {
        this.vertices = vertices;
        this.neighbors = neighbors;
    }
    //work on this
    //-------------------------------
    void immediate(){
        for(int current_vertex: neighbors.keySet()){
            Integer[] current_neighbors = neighbors.entrySet().iterator().next().getValue();
            for(int neighbors: current_neighbors){
                line(vertices.get(current_vertex).x(), vertices.get(current_vertex).y(), vertices.get(current_vertex).z(), vertices.get(neighbors).x(),vertices.get(neighbors).y(),vertices.get(neighbors).z());
            }
        }

    } 
    PShape retained(){
      shapeVertex.beginShape(TRIANGLE);
        for(int current_vertex: neighbors.keySet()){
            Integer[] current_neighbors = neighbors.entrySet().iterator().next().getValue();
            for(int neighbors: current_neighbors){
                shapeVertex.vertex(vertices.get(current_vertex).x(), vertices.get(current_vertex).y(), vertices.get(current_vertex).z());
                shapeVertex.vertex(vertices.get(neighbors).x(),vertices.get(neighbors).y(),vertices.get(neighbors).z());
            }
        }
        shapeVertex.endShape();        
        return shapeVertex;
  
    }
}
