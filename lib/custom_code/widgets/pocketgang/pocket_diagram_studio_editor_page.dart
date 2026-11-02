import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single Node on the Interactive Vector Canvas
class DiagramCanvasNode {
  final String id;
  String label;
  Offset position;
  Size size;
  Color color;
  String shapeType; // 'rect', 'rounded', 'diamond', 'circle', 'card'
  String? subtitle;

  DiagramCanvasNode({
    required this.id,
    required this.label,
    required this.position,
    this.size = const Size(140, 60),
    this.color = const Color(0xFF1E293B),
    this.shapeType = 'rounded',
    this.subtitle,
  });
}

/// Connector Edge between two DiagramCanvasNodes
class DiagramCanvasEdge {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final String? label;
  final Color color;

  DiagramCanvasEdge({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    this.label,
    this.color = const Color(0xFF38BDF8),
  });
}

/// 📐 POKET Interactive Diagram Studio & Whiteboard Editor Page
class PocketDiagramStudioEditorPage extends StatefulWidget {
  final String diagramTitle;
  final String templateKey;
  final String groupName;

  const PocketDiagramStudioEditorPage({
    super.key,
    required this.diagramTitle,
    required this.templateKey,
    required this.groupName,
  });

  static Future<void> open(
    BuildContext context, {
    required String diagramTitle,
    required String templateKey,
    required String groupName,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketDiagramStudioEditorPage(
          diagramTitle: diagramTitle,
          templateKey: templateKey,
          groupName: groupName,
        ),
      ),
    );
  }

  @override
  State<PocketDiagramStudioEditorPage> createState() =>
      _PocketDiagramStudioEditorPageState();
}

