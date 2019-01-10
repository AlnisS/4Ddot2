import java.util.*;

List<Line> linesToDraw;

void drawBoard(BoardManager bm) {
  translate(450, 450, -1000);  
  scale(300);
  rotateX( -(mouseY - height / 2.) / height * 3 * HALF_PI);
  rotateY(mouseX / 160.);
  translate(-1, -1, -1);

  linesToDraw = new ArrayList<Line>();
  for (Node[][][] n0 : bm.nodes)
    for (Node[][] n1 : n0)
      for (Node[] n2 : n1)
        for (Node n3 : n2)
          drawNode(n3);
  for (Line line : linesToDraw) {
    line.prepare();
  }

  while (linesToDraw.size() != 0) {
    linesToDraw.get(0).show();
    linesToDraw.remove(0);
  }
}

void drawNode(Node node) {
  for (Direction direction : positiveDirections) {
    if (node.connections.containsKey(direction))
      drawConnection(node.connections.get(direction), color(255));
    else
      drawSkeleton(node, direction, color(127, 127, 127));
  }
}

void drawConnection(Connection connection, color c) {
  linesToDraw.add(new Line(connection.a, connection.adirection, c));
}

void drawSkeleton(Node node, Direction direction, color c) {
  if (inBounds(node, direction))
    linesToDraw.add(new Line(node, direction, c));
}

boolean inBounds(Node node, Direction dir) {
  return node.x + dx(dir) < f_x && node.y + dy(dir) < f_y && node.z + dz(dir) < f_z && node.w + dw(dir) < f_w;
}

PVector toPolar(PVector in) {
  float rho = sqrt(pow(in.x, 2) + pow(in.y, 2) + pow(in.z, 2));
  float phi = acos(in.z / rho);
  float theta = atan(in.y / in.x);
  return new PVector(rho, phi, theta);
}

PVector fromPolar(PVector in) {
  float x = in.x * cos(in.z);
  float y = in.x * sin(in.z);
  float z = in.x * cos(in.y);
  return new PVector(x, y, z);
}

float modelX(PVector in) {
  return modelX(in.x, in.y, in.z);
}

float modelY(PVector in) {
  return modelY(in.x, in.y, in.z);
}

float modelZ(PVector in) {
  return modelZ(in.x, in.y, in.z);
}

float distance(PVector in) {
  return sqrt(sq(modelX(in) - 450) + sq(modelY(in) - 450) + sq(modelZ(in) - 450));
}

PVector modelXYZ(PVector in) {
  return new PVector(modelX(in), modelY(in), modelZ(in));
}

class Line {
  color c;
  Float distance = null;
  boolean w;
  Point origin;
  Point offset;
  PVector drawOrigin;
  PVector drawEnd;
  float wsize;
  PVector midpoint;

  Line(Node start, Direction dir, color c) {
    this.origin = new Point(start.x, start.y, start.z, start.w);
    this.offset = new Point(dx(dir), dy(dir), dz(dir), 0);
    w = dir == Direction.WN || dir == Direction.WP;
    this.c = c;
  }

  void prepare() {
    drawOrigin = new PVector(origin.x, origin.y, origin.z);
    drawEnd = PVector.add(drawOrigin, new PVector(offset.x, offset.y, offset.z));
    midpoint = PVector.add(drawOrigin, drawEnd).mult(.5);
    if (w)
      distance = -modelZ(drawOrigin);//distance(drawOrigin);
    else
      distance = -modelZ(midpoint);//distance(PVector.add(drawOrigin, drawEnd).mult(.5));
  }

  void show() {
    noFill();
    float shade = map(distance, 450, 1600, 0, 255); 
    stroke(shade);
    if (w) {
      stroke(shade);
      strokeWeight(3);
      PVector epos = modelXYZ(drawOrigin);

      pushMatrix();
      resetMatrix();
      camera();
      translate(0, 0, epos.z);
      ellipse(epos.x, epos.y, 50, 50);
      popMatrix();
    } else {
      strokeWeight(1 / 100.);
      line(drawOrigin.x, drawOrigin.y, drawOrigin.z, drawEnd.x, drawEnd.y, drawEnd.z);
    }
  }
}

class Point {
  float x, y, z, w;
  Point(float x, float y, float z) {
    this(x, y, z, 0);
  }
  Point(float x, float y, float z, float w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }
}

class LineDistanceComparator implements Comparator<Line> {
  public int compare(Line a, Line b) {
    Float ad = a.distance;
    Float bd = b.distance;
    if (ad == null || bd == null)
      return 0;
    if (ad < bd)
      return 1;
    if (ad > bd)
      return -1;
    return 0;
  }
}
