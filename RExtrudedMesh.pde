// code modified from  emnullfuenf's 3D Extruded Font with Geomerative at openprocessing.org 
//modified to draw on pgraphics

class RExtrudedMesh
{
  float depth = 10;
  RPoint[][] points;
  RMesh m;
  PGraphics g;
  
  RExtrudedMesh(RShape grp, float d, PGraphics pgraph)
  {
    depth = d;
    m = grp.toMesh();
    points = grp.getPointsInPaths();
    g = pgraph;
  }
  
  void draw()
  {
    // Draw front
  for (int i=0; i<m.countStrips(); i++) {
    g.beginShape(PConstants.TRIANGLE_STRIP);
    for (int j=0;j<m.strips[i].vertices.length;j++) {
      g.vertex(m.strips[i].vertices[j].x, m.strips[i].vertices[j].y, 0);
    }
    endShape(PConstants.CLOSE);
  }

  // Draw back
  for (int i=0; i<m.countStrips(); i++) {
    g.beginShape(PConstants.TRIANGLE_STRIP);
    for (int j=0;j<m.strips[i].vertices.length;j++) {
      g.vertex(m.strips[i].vertices[j].x, m.strips[i].vertices[j].y, -depth);
    }
    g.endShape(PConstants.CLOSE);
  }
  
  // Draw side (from outline points)
  for (int i=0; i<points.length; i++) {
    g.beginShape(PConstants.TRIANGLE_STRIP);
    for (int j=0; j<points[i].length-1; j++)
    {
      g.vertex(points[i][j].x, points[i][j].y, 0);
      g.vertex(points[i][j].x, points[i][j].y, -depth);
      g.vertex(points[i][j+1].x, points[i][j+1].y, -depth);
      g.vertex(points[i][j].x, points[i][j].y, 0);
      g.vertex(points[i][j+1].x, points[i][j+1].y, 0);
    }
    g.vertex(points[i][0].x, points[i][0].y, 0);
    g.endShape(PConstants.CLOSE);
  }
  }
}
