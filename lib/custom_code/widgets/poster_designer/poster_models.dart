import 'package:flutter/material.dart';

enum ElementType { text, image, shape, sticker }

class DesignElement {
  final String id;
  final ElementType type;
  Offset position;
  Size size;
  double rotation;

  // Text properties
  String? text;
  TextStyle? textStyle;
  TextAlign? textAlign;

  // Image properties
  String? imageUrl;

  // Shape/Color properties
  Color color;
  double? borderRadius;

  DesignElement({
    required this.id,
    required this.type,
    this.position = const Offset(100, 100),
    this.size = const Size(200, 100),
    this.rotation = 0,
    this.text,
    this.textStyle,
    this.textAlign = TextAlign.center,
    this.imageUrl,
    this.color = Colors.white,
    this.borderRadius,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'x': position.dx,
      'y': position.dy,
      'width': size.width,
      'height': size.height,
      'rotation': rotation,
      'text': text,
      'fontSize': textStyle?.fontSize,
      'color': color.value,
      'imageUrl': imageUrl,
      'fontWeight': textStyle?.fontWeight?.index,
      'fontFamily': textStyle?.fontFamily,
    };
  }

  factory DesignElement.fromJson(Map<String, dynamic> json) {
    return DesignElement(
      id: json['id'],
      type: ElementType.values.firstWhere((e) => e.toString() == json['type']),
      position: Offset(json['x']?.toDouble() ?? 0, json['y']?.toDouble() ?? 0),
      size: Size(
          json['width']?.toDouble() ?? 100, json['height']?.toDouble() ?? 100),
      rotation: json['rotation']?.toDouble() ?? 0,
      text: json['text'],
      imageUrl: json['imageUrl'],
      color: Color(json['color'] ?? 0xFFFFFFFF),
      textStyle: TextStyle(
        fontSize: json['fontSize']?.toDouble(),
        fontFamily: json['fontFamily'],
        fontWeight: json['fontWeight'] != null
            ? FontWeight.values[json['fontWeight']]
            : null,
      ),
    );
  }

  DesignElement copyWith({
    Offset? position,
    Size? size,
    double? rotation,
    String? text,
    TextStyle? textStyle,
    Color? color,
  }) {
    return DesignElement(
      id: id,
      type: type,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      imageUrl: imageUrl,
      color: color ?? this.color,
      borderRadius: borderRadius,
    );
  }
}

class PosterDesign {
  final String? id;
  final String title;
  final List<DesignElement> elements;
  final Color backgroundColor;
  final String? backgroundImageUrl;

  PosterDesign({
    this.id,
    required this.title,
    required this.elements,
    this.backgroundColor = Colors.black,
    this.backgroundImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'elements': elements.map((e) => e.toJson()).toList(),
      'backgroundColor': backgroundColor.value,
      'backgroundImageUrl': backgroundImageUrl,
    };
  }

  factory PosterDesign.fromJson(Map<String, dynamic> json) {
    return PosterDesign(
      id: json['id'],
      title: json['title'] ?? 'Untitled Design',
      backgroundColor: Color(json['backgroundColor'] ?? 0xFF000000),
      backgroundImageUrl: json['backgroundImageUrl'],
      elements: (json['elements'] as List? ?? [])
          .map((e) => DesignElement.fromJson(e))
          .toList(),
    );
  }
}
