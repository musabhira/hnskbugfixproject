import '../../services/pocketgang_chat_share_service.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'dx': position.dx,
        'dy': position.dy,
        'width': size.width,
        'height': size.height,
        'color': color.toARGB32(),
        'shapeType': shapeType,
        'subtitle': subtitle,
      };

  factory DiagramCanvasNode.fromJson(Map<String, dynamic> json) =>
      DiagramCanvasNode(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        position: Offset((json['dx'] as num?)?.toDouble() ?? 100.0,
            (json['dy'] as num?)?.toDouble() ?? 100.0),
        size: Size((json['width'] as num?)?.toDouble() ?? 140.0,
            (json['height'] as num?)?.toDouble() ?? 60.0),
        color: json['color'] != null
            ? Color((json['color'] as num).toInt())
            : const Color(0xFF1E293B),
        shapeType: json['shapeType']?.toString() ?? 'rounded',
        subtitle: json['subtitle']?.toString(),
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceNodeId': sourceNodeId,
        'targetNodeId': targetNodeId,
        'label': label,
        'color': color.toARGB32(),
      };

  factory DiagramCanvasEdge.fromJson(Map<String, dynamic> json) =>
      DiagramCanvasEdge(
        id: json['id']?.toString() ?? '',
        sourceNodeId: json['sourceNodeId']?.toString() ?? '',
        targetNodeId: json['targetNodeId']?.toString() ?? '',
        label: json['label']?.toString(),
        color: json['color'] != null
            ? Color((json['color'] as num).toInt())
            : const Color(0xFF38BDF8),
      );
}

/// 📐 POKET Interactive Diagram Studio & Whiteboard Editor Page
class PocketDiagramStudioEditorPage extends StatefulWidget {
  final String diagramId;
  final String diagramTitle;
  final String templateKey;
  final String groupName;
  final String groupId;
  final String userId;

  const PocketDiagramStudioEditorPage({
    super.key,
    this.diagramId = '',
    required this.diagramTitle,
    required this.templateKey,
    required this.groupName,
    this.groupId = '',
    this.userId = '',
  });

