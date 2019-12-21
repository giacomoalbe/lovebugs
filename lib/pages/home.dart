import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
  int tilesNumber = 100;
  List<bool> gridModel;
  Set<int> rowSelected;
  Set<int> colSelected;

  void initState() {
    super.initState();

    mode = ViewMode.GRID;

    gridModel = List<bool>.filled(tilesNumber, false, growable: false);

    rowSelected = new Set();
    colSelected = new Set();
  }

  Widget build(BuildContext context) {
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
                      crossAxisCount: 4,
                      itemCount: tilesNumber,
                      itemBuilder: (BuildContext context, int index) {
                        var row = (index / 4).floor();
                        var col = index % 4;

                        var itemIsSelected = gridModel[index];

                        Color selectedColor;
                        Color idleColor = Colors.blue;
                        IconData selectedIcon;

                        if (selectionIsOk) {
                          selectedColor = Colors.green;
                          selectedIcon = Icons.check;
                        } else {
                          selectedColor = Colors.red;
                          selectedIcon = Icons.close;
                        }

                        var mainColor =
                            itemIsSelected ? selectedColor : idleColor;

                        return InkWell(
                          onTap: () {
                            if (!gridModel[index]) {
                              // Add tile
                              gridModel[index] = true;
                            } else {
                              // Remove tile
                              gridModel[index] = false;
                            }

                            var isRowSelected = false;
                            var isColSelected = false;

                            gridModel.asMap().forEach((i, tileSelected) {
                              var tileRow = (i / 4).floor();
                              var tileCol = i % 4;

                              if (tileRow == row) {
                                isRowSelected = isRowSelected || tileSelected;
                              }

                              if (tileCol == col) {
                                isColSelected = isColSelected || tileSelected;
                              }
                            });

                            if (isColSelected) {
                              colSelected.add(col);
                            } else {
                              colSelected.remove(col);
                            }

                            if (isRowSelected) {
                              rowSelected.add(row);
                            } else {
                              rowSelected.remove(row);
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

                            var selectedTiles = gridModel
                                .where((tileSelected) => tileSelected)
                                .length;

                            selectionIsOk = colSpan * rowSpan == selectedTiles;

                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                width: 4,
                                color: mainColor,
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
                                      color: mainColor,
                                      width: 4.0,
                                    )),
                                child: Center(
                                  child: Icon(
                                      itemIsSelected ? selectedIcon : Icons.add,
                                      color: mainColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      staggeredTileBuilder: (int index) {
                        return new StaggeredTile.count(1, 1);
                      },
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                    ))),
            Container(
              padding: EdgeInsets.all(10.0),
              color: Theme.of(context).primaryColor,
              child: Row(
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
                          gridMode = gridMode == GridMode.ADD
                              ? GridMode.VIEW
                              : GridMode.ADD;
                        });
                      },
                      icon: Icon(
                        gridMode == GridMode.ADD ? Icons.view_list : Icons.add,
                        color: Colors.white,
                      )),
                ],
              ),
            )
          ],
        ));
  }
}
