import 'package:intl/intl.dart';

import '../models/category.dart';

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
  Category category;
  DateTime when;

  Tile({
    this.row = 0,
    this.col = 0,
    this.width = 1,
    this.height = 1,
    this.selected = false,
    this.saved = false,
    this.category,
    this.text = "",
  }) {
    this.id = globalId++;
    this.when = DateTime.now();
  }

  String formatWhen() {
    return DateFormat("d/M/y").format(this.when);
  }
}