  static Future<void> open(
    BuildContext context, {
    String diagramId = '',
    required String diagramTitle,
    required String templateKey,
    required String groupName,
    String groupId = '',
    String userId = '',
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketDiagramStudioEditorPage(
          diagramId: diagramId,
          diagramTitle: diagramTitle,
          templateKey: templateKey,
          groupName: groupName,
          groupId: groupId,
          userId: userId,
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDiagramData();
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDiagramData() async {
    // If diagramId & groupId provided, try loading from Supabase group_activities
    if (widget.groupId.isNotEmpty && widget.diagramId.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheKey = 'gang_diag_detail_${widget.groupId}_${widget.diagramId}';
        final cached = prefs.getString(cacheKey);

        if (cached != null) {
          final data = jsonDecode(cached);
          _parseDiagramJson(data);
        }

        final supabase = Supabase.instance.client;
        final res = await supabase
            .from('group_activities')
            .select('data')
            .eq('group_id', widget.groupId)
            .eq('activity_type', 'gang_diagram_${widget.diagramId}')
            .maybeSingle();

        if (res != null && res['data'] != null) {
          final data = res['data'];
          await prefs.setString(cacheKey, jsonEncode(data));
          _parseDiagramJson(data);
          return;
        }
      } catch (e) {
        debugPrint('Error loading cloud diagram data: $e');
      }
    }

    if (_nodes.isEmpty) {
      _loadTemplatePreset(widget.templateKey);
    }
  }

  void _parseDiagramJson(dynamic data) {
    if (data is Map && data['nodes'] is List) {
      final List nList = data['nodes'];
      final List eList = (data['edges'] as List?) ?? [];
      setState(() {
        _nodes.clear();
        _edges.clear();
        _nodes.addAll(nList
            .map((e) => DiagramCanvasNode.fromJson(Map<String, dynamic>.from(e))));
        _edges.addAll(eList
            .map((e) => DiagramCanvasEdge.fromJson(Map<String, dynamic>.from(e))));
      });
    }
  }

  Future<void> _saveDiagramToCloud() async {
    if (widget.groupId.isEmpty || widget.diagramId.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'gang_diag_detail_${widget.groupId}_${widget.diagramId}';
      final payload = {
        'id': widget.diagramId,
        'title': widget.diagramTitle,
        'template': widget.templateKey,
        'nodes': _nodes.map((n) => n.toJson()).toList(),
        'edges': _edges.map((e) => e.toJson()).toList(),
        'updated_by': widget.userId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await prefs.setString(cacheKey, jsonEncode(payload));

      final supabase = Supabase.instance.client;
      await supabase.from('group_activities').upsert({
        'group_id': widget.groupId,
        'activity_type': 'gang_diagram_${widget.diagramId}',
        'title': widget.diagramTitle,
        'data': payload,
        'created_by': widget.userId,
        'is_active': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('☁️ Diagram saved to Group Cloud!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving diagram to cloud: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _fitToScreen() {
    if (_nodes.isEmpty) {
      _resetZoom();
      return;
    }
    double minX = _nodes.first.position.dx;
    double maxX = _nodes.first.position.dx + _nodes.first.size.width;
    double minY = _nodes.first.position.dy;
    double maxY = _nodes.first.position.dy + _nodes.first.size.height;

    for (final n in _nodes) {
      if (n.position.dx < minX) minX = n.position.dx;
      if (n.position.dx + n.size.width > maxX) maxX = n.position.dx + n.size.width;
      if (n.position.dy < minY) minY = n.position.dy;
      if (n.position.dy + n.size.height > maxY) maxY = n.position.dy + n.size.height;
    }

    final diagWidth = (maxX - minX) + 120;
    final diagHeight = (maxY - minY) + 120;
    final screenSize = MediaQuery.of(context).size;

    final scaleX = screenSize.width / diagWidth;
    final scaleY = (screenSize.height - 180) / diagHeight;
    final targetScale = math.min(scaleX, scaleY).clamp(0.4, 1.8);

    final matrix = Matrix4.identity()
      ..translate(
        (screenSize.width - diagWidth * targetScale) / 2 - (minX - 60) * targetScale,
        (screenSize.height - diagHeight * targetScale) / 2 - (minY - 60) * targetScale,
      )
      ..scale(targetScale, targetScale);

    setState(() {
      _transformCtrl.value = matrix;
    });
    HapticFeedback.lightImpact();
  }

  void _resetZoom() {
    setState(() {
      _transformCtrl.value = Matrix4.identity();
    });
    HapticFeedback.lightImpact();
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
            position: const Offset(40, 100),
            color: const Color(0xFF38BDF8),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'm2',
            label: 'PocketGang Collaborative',
            position: const Offset(340, 100),
            color: const Color(0xFF10B981),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'm3',
            label: 'English 90-Day Citadel',
            position: const Offset(40, 380),
            color: const Color(0xFFF59E0B),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'm4',
            label: 'Gamified Ranking Trail',
            position: const Offset(340, 380),
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
      _nodes.addAll([
        DiagramCanvasNode(
            id: 'sys1',
            label: 'Mobile Client (Flutter)',
            position: const Offset(100, 120),
            color: const Color(0xFF38BDF8),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'sys2',
            label: 'Supabase Realtime Cloud',
            position: const Offset(100, 260),
            color: const Color(0xFF10B981),
            shapeType: 'rounded'),
        DiagramCanvasNode(
            id: 'sys3',
            label: 'Edge Functions & AI',
            position: const Offset(100, 400),
            color: const Color(0xFFFFD700),
            shapeType: 'rounded'),
      ]);
      _edges.addAll([
        DiagramCanvasEdge(id: 'se1', sourceNodeId: 'sys1', targetNodeId: 'sys2', label: 'WebSocket / REST'),
        DiagramCanvasEdge(id: 'se2', sourceNodeId: 'sys2', targetNodeId: 'sys3', label: 'RPC / Webhook'),
      ]);
    }
  }

  void _addNewNode() {
    HapticFeedback.lightImpact();
    final newId = 'n_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _nodes.add(DiagramCanvasNode(
        id: newId,
        label: 'New Step / Module',
        position: const Offset(160, 260),
        color: const Color(0xFF0284C7),
      ));
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
        title: Text('Edit Node Label',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter title...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                node.label = ctrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.diagramTitle,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.groupName} • Diagram Studio',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Grid',
            icon: Icon(
              _isGridVisible ? Icons.grid_on_rounded : Icons.grid_off_rounded,
              color: _isGridVisible ? const Color(0xFFFFD700) : Colors.white38,
              size: 20,
            ),
            onPressed: () => setState(() => _isGridVisible = !_isGridVisible),
          ),
          IconButton(
            tooltip: 'Save to Cloud',
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700)),
                  )
                : const Icon(Icons.cloud_upload_outlined, color: Color(0xFFFFD700), size: 22),
            onPressed: _isSaving ? null : _saveDiagramToCloud,
          ),
          if (widget.groupId.isNotEmpty)
            IconButton(
              tooltip: 'Share to Group Chat',
              icon: const Icon(Icons.share_rounded, color: Color(0xFFFFD700), size: 20),
              onPressed: () async {
                HapticFeedback.lightImpact();
                await _saveDiagramToCloud();
                final ok = await PocketGangChatShareService.instance.shareDiagramToGroupChat(
                  groupId: widget.groupId,
                  userId: widget.userId,
                  diagramId: widget.diagramId,
                  diagramTitle: widget.diagramTitle,
                  templateKey: widget.templateKey,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? '🚀 Diagram shared to Group Chat!' : 'Failed to share diagram.'),
                      backgroundColor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Responsive Unclipped Vector Canvas with smooth InteractiveViewer
          InteractiveViewer(
            transformationController: _transformCtrl,
            boundaryMargin: const EdgeInsets.all(2500),
            minScale: 0.2,
            maxScale: 3.5,
            clipBehavior: Clip.none,
            child: SizedBox(
              width: 3000,
              height: 3000,
              child: Stack(
                clipBehavior: Clip.none,
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

          // Floating Fit-to-Screen and Reset Zoom controls
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_fit',
                  tooltip: 'Fit to Screen',
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: const Color(0xFFFFD700),
                  onPressed: _fitToScreen,
                  child: const Icon(Icons.fullscreen_rounded, size: 20),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'fab_reset',
                  tooltip: 'Reset Zoom (100%)',
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white70,
                  onPressed: _resetZoom,
                  child: const Icon(Icons.center_focus_strong_rounded, size: 18),
                ),
              ],
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