class _PocketDiagramStudioEditorPageState
    extends State<PocketDiagramStudioEditorPage> {
  final TransformationController _transformCtrl = TransformationController();
  final List<DiagramCanvasNode> _nodes = [];
  final List<DiagramCanvasEdge> _edges = [];

  String? _selectedNodeId;
  bool _isGridVisible = true;

  @override
  void initState() {
    super.initState();
    _loadTemplatePreset(widget.templateKey);
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  /// Populate sample editable topology based on the selected template
  void _loadTemplatePreset(String key) {
    _nodes.clear();
    _edges.clear();

    if (key == 'flowchart' || key.isEmpty) {
      _nodes.addAll([
        DiagramCanvasNode(
            id: 'n1',
            label: 'User Sign Up / Login',
            position: const Offset(120, 80),
            color: const Color(0xFF10B981),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'n2',
            label: 'Verify Email & Consent',
            position: const Offset(120, 200),
            color: const Color(0xFFF59E0B),
            shapeType: 'diamond'),
        DiagramCanvasNode(
            id: 'n3',
            label: 'Select PocketGang Mode',
            position: const Offset(120, 340),
            color: const Color(0xFF38BDF8),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'n4',
            label: 'Launch Modular Workspace',
            position: const Offset(120, 480),
            color: const Color(0xFFA855F7),
            shapeType: 'rounded'),
      ]);
      _edges.addAll([
        DiagramCanvasEdge(
            id: 'e1',
            sourceNodeId: 'n1',
            targetNodeId: 'n2',
            label: 'Submit credentials'),
        DiagramCanvasEdge(
            id: 'e2',
            sourceNodeId: 'n2',
            targetNodeId: 'n3',
            label: 'Authorized'),
        DiagramCanvasEdge(
            id: 'e3',
            sourceNodeId: 'n3',
            targetNodeId: 'n4',
            label: 'Gang Initialized'),
      ]);
    } else if (key == 'mindmap') {
      _nodes.addAll([
        DiagramCanvasNode(
            id: 'c',
            label: 'POKET Ecosystem',
            position: const Offset(200, 240),
            color: const Color(0xFFFFD700),
            shapeType: 'circle',
            size: const Size(110, 110)),
        DiagramCanvasNode(
            id: 'm1',
            label: 'Individual Workspace',
            position: const Offset(40, 80),
            color: const Color(0xFF38BDF8),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'm2',
            label: 'Couple Shared Life',
            position: const Offset(360, 80),
            color: const Color(0xFFF43F5E),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'm3',
            label: 'Friends & Team Gang',
            position: const Offset(40, 400),
            color: const Color(0xFF10B981),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'm4',
            label: 'English Learning Hub',
            position: const Offset(360, 400),
            color: const Color(0xFFA855F7),
            shapeType: 'rounded'),
      ]);
      _edges.addAll([
        DiagramCanvasEdge(id: 'e1', sourceNodeId: 'c', targetNodeId: 'm1'),
        DiagramCanvasEdge(id: 'e2', sourceNodeId: 'c', targetNodeId: 'm2'),
        DiagramCanvasEdge(id: 'e3', sourceNodeId: 'c', targetNodeId: 'm3'),
        DiagramCanvasEdge(id: 'e4', sourceNodeId: 'c', targetNodeId: 'm4'),
      ]);
    } else {
      // General architecture diagram
      _nodes.addAll([
        DiagramCanvasNode(
            id: 'a1',
            label: 'Flutter Mobile & Web Client',
            position: const Offset(100, 100),
            color: const Color(0xFF0284C7),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'a2',
            label: 'Supabase Realtime API Gateway',
            position: const Offset(100, 260),
            color: const Color(0xFF10B981),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'a3',
            label: 'PostgreSQL Tables & RLS Policies',
            position: const Offset(100, 420),
            color: const Color(0xFF6366F1),
            shapeType: 'rounded'),
      ]);
      _edges.addAll([
        DiagramCanvasEdge(
            id: 'ea1',
            sourceNodeId: 'a1',
            targetNodeId: 'a2',
            label: 'HTTPS & WSS Broadcast'),
        DiagramCanvasEdge(
            id: 'ea2',
            sourceNodeId: 'a2',
            targetNodeId: 'a3',
            label: 'Row Level Security'),
      ]);
    }
  }

  void _addNewNode() {
    HapticFeedback.lightImpact();
    setState(() {
      final newId = 'node_${DateTime.now().millisecondsSinceEpoch}';
      _nodes.add(
        DiagramCanvasNode(
          id: newId,
          label: 'New Concept Node',
          position: const Offset(180, 180),
          color: const Color(0xFF1E293B),
        ),
      );
      _selectedNodeId = newId;
    });
  }

  void _editSelectedNodeLabel() {
    if (_selectedNodeId == null) return;
    final node = _nodes.firstWhere((n) => n.id == _selectedNodeId);
    final ctrl = TextEditingController(text: node.label);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Node Label',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter node title...',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF38BDF8))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => node.label = ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black),
            child: const Text('SAVE',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.diagramTitle,
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 5),
                Text(
                  '${widget.groupName} · 3 Collaborators Online',
                  style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
                _isGridVisible ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                color: Colors.white70,
                size: 20),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _isGridVisible = !_isGridVisible);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded,
                color: Color(0xFFFFD700), size: 22),
            onPressed: () {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '📥 Exporting Diagram to PNG & PDF... (Autosaved to Team Hub)'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Infinite Interactive Vector Canvas
          InteractiveViewer(
            transformationController: _transformCtrl,
            boundaryMargin: const EdgeInsets.all(1000),
            minScale: 0.3,
            maxScale: 3.0,
            child: SizedBox(
              width: 2500,
              height: 2500,
              child: Stack(
                children: [
                  // 1. Grid Background
                  if (_isGridVisible)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DiagramGridPainter(),
                      ),
                    ),

                  // 2. Vector Edge Connectors
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiagramEdgesPainter(
                        nodes: _nodes,
                        edges: _edges,
                      ),
                    ),
                  ),

                  // 3. Draggable Nodes
                  ..._nodes.map((node) {
                    final isSelected = _selectedNodeId == node.id;

                    return Positioned(
                      left: node.position.dx,
                      top: node.position.dy,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedNodeId = node.id);
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            node.position += details.delta;
                          });
                        },
                        child: Container(
                          width: node.size.width,
                          height: node.size.height,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: node.color,
                            borderRadius: node.shapeType == 'circle'
                                ? BorderRadius.circular(node.size.width / 2)
                                : BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white24,
                              width: isSelected ? 2.5 : 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 14,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            node.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Floating Tools Dock
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDockButton(
                      icon: Icons.add_circle_outline,
                      label: 'Add Node',
                      onTap: _addNewNode),
                  _buildDockButton(
                    icon: Icons.edit_note_rounded,
                    label: 'Edit Text',
                    onTap:
                        _selectedNodeId != null ? _editSelectedNodeLabel : null,
                  ),
                  _buildDockButton(
                    icon: Icons.palette_outlined,
                    label: 'Color',
                    onTap: () {
                      if (_selectedNodeId == null) return;
                      final node =
                          _nodes.firstWhere((n) => n.id == _selectedNodeId);
                      final colors = [
                        const Color(0xFF0284C7),
                        const Color(0xFF10B981),
                        const Color(0xFFF59E0B),
                        const Color(0xFFF43F5E),
                        const Color(0xFFA855F7),
                        const Color(0xFF1E293B),
                      ];
                      setState(() {
                        final nextIndex =
                            (colors.indexOf(node.color) + 1) % colors.length;
                        node.color = colors[nextIndex];
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                  _buildDockButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      if (_selectedNodeId == null) return;
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _edges.removeWhere((e) =>
                            e.sourceNodeId == _selectedNodeId ||
                            e.targetNodeId == _selectedNodeId);
                        _nodes.removeWhere((n) => n.id == _selectedNodeId);
                        _selectedNodeId = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color color = const Color(0xFF38BDF8),
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isEnabled ? color : Colors.white24, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isEnabled ? Colors.white70 : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Canvas Grid Painter
class _DiagramGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramGridPainter oldDelegate) => false;
}

/// Canvas Vector Connectors Painter
class _DiagramEdgesPainter extends CustomPainter {
  final List<DiagramCanvasNode> nodes;
  final List<DiagramCanvasEdge> edges;

  _DiagramEdgesPainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final edge in edges) {
      final source = nodes.where((n) => n.id == edge.sourceNodeId).firstOrNull;
      final target = nodes.where((n) => n.id == edge.targetNodeId).firstOrNull;
      if (source == null || target == null) continue;

      paint.color = edge.color;

      final start = Offset(source.position.dx + source.size.width / 2,
          source.position.dy + source.size.height / 2);
      final end = Offset(target.position.dx + target.size.width / 2,
          target.position.dy + target.size.height / 2);

      // Smooth curved bezier spline
      final path = Path();
      path.moveTo(start.dx, start.dy);
      final midY = (start.dy + end.dy) / 2;
      path.cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);
      canvas.drawPath(path, paint);

      // Arrow head indicator
      final angle = math.atan2(end.dy - midY, end.dx - end.dx);
      final arrowP1 =
          end - Offset(math.cos(angle - 0.5) * 12, math.sin(angle - 0.5) * 12);
      final arrowP2 =
          end - Offset(math.cos(angle + 0.5) * 12, math.sin(angle + 0.5) * 12);
      final arrowPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(arrowP1.dx, arrowP1.dy)
        ..lineTo(arrowP2.dx, arrowP2.dy)
        ..close();
      canvas.drawPath(
          arrowPath,
          Paint()
            ..color = edge.color
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramEdgesPainter oldDelegate) => true;
}
