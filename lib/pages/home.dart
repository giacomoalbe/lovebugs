import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_rounded_progress_bar/flutter_icon_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../partials/add_tile_dialog.partial.dart';

import '../models/tile.dart';
import '../models/category.dart';

enum ViewMode { LIST, GRID }
enum GridMode { VIEW, ADD }

class HomePage extends StatefulWidget {
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  ViewMode mode;
  GridMode gridMode;

  bool selectionIsOk = true;

  int maxTilesNumber = Tile.MAX_TILES_NUMBER;
  int gridColumns = Tile.GRID_COLUMNS;
  double tilesPercent = 0;

  List<Tile> tiles;

  Color selectedColor = Colors.green;
  Color invalidColor = Colors.red;
  Color addbleColor = Colors.blue;
  Color idleColor = Colors.grey;
  Color alreadyTakenColor = Colors.purple;

  IconData selectedIcon = Icons.check;
  IconData invalidIcon = Icons.close;
  IconData addbleIcon = Icons.add;
  IconData idleIcon = FontAwesomeIcons.question;
  IconData alreadyTakenIcon = FontAwesomeIcons.save;

  Set<int> rowSelected;
  Set<int> colSelected;

  void initState() {
    super.initState();

    mode = ViewMode.GRID;
    gridMode = GridMode.VIEW;

    tiles = [];

    Future.delayed(Duration.zero, () async {
      tiles = await Tile.getTilesFromDisk();

      initData();

      setState(() {});
    });
  }

  void initData() {
    int savedTilesArea = 0;

    tiles.forEach((tile) {
      tile.selected = false;

      if (tile.saved) {
        savedTilesArea += tile.width * tile.height;
      }
    });

    tilesPercent = (savedTilesArea / maxTilesNumber * 100.0).round() * 1.0;

    rowSelected = new Set();
    colSelected = new Set();
  }

  void cancelAdd() {
    initData();

    gridMode = GridMode.VIEW;
    setState(() {});
  }

  void deleteTile(int row, int col) {
    int tileIndex = -1;

    tiles.asMap().forEach((index, tile) {
      if (tile.col == col && tile.row == row) {
        tileIndex = index;
      }
    });

    tiles.removeAt(tileIndex);
  }

  void setTileSize(Tile tile, int row, int col, int width, int height) {
    tile.width = width;
    tile.height = height;

    // Eat all the tiles this is going to fagocitate
    for (var i = 0; i < height; i++) {
      for (var j = 0; j < width; j++) {
        var tileRow = row + i;
        var tileCol = col + j;

        if (!(tileRow == row && tileCol == col)) {
          deleteTile(tileRow, tileCol);
        }
      }
    }
  }

  void saveTileContent(Tile tile, String note, Category category) {
    tile.saved = true;
    tile.category = category;
    tile.text = note;
  }

  void addSelectionToGrid(
      {String note, Category category, bool isAdd = true}) async {
    if (isAdd) {
      var minCol = colSelected.toList().reduce(min);
      var maxCol = colSelected.toList().reduce(max);

      var minRow = rowSelected.toList().reduce(min);
      var maxRow = rowSelected.toList().reduce(max);

      var width = (maxCol - minCol) + 1;
      var height = (maxRow - minRow) + 1;

      Tile tile;

      tile = tiles.where((t) => t.col == minCol && t.row == minRow).toList()[0];

      saveTileContent(tile, note, category);

      setTileSize(tile, minRow, minCol, width, height);

      await Tile.saveTilesToDisk(tiles);
    }

    cancelAdd();
  }

  void checkSelectionIsOk(Tile currentTile) {
    int selectedTiles = 0;

    currentTile.selected = !currentTile.selected;

    var isRowSelected = false;
    var isColSelected = false;

    tiles.forEach((tile) {
      if (tile.row == currentTile.row) {
        isRowSelected = isRowSelected || tile.selected;
      }

      if (tile.col == currentTile.col) {
        isColSelected = isColSelected || tile.selected;
      }

      if (tile.selected) {
        selectedTiles += 1;
      }
    });

    if (isColSelected) {
      colSelected.add(currentTile.col);
    } else {
      colSelected.remove(currentTile.col);
    }

    if (isRowSelected) {
      rowSelected.add(currentTile.row);
    } else {
      rowSelected.remove(currentTile.row);
    }

    var colSelectedList = colSelected.toList() ?? [];
    var rowSelectedList = rowSelected.toList() ?? [];

    var colSpan = 0;
    var rowSpan = 0;

    if (colSelectedList.length > 0) {
      colSpan = colSelectedList.reduce(max) - colSelectedList.reduce(min) + 1;
    }

    if (rowSelectedList.length > 0) {
      rowSpan = rowSelectedList.reduce(max) - rowSelectedList.reduce(min) + 1;
    }

    selectionIsOk = colSpan * rowSpan == selectedTiles;
  }

