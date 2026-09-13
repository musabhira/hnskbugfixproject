import 'package:flutter/material.dart';

enum ElementType { text, image, shape, sticker }

class DesignElement {
  final String id;
  final ElementType type;
  Offset position;
  Size size;
  double rotation;
  double opacity;

  // Text properties
  String? text;
  TextStyle? textStyle;
  TextAlign? textAlign;
  Color? textBackgroundColor;

  // Image properties
  String? imageUrl;

  // Shape/Color/Sticker properties
  Color color;
  double? borderRadius;
  IconData? stickerIcon;
  BoxShape shapeType;

  DesignElement({
    required this.id,
    required this.type,
    this.position = const Offset(100, 100),
    this.size = const Size(200, 100),
    this.rotation = 0,
    this.opacity = 1.0,
    this.text,
    this.textStyle,
    this.textAlign = TextAlign.center,
    this.textBackgroundColor,
    this.imageUrl,
    this.color = Colors.white,
    this.borderRadius,
    this.stickerIcon,
    this.shapeType = BoxShape.rectangle,
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
      'opacity': opacity,
      'text': text,
      'fontSize': textStyle?.fontSize,
      'color': color.toARGB32(),
      'imageUrl': imageUrl,
      'fontWeight': textStyle?.fontWeight?.index,
      'fontFamily': textStyle?.fontFamily,
      'letterSpacing': textStyle?.letterSpacing,
      'borderRadius': borderRadius,
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
      opacity: json['opacity']?.toDouble() ?? 1.0,
      text: json['text'],
      imageUrl: json['imageUrl'],
      color: Color(json['color'] ?? 0xFFFFFFFF),
      borderRadius: json['borderRadius']?.toDouble(),
      textStyle: TextStyle(
        fontSize: json['fontSize']?.toDouble(),
        fontFamily: json['fontFamily'],
        letterSpacing: json['letterSpacing']?.toDouble(),
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
    double? opacity,
    String? text,
    TextStyle? textStyle,
    TextAlign? textAlign,
    Color? textBackgroundColor,
    Color? color,
    double? borderRadius,
    IconData? stickerIcon,
    BoxShape? shapeType,
  }) {
    return DesignElement(
      id: id,
      type: type,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      textAlign: textAlign ?? this.textAlign,
      textBackgroundColor: textBackgroundColor ?? this.textBackgroundColor,
      imageUrl: imageUrl,
      color: color ?? this.color,
      borderRadius: borderRadius ?? this.borderRadius,
      stickerIcon: stickerIcon ?? this.stickerIcon,
      shapeType: shapeType ?? this.shapeType,
    );
  }
}

class PosterDesign {
  final String? id;
  String title;
  final List<DesignElement> elements;
  Color backgroundColor;
  List<Color>? backgroundGradient;
  String? backgroundImageUrl;
  double aspectRatio; // 3/4 (Flyer), 9/16 (Story), 1/1 (Post), 16/9 (Banner)

  PosterDesign({
    this.id,
    required this.title,
    required this.elements,
    this.backgroundColor = Colors.black,
    this.backgroundGradient,
    this.backgroundImageUrl,
    this.aspectRatio = 3 / 4,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'elements': elements.map((e) => e.toJson()).toList(),
      'backgroundColor': backgroundColor.toARGB32(),
      'backgroundGradient':
          backgroundGradient?.map((c) => c.toARGB32()).toList(),
      'backgroundImageUrl': backgroundImageUrl,
      'aspectRatio': aspectRatio,
    };
  }

  factory PosterDesign.fromJson(Map<String, dynamic> json) {
    return PosterDesign(
      id: json['id'],
      title: json['title'] ?? 'Untitled Design',
      backgroundColor: Color(json['backgroundColor'] ?? 0xFF000000),
      backgroundGradient: json['backgroundGradient'] != null
          ? (json['backgroundGradient'] as List)
              .map((c) => Color(c as int))
              .toList()
          : null,
      backgroundImageUrl: json['backgroundImageUrl'],
      aspectRatio: json['aspectRatio']?.toDouble() ?? 3 / 4,
      elements: (json['elements'] as List? ?? [])
          .map((e) => DesignElement.fromJson(e))
          .toList(),
    );
  }
}
