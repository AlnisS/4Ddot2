import java.util.*;

class BoardManager {
  Node[][][][] nodes;
  Set<Square> squares;
  Queue<Square> newSquares;
  
  BoardManager(int x, int y, int z, int w) {
    
    nodes = new Node[x][y][z][w];
    
    for (int x_ = 0; x_ < x; x_++) {
      for (int y_ = 0; y_ < x; y_++) {
        for (int z_ = 0; z_ < x; z_++) {
          for (int w_ = 0; w_ < x; w_++) {
            nodes[x_][y_][z_][w_] = new Node(x_, y_, z_, w_);
          }
        }
      }
    }
    
    squares = new HashSet<Square>();
    newSquares = new LinkedList<Square>();
  }
  
  Node getNode(int x, int y, int z, int w) {
    return nodes[x][y][z][w];
  }
  
  Node getNode(Point p) {
    return  getNode(round(p.x), round(p.y), round(p.z), round(p.w));
  }
  
  void connect(Node a, Node b) {
    new Connection(a, b);
  }
  
  void updateSquares(Player player) {
    for (Node[][][] n0 : nodes)
      for (Node[][] n1 : n0)
        for (Node[] n2 : n1)
          for (Node n3 : n2)
            n3.checkSquares(this);
    Square square;
    while ((square = newSquares.poll()) != null) {
      squares.add(square);
      square.player = player;
    }
  }
  
  void register(Square square) {
    newSquares.add(square);
  }
}

class Square {
  Connection outa, outb, backa, backb;
  Player player = null;
  
  public Square(Connection outa, Connection outb, Connection backa, Connection backb) {
    this.outa = outa;
    this.outb = outb;
    this.backa = backa;
    this.backb = backb;
  }
  
  public Square(Node node, Direction a, Direction b) {
    
  }
}

class Connection {
  Node a;
  Node b;
  Direction adirection;
  Direction bdirection;
  
  Connection(Node a, Node b) {
    this.a = a;
    this.b = b;
    this.adirection = getDirection(a, b);
    this.bdirection = getOpposite(adirection);
    a.connections.put(adirection, this);
    b.connections.put(bdirection, this);
  }
  
  Node getOther(Node thus) {
    if (a == thus)
      return b;
    if (b == thus)
      return a;
    return null;
  }
}

class Node {
  int x, y, z, w;
  Map<Direction, Connection> connections;
  
  Node(int x, int y, int z, int w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
    connections = new HashMap<Direction, Connection>();
  }
  
  Square checkSquares(BoardManager manager) {
    for (DirectionPair pair : directionPairs) {
      Square square = checkSquare(pair.a, pair.b);
      if (square != null)
        manager.register(square);
    }
    return null;
  }
  
  Square checkSquare(Direction a, Direction b) {
     Node node1 = precess(this, a);
     Node node2 = precess(node1, b);
     Node node3 = precess(node2, getOpposite(a));
     Node node0 = precess(node3, getOpposite(b));
     if (node0 == null)
       return null;
     if (node0 != this)
       throw new InternalError("square is not square");
     return new Square(this, a, b);
  }
  
  String toString() {
    return x + " " + y + " " + z + " " + w;
  }
}

class DirectionPair {
  Direction a;
  Direction b;
  
  DirectionPair(Direction a, Direction b) {
    this.a = a;
    this.b = b;
  }
}

class Player {
  int id;
  
  Player(int id) {
    this.id = id;
  }
}
