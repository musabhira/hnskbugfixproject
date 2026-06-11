import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'drawing_page.dart';

class DrawingAppHome extends StatefulWidget {
  const DrawingAppHome({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<DrawingAppHome> createState() => _DrawingAppHomeState();
}

class _DrawingAppHomeState extends State<DrawingAppHome> {
  List<File> _recentDrawings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentDrawings();
  }

  Future<void> _loadRecentDrawings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final drawingDir = Directory('${directory.path}/saved_drawings');
      if (await drawingDir.exists()) {
        final files = drawingDir.listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.png'))
            .toList()
          ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        
        if (mounted) {
          setState(() {
            _recentDrawings = files;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading recent drawings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          _buildActionCards(theme),
          _buildRecentHeader(theme),
          _buildRecentGrid(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCanvasSelectionDialog(context),
        backgroundColor: Color(0xFFFFFC00),
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text('New Masterpiece', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildSliverAppBar(FlutterFlowTheme theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('My Creative Studio', 
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFC00).withValues(alpha: 0.2), Colors.black],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCards(FlutterFlowTheme theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: _actionCard(
                'New Canvas', 
                Icons.add_photo_alternate_rounded, 
                Color(0xFFFFFC00), 
                () => _showCanvasSelectionDialog(context)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _actionCard(
                'Tutorials', 
                Icons.school_rounded, 
                Colors.blueAccent, 
                () => {} // Navigate to Academy
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader(FlutterFlowTheme theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Artworks', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
            if (_recentDrawings.isNotEmpty)
              TextButton(onPressed: () {}, child: Text('View Gallery', style: TextStyle(color: Color(0xFFFFFC00)))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGrid(FlutterFlowTheme theme) {
    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00))));
    }
    
    if (_recentDrawings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.palette_outlined, color: Colors.white10, size: 80),
              const SizedBox(height: 16),
              Text('No drawings yet.', style: GoogleFonts.outfit(color: Colors.white24)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showCanvasSelectionDialog(context), 
                child: const Text('Start Creating')
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final file = _recentDrawings[index];
            return _buildDrawingCard(file);
          },
          childCount: _recentDrawings.length,
        ),
      ),
    );
  }

  Widget _buildDrawingCard(File file) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => DrawingPage(sessionPath: file.path.replaceAll('.png', '.json')))
        );
        _loadRecentDrawings(); // Reload on return
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), 
              blurRadius: 15, 
              offset: const Offset(0, 8),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => _confirmDelete(file),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFileName(file.path),
                    style: GoogleFonts.outfit(
                      color: Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFFFFC00), size: 10),
                      const SizedBox(width: 4),
                      Text(
                        '${file.lastModifiedSync().day}/${file.lastModifiedSync().month} · ${_getTimeAgo(file.lastModifiedSync())}',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).moveY(begin: 30, end: 0, curve: Curves.easeOutCubic),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _confirmDelete(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Delete Drawing?', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('This will permanently remove this masterpiece.', style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep it')),
          TextButton(
            onPressed: () async {
              try {
                await file.delete();
                final jsonFile = File(file.path.replaceAll('.png', '.json'));
                if (await jsonFile.exists()) await jsonFile.delete();
                if (mounted) Navigator.pop(context);
                _loadRecentDrawings();
              } catch (e) {}
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _getFileName(String path) {
    final name = path.split('/').last.split('\\').last;
    return name.replaceAll('sketch_', '').replaceAll('.png', '');
  }

  void _showCanvasSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true,
      builder: (context) => _CanvasSelectionSheet(
        onSelected: (width, height) {
          Navigator.pop(context);
          _startNewDrawing(context, width, height);
        },
      ),
    );
  }

  void _startNewDrawing(BuildContext context, [double? width, double? height]) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DrawingPage(
          canvasWidth: width,
          canvasHeight: height,
        )
      )
    );
  }
}

class _CanvasSelectionSheet extends StatefulWidget {
  final Function(double, double) onSelected;
  const _CanvasSelectionSheet({required this.onSelected});

  @override
  State<_CanvasSelectionSheet> createState() => _CanvasSelectionSheetState();
}

class _CanvasSelectionSheetState extends State<_CanvasSelectionSheet> {
  final TextEditingController _widthController = TextEditingController(text: '1080');
  final TextEditingController _heightController = TextEditingController(text: '1080');
  String _selectedPreset = 'Square';

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Square', 'w': 1080.0, 'h': 1080.0, 'icon': Icons.crop_square},
    {'name': 'Portrait', 'w': 1080.0, 'h': 1920.0, 'icon': Icons.stay_current_portrait},
    {'name': 'Landscape', 'w': 1920.0, 'h': 1080.0, 'icon': Icons.stay_current_landscape},
    {'name': '4K Quad', 'w': 3840.0, 'h': 2160.0, 'icon': Icons.four_k_rounded},
    {'name': 'HD Pro', 'w': 2560.0, 'h': 1440.0, 'icon': Icons.high_quality_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Canvas Size',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a preset or enter custom dimensions',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final p = _presets[index];
                final isSelected = _selectedPreset == p['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPreset = p['name'];
                      _widthController.text = p['w'].toInt().toString();
                      _heightController.text = p['h'].toInt().toString();
                    });
                  },
                  child: AnimatedContainer(
                    duration: 300.ms,
                    width: 100,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFFFFC00).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Color(0xFFFFFC00) : Colors.white10,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          p['icon'],
                          color: isSelected ? Color(0xFFFFFC00) : Colors.white54,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p['name'],
                          style: GoogleFonts.outfit(
                            color: isSelected ? Color(0xFFFFFC00) : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _customField('Width (px)', _widthController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _customField('Height (px)', _heightController),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                final w = double.tryParse(_widthController.text) ?? 1080.0;
                final h = double.tryParse(_heightController.text) ?? 1080.0;
                widget.onSelected(w, h);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFC00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start Project',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _customField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (v) {
            setState(() {
              _selectedPreset = 'Custom';
            });
          },
        ),
      ],
    );
  }
}

