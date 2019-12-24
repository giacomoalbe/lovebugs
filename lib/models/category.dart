import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  String name;
  Color color;
  IconData icon;

  static List<Category> getAll() {
    return [
      Category(
        name: "Sorprese",
        color: Color(0xffff7675),
        icon: FontAwesomeIcons.surprise,
      ),
      Category(
        name: "Parole Vere e Dolci",
        color: Color(0xfffdcb6e),
        icon: FontAwesomeIcons.birthdayCake,
      ),
      Category(
        name: "Abbracci nei momenti di sconforto",
        color: Color(0xff55efc4),
        icon: FontAwesomeIcons.peopleCarry,
      ),
      Category(
        name: "Semplificare la vita",
        color: Color(0xffa29bfe),
        icon: FontAwesomeIcons.clipboardList,
      ),
      Category(
        name: "Le sigarette",
        color: Color(0xff2d3436),
        icon: FontAwesomeIcons.smoking,
      ),
      Category(
        name: "Amore improvviso",
        color: Color(0xffd63031),
        icon: FontAwesomeIcons.grinHearts,
      ),
      Category(
        name: "Ascoltare",
        color: Color(0xff00b894),
        icon: FontAwesomeIcons.assistiveListeningSystems,
      ),
      Category(
        name: "Dare segni di vita & rispondere",
        color: Color(0xff00cec9),
        icon: FontAwesomeIcons.lifeRing,
      ),
    ];
  }

  Category({this.name, this.color, this.icon});
}
