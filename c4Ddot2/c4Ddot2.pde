BoardManager manager;
int f_x = 3, f_y = 3, f_z = 3, f_w = 3;
float brightness;
void setup() {
  size(1200, 1200, P3D);
  manager = new BoardManager(f_x, f_y, f_z, f_w);
  cursorNode = manager.getNode(0, 0, 0, 0);
  cursorDirection = Direction.XP;
  //noLoop();
}
void draw() {
  brightness = 230;
  background(brightness);
  hint(DISABLE_DEPTH_TEST);
  drawBoard(manager);
}

void keyPressed() {
  updateCursor(key);
}
