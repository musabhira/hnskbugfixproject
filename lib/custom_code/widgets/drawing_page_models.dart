import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ── Enums ──
enum BrushType { pen, marker, pencil, airbrush, watercolor, chalk, charcoal, calligraphy, glow, fill, sprinkle }
enum ShapeTool { line, rectangle, circle, triangle, arrow, star, pentagon, hexagon }
enum DrawingTool { brush, eraser, lasso, shape, eyedropper, fillBucket, smudge, transform, symmetry }
enum SymmetryMode { none, horizontal, vertical, quad, radial }

// ── Brush Info ──
class BrushInfo {
  final String id, name, category;
  final BrushType type;
  final double defaultSize, defaultOpacity, flow, spacing;
  const BrushInfo({required this.id, required this.name, required this.category, required this.type, this.defaultSize = 4.0, this.defaultOpacity = 1.0, this.flow = 1.0, this.spacing = 0.1});
}

const List<String> brushCategories = ['New','Favorites','Recent','Pencils','Pens','Calligraphy','Markers','Paint','Watercolor','Sprayers','Chalks','Charcoals','Design','Fills','Glow'];

const List<BrushInfo> allBrushes = [
  // Favorites
  BrushInfo(id:'proko_pencil',name:'Proko Pencil',category:'Favorites',type:BrushType.pencil,defaultSize:2.0,defaultOpacity:0.6),
  BrushInfo(id:'gesture_vine',name:'Gesture Vine',category:'Favorites',type:BrushType.pencil,defaultSize:6.0,defaultOpacity:0.5),
  BrushInfo(id:'pilot_pen',name:'Pilot Pen',category:'Favorites',type:BrushType.pen,defaultSize:3.0),
  BrushInfo(id:'manga_inker',name:'Manga Inker',category:'Favorites',type:BrushType.pen,defaultSize:2.5),
  BrushInfo(id:'dry_ink_marker',name:'Dry Ink Marker',category:'Favorites',type:BrushType.marker,defaultSize:8.0,defaultOpacity:0.8),
  BrushInfo(id:'fine_blender',name:'Fine Blender',category:'Favorites',type:BrushType.airbrush,defaultSize:10.0,defaultOpacity:0.3),
  BrushInfo(id:'soft_airbrush',name:'Soft Airbrush',category:'Favorites',type:BrushType.airbrush,defaultSize:15.0,defaultOpacity:0.4),
  // Pencils
  BrushInfo(id:'hb_pencil',name:'HB Pencil',category:'Pencils',type:BrushType.pencil,defaultSize:1.5,defaultOpacity:0.7),
  BrushInfo(id:'2b_pencil',name:'2B Pencil',category:'Pencils',type:BrushType.pencil,defaultSize:3.0,defaultOpacity:0.55),
  BrushInfo(id:'6b_pencil',name:'6B Pencil',category:'Pencils',type:BrushType.pencil,defaultSize:5.0,defaultOpacity:0.45),
  BrushInfo(id:'mech_pencil',name:'Mechanical Pencil',category:'Pencils',type:BrushType.pencil,defaultSize:1.0,defaultOpacity:0.8),
  BrushInfo(id:'sketch_pencil',name:'Sketch Pencil',category:'Pencils',type:BrushType.pencil,defaultSize:2.5,defaultOpacity:0.65),
  BrushInfo(id:'col_pencil',name:'Color Pencil',category:'Pencils',type:BrushType.pencil,defaultSize:3.0,defaultOpacity:0.6),
  // Pens
  BrushInfo(id:'solid_pen',name:'Solid Pen',category:'Pens',type:BrushType.pen,defaultSize:2.0),
  BrushInfo(id:'soft_pen',name:'Soft Pen',category:'Pens',type:BrushType.pen,defaultSize:3.0,defaultOpacity:0.9),
  BrushInfo(id:'fine_tip',name:'Fine Tip Pen',category:'Pens',type:BrushType.pen,defaultSize:1.0),
  BrushInfo(id:'tapered_inker',name:'Tapered Inker',category:'Pens',type:BrushType.pen,defaultSize:4.0),
  BrushInfo(id:'old_inker',name:'Old Inker',category:'Pens',type:BrushType.pen,defaultSize:3.5,defaultOpacity:0.85),
  BrushInfo(id:'coarse_inker',name:'Coarse Inker',category:'Pens',type:BrushType.pen,defaultSize:5.0,defaultOpacity:0.9),
  BrushInfo(id:'tech_pen',name:'Technical Pen',category:'Pens',type:BrushType.pen,defaultSize:1.5),
  // Calligraphy
  BrushInfo(id:'script',name:'Script',category:'Calligraphy',type:BrushType.calligraphy,defaultSize:5.0,defaultOpacity:0.9),
  BrushInfo(id:'flat_nib',name:'Flat Nib',category:'Calligraphy',type:BrushType.calligraphy,defaultSize:6.0),
  BrushInfo(id:'pointed_nib',name:'Pointed Nib',category:'Calligraphy',type:BrushType.calligraphy,defaultSize:3.5),
  BrushInfo(id:'brush_pen',name:'Brush Pen',category:'Calligraphy',type:BrushType.calligraphy,defaultSize:8.0,defaultOpacity:0.85),
  // Markers
  BrushInfo(id:'broad_marker',name:'Broad Marker',category:'Markers',type:BrushType.marker,defaultSize:12.0,defaultOpacity:0.75),
  BrushInfo(id:'fine_marker',name:'Fine Marker',category:'Markers',type:BrushType.marker,defaultSize:4.0,defaultOpacity:0.85),
  BrushInfo(id:'chisel_marker',name:'Chisel Marker',category:'Markers',type:BrushType.marker,defaultSize:10.0,defaultOpacity:0.7),
  BrushInfo(id:'highlight_marker',name:'Highlighter',category:'Markers',type:BrushType.marker,defaultSize:14.0,defaultOpacity:0.4),
  // Paint
  BrushInfo(id:'round_brush',name:'Round Brush',category:'Paint',type:BrushType.marker,defaultSize:12.0,defaultOpacity:0.85),
  BrushInfo(id:'flat_brush',name:'Flat Brush',category:'Paint',type:BrushType.marker,defaultSize:16.0,defaultOpacity:0.9),
  BrushInfo(id:'palette_knife',name:'Palette Knife',category:'Paint',type:BrushType.marker,defaultSize:20.0,defaultOpacity:0.7),
  BrushInfo(id:'oil_brush',name:'Oil Brush',category:'Paint',type:BrushType.marker,defaultSize:14.0,defaultOpacity:0.8),
  // Watercolor
  BrushInfo(id:'wet_wash',name:'Wet Wash',category:'Watercolor',type:BrushType.watercolor,defaultSize:18.0,defaultOpacity:0.35),
  BrushInfo(id:'dry_wash',name:'Dry Wash',category:'Watercolor',type:BrushType.watercolor,defaultSize:14.0,defaultOpacity:0.45),
  BrushInfo(id:'splatter',name:'Splatter',category:'Watercolor',type:BrushType.watercolor,defaultSize:20.0,defaultOpacity:0.3),
  // Sprayers
  BrushInfo(id:'spray_can',name:'Spray Can',category:'Sprayers',type:BrushType.airbrush,defaultSize:25.0,defaultOpacity:0.25),
  BrushInfo(id:'mist',name:'Mist',category:'Sprayers',type:BrushType.airbrush,defaultSize:30.0,defaultOpacity:0.15),
  BrushInfo(id:'speckle',name:'Speckle',category:'Sprayers',type:BrushType.airbrush,defaultSize:20.0,defaultOpacity:0.35),
  // Chalks
  BrushInfo(id:'soft_chalk',name:'Soft Chalk',category:'Chalks',type:BrushType.chalk,defaultSize:10.0,defaultOpacity:0.5),
  BrushInfo(id:'hard_chalk',name:'Hard Chalk',category:'Chalks',type:BrushType.chalk,defaultSize:6.0,defaultOpacity:0.65),
  BrushInfo(id:'pastel',name:'Pastel',category:'Chalks',type:BrushType.chalk,defaultSize:12.0,defaultOpacity:0.45),
  // Charcoals
  BrushInfo(id:'vine_charcoal',name:'Vine Charcoal',category:'Charcoals',type:BrushType.charcoal,defaultSize:8.0,defaultOpacity:0.5),
  BrushInfo(id:'compressed',name:'Compressed',category:'Charcoals',type:BrushType.charcoal,defaultSize:6.0,defaultOpacity:0.7),
  BrushInfo(id:'willow',name:'Willow',category:'Charcoals',type:BrushType.charcoal,defaultSize:10.0,defaultOpacity:0.4),
  // Design
  BrushInfo(id:'grid_pen',name:'Grid Pen',category:'Design',type:BrushType.pen,defaultSize:1.0),
  BrushInfo(id:'dotted',name:'Dotted Line',category:'Design',type:BrushType.pen,defaultSize:2.0,defaultOpacity:0.8,spacing:0.5),
  // Fills
  BrushInfo(id:'bucket_fill',name:'Bucket Fill',category:'Fills',type:BrushType.fill,defaultSize:1.0),
  BrushInfo(id:'grad_fill',name:'Gradient Fill',category:'Fills',type:BrushType.fill,defaultSize:1.0,defaultOpacity:0.8),
  // Glow
  BrushInfo(id:'soft_glow',name:'Soft Glow',category:'Glow',type:BrushType.glow,defaultSize:15.0,defaultOpacity:0.4),
  BrushInfo(id:'neon',name:'Neon',category:'Glow',type:BrushType.glow,defaultSize:4.0,defaultOpacity:0.9),
  BrushInfo(id:'star_glow',name:'Star Glow',category:'Glow',type:BrushType.glow,defaultSize:20.0,defaultOpacity:0.3),
];

