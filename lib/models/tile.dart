class Tile {
  static int globalId = 0;

  int id;
  int row;
  int col;
  int width;
  int height;
  bool selected;
  bool saved;
  String text;

  Tile({
    this.row = 0,
    this.col = 0,
    this.width = 1,
    this.height = 1,
    this.selected = false,
    this.saved = false,
    this.text = "",
  }) {
    this.id = globalId++;
  }
}
