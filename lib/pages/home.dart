import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/tile.dart';

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

  int maxTilesNumber = 20;
  int gridColumns = 4;

  List<bool> gridModel;
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

    tiles = new List();

    for (var i = 0; i < maxTilesNumber; i++) {
      int row = (i / gridColumns).floor();
      int col = i % gridColumns;

      tiles.add(Tile(
        row: row,
        col: col,
        width: 1,
        height: 1,
      ));
    }

    initData();
  }

  void initData() {
    tiles.forEach((tile) {
      tile.selected = false;
    });

    rowSelected = new Set();
    colSelected = new Set();
  }

  void cancelAdd() {
    initData();

    gridMode = GridMode.VIEW;
    setState(() {});
  }

  void deleteTile(int row, int col) {
    var tileIndex = row * gridColumns + col;

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

  void addSelectionToGrid({bool isAdd = true}) {
    if (isAdd) {
      var minCol = colSelected.toList().reduce(min);
      var maxCol = colSelected.toList().reduce(max);

      var minRow = rowSelected.toList().reduce(min);
      var maxRow = rowSelected.toList().reduce(max);

      var width = (maxCol - minCol) + 1;
      var height = (maxRow - minRow) + 1;

      Tile tile;

      tile = tiles.where((t) => t.col == minCol && t.row == minRow).toList()[0];

      tile.saved = true;

      setTileSize(tile, minRow, minCol, width, height);
    }

    cancelAdd();
  }

  Widget build(BuildContext context) {
    final viewBottomBar = Row(
      children: <Widget>[
        IconButton(
            onPressed: () {
              print("help");
            },
            icon: Icon(
              Icons.help_outline,
              color: Colors.white,
            )),
        Spacer(),
        IconButton(
            onPressed: () {
              setState(() {
                gridMode =
                    gridMode == GridMode.ADD ? GridMode.VIEW : GridMode.ADD;
              });
            },
            icon: Icon(
              gridMode == GridMode.ADD ? Icons.view_list : Icons.add,
              color: Colors.white,
            )),
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
            onPressed: selectionIsOk ? addSelectionToGrid : null,
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
          title: Text("LoveBugs"),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    mode =
                        mode == ViewMode.GRID ? ViewMode.LIST : ViewMode.GRID;
                  });
                },
                icon: Icon(
                    mode == ViewMode.GRID ? Icons.dashboard : Icons.view_list))
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

                        //int row = (index / gridColumns).floor();
                        //int col = index % gridColumns;

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
                            tileColor = idleColor;
                            tileIcon = idleIcon;
                            break;
                        }

                        return InkWell(
                          onTap: () {
                            if (gridMode == GridMode.VIEW) {
                              return;
                            }

                            if (currentTile.saved) {
                              // Cannot select an already saved tile
                              return;
                            }

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
                              colSpan = colSelectedList.reduce(max) -
                                  colSelectedList.reduce(min) +
                                  1;
                            }

                            if (rowSelectedList.length > 0) {
                              rowSpan = rowSelectedList.reduce(max) -
                                  rowSelectedList.reduce(min) +
                                  1;
                            }

                            selectionIsOk = colSpan * rowSpan == selectedTiles;

                            setState(() {});
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