// ── Drawing Models ──
class DrawingPoint {
  final Offset offset;
  final double pressure;
  DrawingPoint(this.offset, this.pressure);

  Map<String, dynamic> toJson() => {'dx': offset.dx, 'dy': offset.dy, 'p': pressure};
  factory DrawingPoint.fromJson(Map<String, dynamic> j) => DrawingPoint(Offset(j['dx'], j['dy']), j['p']);
}

class DrawingStroke {
  final Color color;
  final double strokeWidth;
  final List<DrawingPoint> points;
  final bool isEraser;
  final double opacity;
  final BrushType brushType;
  final ShapeTool? shapeType;
  final Offset? shapeEnd;
  final bool isFilled;
  final ui.Image? fillImage;
  final Offset? fillOffset;

  DrawingStroke({
    required this.color,
    required this.strokeWidth,
    required this.points,
    this.isEraser = false,
    this.opacity = 1.0,
    this.brushType = BrushType.pen,
    this.shapeType,
    this.shapeEnd,
    this.isFilled = false,
    this.fillImage,
    this.fillOffset,
  });

  Map<String, dynamic> toJson() => {
    'c': color.value,
    'w': strokeWidth,
    'pts': points.map((p) => p.toJson()).toList(),
    'e': isEraser,
    'o': opacity,
    'bt': brushType.index,
    'st': shapeType?.index,
    'se': shapeEnd != null ? {'dx': shapeEnd!.dx, 'dy': shapeEnd!.dy} : null,
    'f': isFilled,
    'fo': fillOffset != null ? {'dx': fillOffset!.dx, 'dy': fillOffset!.dy} : null,
  };

