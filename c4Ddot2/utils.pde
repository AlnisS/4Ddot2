DirectionPair[] directionPairs =
    {new DirectionPair(Direction.XP, Direction.YP),
     new DirectionPair(Direction.YP, Direction.ZP),
     new DirectionPair(Direction.XP, Direction.ZP),
     new DirectionPair(Direction.WP, Direction.XP),
     new DirectionPair(Direction.WP, Direction.YP),
     new DirectionPair(Direction.WP, Direction.ZP)};

Direction[] positiveDirections = 
    {Direction.XP, Direction.YP, Direction.ZP, Direction.WP};

enum Direction {XN, XP, YN, YP, ZN, ZP, WN, WP}

Direction getDirection(Node a, Node b) {
  int delta = abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z) + abs(a.w - b.w);
  if (delta > 1)
    return null;
  if (b.x < a.x)
    return Direction.XN;
  if (b.x > a.x)
    return Direction.XP;
  if (b.y < a.y)
    return Direction.YN;
  if (b.y > a.y)
    return Direction.YP;
  if (b.z < a.z)
    return Direction.ZN;
  if (b.z > a.z)
    return Direction.ZP;
  if (b.w < a.w)
    return Direction.WN;
  if (b.w > a.w)
    return Direction.WP;
  throw new InternalError("this should never happen a (" + a.toString() + " b (" + b.toString() + ")");
}

Direction getOpposite(Direction direction) {
  switch (direction) {
    case XN: return Direction.XP;
    case XP: return Direction.XN;
    case YN: return Direction.YP;
    case YP: return Direction.YN;
    case ZN: return Direction.ZP;
    case ZP: return Direction.ZN;
    case WN: return Direction.WP;
    case WP: return Direction.WN;
    default: return null;
  }
}

Node precess(Node node, Direction direction) {
  if (node == null)
    return null;
  return node.connections.get(direction).getOther(node);
}

int dx(Direction d) {
  switch (d) {
    case XN: return -1;
    case XP: return +1;
    default: return 0;
  }
}

int dy(Direction d) {
  switch (d) {
    case YN: return -1;
    case YP: return +1;
    default: return 0;
  }
}

int dz(Direction d) {
  switch (d) {
    case ZN: return -1;
    case ZP: return +1;
    default: return 0;
  }
}

int dw(Direction d) {
  switch (d) {
    case WN: return -1;
    case WP: return +1;
    default: return 0;
  }
}
