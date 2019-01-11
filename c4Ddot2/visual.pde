import java.util.*;

List<Line> linesToDraw;

float rotx;
float roty;

Direction rotateForView(Direction dir, int side) {
  if (dir == Direction.YN || dir == Direction.YP || dir == Direction.WN || dir == Direction.WP)
    return dir;
  return directionViewNumber(round(mod(viewDirectionNumber(dir) + side + 1, 4)));
}

int viewDirectionNumber(Direction dir) {
  switch (dir) {
    case XP: return 0;
    case ZP: return 1;
    case XN: return 2;
    case ZN: return 3;
    default: return -1;
  }
}

Direction directionViewNumber(int num) {
  switch (num) {
    case 0: return Direction.XP;
    case 1: return Direction.ZP;
    case 2: return Direction.XN;
    case 3: return Direction.ZN;
    default: return null;
  }
}

int currentSide() {
  return round(side(roty - HALF_PI / 2.));
}

void drawBoard(BoardManager bm) {
  translate(width / 2, height / 2, -1200);  
  scale(600);
  rotx = -(mouseY - height / 2.) / height * 3 * HALF_PI;
  roty = mouseX / 160.;
  rotateX(rotx);
  rotateY(roty);
  
  translate(-1, -1, -1);

  linesToDraw = new ArrayList<Line>();
  for (Node[][][] n0 : bm.nodes)
    for (Node[][] n1 : n0)
      for (Node[] n2 : n1)
        for (Node n3 : n2)
          drawNode(n3);
  
  drawCursor(cursorNode, cursorDirection);
  
  linesToDraw.sort(new LineDistanceComparator());
  while (linesToDraw.size() != 0) {
    linesToDraw.get(0).show();
    linesToDraw.remove(0);
  }
}

void updateCursor(char k) {
  updateActualCursorData(cursorNode, cursorDirection);
  Direction keyDirection = keyToDirection(k);
  if (keyDirection == null)
    return;
  keyDirection = rotateForView(keyDirection, currentSide());
  if (keyDirection != cursorDirection) {
    cursorDirection = keyDirection;
    if (!inBounds(cursorNode, cursorDirection))
      cursorDirection = getOpposite(cursorDirection);
  } else {
    Direction cd = cursorDirection;
    cursorNode = manager.getNode(new Point(aco.x + dx(cd), aco.y + dy(cd), aco.z + dz(cd), aco.w + dw(cd)));
    if (!inBounds(cursorNode, cursorDirection))
      cursorDirection = getOpposite(cursorDirection);
  }
  updateActualCursorData(cursorNode, cursorDirection);
}

int side(float roty) {
  int res = 0;
  roty = mod(roty, TWO_PI);
  while (roty > HALF_PI) {
    res++;
    roty -= HALF_PI;
  }
  return res;
}

Node cursorNode;
Direction cursorDirection;

Point aco = null;
Point ace = null;

void updateActualCursorData(Node node, Direction dir) {
  aco = new Point(node.x, node.y, node.z, node.w);
  ace = new Point(dx(dir), dy(dir), dz(dir), dw(dir));
}

Direction keyToDirection(char k) {
  switch (k) {
    case 'a': return Direction.XN;
    case 'd': return Direction.XP;
    
    case 'e': return Direction.YN;
    case 'q': return Direction.YP;
    
    case 'w': return Direction.ZN;
    case 's': return Direction.ZP;
    
    case 'r': return Direction.WP;
    case 'f': return Direction.WN;
    
    default: return null;
  }
}

Point dco = null;
Point dce = null;

void drawCursor(Node node, Direction dir) {
  updateActualCursorData(node, dir);
  if (dco == null)
    dco = new Point(aco);
  if (dce == null)
    dce = new Point(ace);
  dco.avg(aco);
  dce.avg(ace);
  drawCursorHead();
  drawCursorTail();
}

void drawCursorHead() {
  drawMark(combine(dce, dco));
}

void drawCursorTail() {
  drawMark(dco);
}

