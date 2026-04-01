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
        onPressed: () => _startNewDrawing(context),
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text('New Drawing', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
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
              colors: [Colors.amber.withValues(alpha: 0.2), Colors.black],
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
                'Sketchpad', 
                Icons.brush_rounded, 
                Colors.amber, 
                () => _startNewDrawing(context)
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
              TextButton(onPressed: () {}, child: Text('View Gallery', style: TextStyle(color: Colors.amber.shade200))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGrid(FlutterFlowTheme theme) {
    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.amber)));
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
                onPressed: () => _startNewDrawing(context), 
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
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DrawingPage(sessionPath: file.path.replaceAll('.png', '.json'))));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFileName(file.path),
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Last modified: ${file.lastModifiedSync().day}/${file.lastModifiedSync().month}',
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).moveY(begin: 20, end: 0),
    );
  }

  String _getFileName(String path) {
    final name = path.split('/').last.split('\\').last;
    return name.replaceAll('sketch_', '').replaceAll('.png', '');
  }

  void _startNewDrawing(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawingPage()));
  }
}
