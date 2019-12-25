import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';

part 'tile.g.dart';

@JsonSerializable()
class Tile {
  static int MAX_TILES_NUMBER = 100;
  static int GRID_COLUMNS = 4;

  int row;
  int col;
  int width;
  int height;
  bool selected;
  bool saved;
  String text;
  @JsonKey(fromJson: categoryFromJson, toJson: categoryToJson)
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
    this.when = DateTime.now();
  }

  factory Tile.fromJson(Map<String, dynamic> json) => _$TileFromJson(json);

  Map<String, dynamic> toJson() => _$TileToJson(this);

  String formatWhen() {
    return DateFormat("d/M/y").format(this.when);
  }

  static Future<List<Tile>> getTilesFromDisk() async {
    Directory fileRoot = await getApplicationDocumentsDirectory();
    List<Tile> tiles = new List();

    if (File("${fileRoot.path}/tiles.json").existsSync()) {
      String tilesContent =
          File("${fileRoot.path}/tiles.json").readAsStringSync();

      List<dynamic> tilesMap = jsonDecode(tilesContent);

      tilesMap.forEach((tileMap) {
        tiles.add(Tile.fromJson(jsonDecode(tileMap)));
      });

      return tiles;
    } else {
      for (var i = 0; i < MAX_TILES_NUMBER; i++) {
        int row = (i / GRID_COLUMNS).floor();
        int col = i % GRID_COLUMNS;

        tiles.add(Tile(
          row: row,
          col: col,
          width: 1,
          height: 1,
        ));
      }

      return tiles;
    }
  }

  static Category categoryFromJson(String categoryId) {
    if (categoryId != "null") {
      return Category.getAll()
          .where((c) => c.id == int.parse(categoryId))
          .toList()[0];
    } else {
      return null;
    }
  }

  static String categoryToJson(Category category) {
    if (category == null) {
      return "null";
    } else {
      return "${category.id}";
    }
  }

  static void saveTilesToDisk(List<Tile> tiles) async {
    List<String> tilesListString = [];

    for (var tile in tiles) {
      tilesListString.add(jsonEncode(tile.toJson()));
    }

    String tilesJson = jsonEncode(tilesListString);

    Directory fileRoot = await getApplicationDocumentsDirectory();

    await File("${fileRoot.path}/tiles.json").writeAsString(tilesJson);
  }
}