void drawMark(Point p) {
  for (Direction d : nonWDirections) {
    Point base = combine(p, new Point(dx(d) * .05, dy(d) * .05, dz(d) * .05, dw(d) * .05));
    Point out = new Point(dx(d) * .05, dy(d) * .05, dz(d) * .05, dw(d) * .05);
    drawRaw(base, out, 0);
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

void drawRaw(Point a, Point b, color c) {
  linesToDraw.add(new Line(a, b, c));
}

boolean inBounds(Node node, Direction dir) {
  return node.x + dx(dir) < f_x && node.y + dy(dir) < f_y && node.z + dz(dir) < f_z && node.w + dw(dir) < f_w
      && node.x + dx(dir) >= 0  && node.y + dy(dir) >= 0  && node.z + dz(dir) >= 0  && node.w + dw(dir) >= 0;
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
    prepare(true);
  }
  
  Line(Point origin, Point offset, color c) {
    this.origin = origin;
    this.offset = offset;
    this.c = c;
    w = false;
    prepare(false);
  }

  void prepare(boolean doNudge) {
    PVector offset = new PVector(this.offset.x, this.offset.y, this.offset.z);
    drawOrigin = new PVector(origin.x, origin.y, origin.z);
    drawEnd = PVector.add(drawOrigin, offset);
    
    if (doNudge) {
      PVector nudge = PVector.mult(offset, .15);
      if (!w)
        drawOrigin.add(nudge);
      drawEnd.sub(nudge);
    }
    
    midpoint = PVector.add(drawOrigin, drawEnd).mult(.5);
    if (w)
      distance = -modelZ(drawOrigin);
    else
      distance = -modelZ(midpoint);
  }

  void show() {
    noFill();
    float shade = map(distance, 150, 2300, 255, brightness);
    float ishade = map(distance, 150, 2300, 0, brightness);
    
    if (distance < min)
      min = distance;
    if (distance > max)
      max = distance;
    //println(min, max);
    
    if (w) {
      stroke(shade);
      strokeWeight(6);
      PVector epos = modelXYZ(drawOrigin);
      float es = 50 + 25 * origin.w;
      int w = round(origin.w);
      if (w == 0)
        stroke(shade, shade, ishade);
      if (w == 1)
        stroke(ishade, shade, shade);

      pushMatrix();
      resetMatrix();
      camera();
      translate(0, 0, epos.z);
      ellipse(epos.x, epos.y, es, es);
      popMatrix();
    } else {
      strokeWeight(6 + 12 * (origin.w));
      int w = round(origin.w);
      stroke(c);
      if (w == 2)
        stroke(shade, ishade, ishade);
      if (w == 1)
        stroke(ishade, shade, ishade);
      if (w == 0)
        stroke(ishade, ishade, shade);
      
      PVector start = modelXYZ(drawOrigin);
      PVector end = modelXYZ(drawEnd);
      start.z = start.z;
      end.z = end.z;
      start.z -= origin.w * .03;
      end.z -= origin.w * .03;
      pushMatrix();
      resetMatrix();
      camera();
      line(start.x, start.y, start.z, end.x, end.y, end.z);
      popMatrix();
    }
  }
}
float min = 2000, max = 0;

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
  Point(Point p) {
    this(p.x, p.y, p.z, p.w);
  }
  void avg(Point p) {
    x = (x + p.x) / 2.;
    y = (y + p.y) / 2.;
    z = (z + p.z) / 2.;
    w = (w + p.w) / 2.;
  }
}

Point combine(Point a, Point b) {
  return new Point(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
}

class LineDistanceComparator implements Comparator<Line> {
  public int compare(Line a, Line b) {
    Float ad = a.distance;
    Float bd = b.distance;
    if (ad == null || bd == null)
      return 0;
    if (abs(ad - bd) < .01) {
      if (abs(a.origin.w - b.origin.w) < .01)
        return 0;
      if (a.origin.w < b.origin.w)
        return 1;
      if (a.origin.w > b.origin.w)
        return -1;
    } 
    if (ad < bd)
      return 1;
    if (ad > bd)
      return -1;
    return 0;
  }
}
