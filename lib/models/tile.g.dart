// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tile _$TileFromJson(Map<String, dynamic> json) {
  return Tile(
    row: json['row'] as int,
    col: json['col'] as int,
    width: json['width'] as int,
    height: json['height'] as int,
    selected: json['selected'] as bool,
    saved: json['saved'] as bool,
    category: Tile.categoryFromJson(json['category'] as String),
    text: json['text'] as String,
  )..when =
      json['when'] == null ? null : DateTime.parse(json['when'] as String);
}

Map<String, dynamic> _$TileToJson(Tile instance) => <String, dynamic>{
      'row': instance.row,
      'col': instance.col,
      'width': instance.width,
      'height': instance.height,
      'selected': instance.selected,
      'saved': instance.saved,
      'text': instance.text,
      'category': Tile.categoryToJson(instance.category),
      'when': instance.when?.toIso8601String(),
    };