  Widget build(BuildContext context) {
    final viewBottomBar = Row(
      children: <Widget>[
        Expanded(
          child: RoundedProgressBar(
            //theme: RoundedProgressBarTheme.green,
            childCenter: Text(
              "$tilesPercent %",
              style: TextStyle(
                color: Color(0xff333333),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: RoundedProgressBarStyle(
              borderWidth: 0,
              widthShadow: 0,
              colorProgress: Color(0xff2ecc71),
              colorProgressDark: Color(0xff27ae60),
              colorBorder: Color(0xff2980b9),
            ),
            borderRadius: BorderRadius.circular(15),
            percent: tilesPercent,
          ),
        ),
      ],
    );

    final addBottomBar = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: cancelAdd,
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.solidTimesCircle,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text("Cancella", style: TextStyle(color: Colors.white)),
                ],
              )),
        ),
        SizedBox(width: 10),
        Expanded(
          child: RaisedButton(
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onPressed: selectionIsOk
                ? () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AddTileDialog(
                            onDispose: (result, message, category) async {
                              if (result) {
                                await addSelectionToGrid(
                                    note: message, category: category);
                              } else {
                                await addSelectionToGrid(isAdd: false);
                              }

                              Navigator.of(context).pop();
                            },
                          );
                        });
                  }
                : null,
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text("Aggiungi", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        )
      ],
    );

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("LoveTile"),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    gridMode =
                        gridMode == GridMode.ADD ? GridMode.VIEW : GridMode.ADD;
                  });
                },
                icon: Icon(FontAwesomeIcons.plusCircle))
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 5.0,
                    ),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: gridColumns,
                      itemCount: tiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        Color tileColor;
                        IconData tileIcon;

                        Tile currentTile = tiles[index];

                        switch (gridMode) {
                          case GridMode.ADD:
                            if (currentTile.selected) {
                              if (selectionIsOk) {
                                tileColor = selectedColor;
                                tileIcon = selectedIcon;
                              } else {
                                tileColor = invalidColor;
                                tileIcon = invalidIcon;
                              }
                            } else {
                              if (currentTile.saved) {
                                tileColor = alreadyTakenColor;
                                tileIcon = alreadyTakenIcon;
                              } else {
                                // Here is addable
                                tileColor = addbleColor;
                                tileIcon = addbleIcon;
                              }
                            }

                            break;

                          case GridMode.VIEW:
                            if (currentTile.saved) {
                              tileColor = currentTile.category.color;
                              tileIcon = currentTile.category.icon;
                            } else {
                              tileColor = idleColor;
                              tileIcon = idleIcon;
                            }
                            break;
                        }

                        return InkWell(
                          onTap: () async {
                            if (currentTile.saved) {
                              // Cannot select an already saved tile
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddTileDialog(
                                      readonly: true,
                                      tile: currentTile,
                                      onDispose: (result, message, category) {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  });
                            } else {
                              checkSelectionIsOk(currentTile);
                              setState(() {});
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              //color: tileColor?.withOpacity(0.8),
                              color: tileColor,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                width: 4,
                                color: tileColor,
                              ),
                            ),
                            padding: EdgeInsets.all(6),
                            child: Center(
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: tileColor,
                                      width: 4.0,
                                    )),
                                child: Center(
                                  child: Icon(tileIcon, color: tileColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      staggeredTileBuilder: (int index) {
                        Tile tile = tiles[index];

                        return new StaggeredTile.count(tile.width, tile.height);
                      },
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                    ))),
            Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.blue,
                child: gridMode == GridMode.ADD ? addBottomBar : viewBottomBar)
          ],
        ));
  }
}
