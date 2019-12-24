import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/category.dart';
import '../models/tile.dart';

class AddTileDialog extends StatefulWidget {
  final void Function(bool, String, Category) onDispose;
  final Tile tile;
  final bool readonly;

  AddTileDialog({this.readonly = false, this.tile, this.onDispose});

  AddTileDialogState createState() {
    return AddTileDialogState();
  }
}

class AddTileDialogState extends State<AddTileDialog> {
  List<Category> categories = Category.getAll();
  Category selectedCategory;
  bool formIsValid = false;
  String note = "";
  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();
  }

  void saveTile() {
    widget.onDispose(true, note, selectedCategory);
  }

  Widget build(BuildContext context) {
    formIsValid = selectedCategory != null && note != "";

    if (widget.tile != null) {
      print(widget.tile.text);
      textController.text = widget.tile.text;
      note = widget.tile.text;
      selectedCategory = widget.tile.category;
    }

    final readOnlyBottom = [
      Expanded(
        child: RaisedButton(
          child: Text("Chiudi",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          color: Colors.blue,
          onPressed: () {
            widget.onDispose(true, "", null);
          },
        ),
      )
    ];

    final canEditBottom = [
      Expanded(
        child: RaisedButton(
          child: Text("Annulla",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          color: Colors.red,
          onPressed: () {
            widget.onDispose(false, "", null);
          },
        ),
      ),
      SizedBox(width: 20.0),
      Expanded(
        child: RaisedButton(
          child: Text("Salva",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          color: Colors.green,
          onPressed: formIsValid ? saveTile : null,
        ),
      )
    ];

    return Material(
        color: Colors.blue.withAlpha(80),
        child: InkWell(
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {},
            child: Center(
              child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                      color: Color(0xffeeeeee),
                      borderRadius: BorderRadius.circular(10)),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        widget.readonly
                            ? "Rivedi LoveTile"
                            : "Aggiungi LoveTile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Nota",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Color(0xff2980b9),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 15.0),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          readOnly: widget.readonly,
                          maxLines: 8,
                          onChanged: (text) {
                            note = text;
                            setState(() {});
                          },
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            hintText:
                                "Aggiunti una nota a questa LoveTile (per non dimenticarti <3)",
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Categoria",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Color(0xff2980b9),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10.0),
                      Expanded(
                          child: StaggeredGridView.countBuilder(
                        crossAxisCount: 4,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          Category category = categories[index];

                          bool isSelected = selectedCategory != null &&
                              selectedCategory.name == category.name;

                          return InkWell(
                            onTap: () {
                              if (widget.readonly) {
                                return;
                              }

                              if (selectedCategory != null &&
                                  selectedCategory == category) {
                                selectedCategory = null;
                              } else {
                                selectedCategory = category;
                              }

                              setState(() {});
                            },
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? category.color : Colors.white,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Icon(
                                category.icon,
                                color:
                                    isSelected ? Colors.white : category.color,
                              ),
                            ),
                          );
                        },
                        staggeredTileBuilder: (int index) {
                          return StaggeredTile.count(1, 1);
                        },
                      )),
                      SizedBox(height: 10.0),
                      Text(
                        selectedCategory != null
                            ? selectedCategory.name
                            : "Nessun categoria selezionata",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      widget.readonly
                          ? Padding(
                              padding: EdgeInsets.only(bottom: 15.0),
                              child: Text(
                                "Quando: ${widget.tile.formatWhen()}",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Color(0xff2980b9),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ))
                          : Container(),
                      Row(
                        children:
                            widget.readonly ? readOnlyBottom : canEditBottom,
                      )
                    ],
                  )),
            )));
  }
}
