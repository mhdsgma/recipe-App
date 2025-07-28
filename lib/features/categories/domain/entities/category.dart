import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final Color color;

  Category({
    required this.id,
    required this.name,
    this.imageUrl = "",
    required this.color,
  });


  factory Category.fromJson(Map<String, dynamic> json, String id) {
    print("--- Category.fromJson: Parsing category with ID: $id ---");
    print("--- Category.fromJson: Raw JSON data: $json ---");

    final String retrievedName = json["name "] ?? 
                               json["name"] ?? 
                               json["Name"] ?? 
                               json["NAME"] ?? 
                               "<NAME NOT FOUND>";
    print("--- Category.fromJson: Retrieved name: $retrievedName ---");

    final String retrievedImageUrl = json["imageUrl "] ?? 
                                   json["imageUrl"] ?? 
                                   json["image_url"] ?? 
                                   json["image"] ?? 
                                   "";
    print("--- Category.fromJson: Retrieved imageUrl: $retrievedImageUrl ---");

    final String colorHex = json["colorHex"] ?? 
                          json["color"] ?? 
                          json["color_hex"] ?? 
                          "#CCCCCC";
    print("--- Category.fromJson: Retrieved colorHex: $colorHex ---");

    try {
      final category = Category(
        id: id,
        name: retrievedName,
        imageUrl: retrievedImageUrl,
        color: _colorFromHex(colorHex),
      );
      print("--- Category.fromJson: Successfully created category: ${category.name} ---");
      return category;
    } catch (e) {
      print("!!! ERROR creating category: $e");
      print("!!! Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }

  get colorHex => null;


  Map<String, dynamic> toJson() {

    return {
      "name": name.trim(),
      "imageUrl": imageUrl.trim(),
      "colorHex": '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
    };
  }


  static Color _colorFromHex(String hexColor) {
    print("--- _colorFromHex: Converting color: $hexColor ---");
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    try {
      final color = Color(int.parse(hexColor, radix: 16));
      print("--- _colorFromHex: Successfully converted to color: $color ---");
      return color;
    } catch (e) {
      print("!!! ERROR parsing color: $hexColor, defaulting to grey");
      print("!!! Stack trace: ${StackTrace.current}");
      return Colors.grey;
    }
  }
}