  factory DrawingStroke.fromJson(Map<String, dynamic> j) => DrawingStroke(
    color: Color(j['c']),
    strokeWidth: j['w'],
    points: (j['pts'] as List).map((p) => DrawingPoint.fromJson(p)).toList(),
    isEraser: j['e'] ?? false,
    opacity: j['o'] ?? 1.0,
    brushType: BrushType.values[j['bt'] ?? 0],
    shapeType: j['st'] != null ? ShapeTool.values[j['st']] : null,
    shapeEnd: j['se'] != null ? Offset(j['se']['dx'], j['se']['dy']) : null,
    isFilled: j['f'] ?? false,
    fillOffset: j['fo'] != null ? Offset(j['fo']['dx'], j['fo']['dy']) : null,
  );
}

class DrawingLayer {
  String id, name;
  bool isVisible, isLocked;
  double opacity;
  List<DrawingStroke> strokes;
  List<DrawingStroke> redoStack;
  Color? backgroundColor;
  ui.Image? importedImage;
  Offset imageOffset;
  double imageScale;

  DrawingLayer({required this.id, required this.name, this.isVisible = true, this.isLocked = false, this.opacity = 1.0, List<DrawingStroke>? strokes, this.backgroundColor, this.importedImage, this.imageOffset = Offset.zero, this.imageScale = 1.0})
      : strokes = strokes ?? [], redoStack = [];

  Map<String, dynamic> toJson() => {
    'id': id, 'n': name, 'v': isVisible, 'l': isLocked, 'o': opacity,
    's': strokes.map((s) => s.toJson()).toList(),
    'bg': backgroundColor?.value,
  };

  factory DrawingLayer.fromJson(Map<String, dynamic> j) => DrawingLayer(
    id: j['id'],
    name: j['n'],
    isVisible: j['v'] ?? true,
    isLocked: j['l'] ?? false,
    opacity: j['o'] ?? 1.0,
    strokes: (j['s'] as List).map((s) => DrawingStroke.fromJson(s)).toList(),
    backgroundColor: j['bg'] != null ? Color(j['bg']) : null,
  );
}

class TextOverlay {
  String id, text;
  Offset position;
  Color color;
  double fontSize, rotation;
  TextStyle style;
  TextOverlay({required this.id, required this.text, required this.position, required this.color, this.fontSize = 20.0, this.rotation = 0.0, required this.style});
}

class ImageOverlay {
  String id;
  Uint8List bytes;
  Offset position;
  double scale, rotation;
  ImageOverlay({required this.id, required this.bytes, this.position = Offset.zero, this.scale = 1.0, this.rotation = 0.0});
}
