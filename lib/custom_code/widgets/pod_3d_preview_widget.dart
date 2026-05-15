import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// A WebView-based 3D product preview using Three.js.
/// Renders a GLB model and applies a design image as a texture.
/// Supports interactive positioning (Decals).
class Pod3DPreviewWidget extends StatefulWidget {
  final String glbUrl;
  final String? localGlbPath;
  final String? designImageUrl;
  final String productSlug;
  final double width;
  final double height;
  final bool autoRotate;
  final Function(double x, double y, double z, double scale, double rot)? onCoordinatesChanged;

  const Pod3DPreviewWidget({
    super.key,
    required this.glbUrl,
    this.localGlbPath,
    this.designImageUrl,
    required this.productSlug,
    required this.width,
    required this.height,
    this.autoRotate = true,
    this.onCoordinatesChanged,
  });

  @override
  State<Pod3DPreviewWidget> createState() => Pod3DPreviewWidgetState();
}

class Pod3DPreviewWidgetState extends State<Pod3DPreviewWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _glbBase64;

  @override
  void initState() {
    super.initState();
    _initController();
    _loadGlb();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A0A))
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage msg) {
          if (msg.message.startsWith('COORDS:')) {
            final parts = msg.message.substring(7).split(',');
            if (parts.length == 5) {
              widget.onCoordinatesChanged?.call(
                double.tryParse(parts[0]) ?? 0,
                double.tryParse(parts[1]) ?? 0,
                double.tryParse(parts[2]) ?? 0,
                double.tryParse(parts[3]) ?? 1,
                double.tryParse(parts[4]) ?? 0,
              );
            }
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
      ));
  }

  Future<void> _loadGlb() async {
    if (widget.localGlbPath != null) {
      try {
        final data = await rootBundle.load(widget.localGlbPath!);
        final bytes = data.buffer.asUint8List();
        _glbBase64 = base64Encode(bytes);
      } catch (e) {
        debugPrint('[POD-3D] Error loading local GLB: $e');
      }
    }
    _controller.loadHtmlString(_buildHtml());
  }

  /// Apply a new design texture dynamically
  Future<void> applyDesign(String designUrl) async {
    await _controller.runJavaScript('applyDesignTexture("$designUrl")');
  }

  /// Update decal scale dynamically
  Future<void> updateScale(double scale) async {
    await _controller.runJavaScript('window.updateDecalScale($scale)');
  }

  String _buildHtml() {
    final designUrl = widget.designImageUrl ?? '';
    final glbData = _glbBase64 != null ? 'data:model/gltf-binary;base64,$_glbBase64' : widget.glbUrl;

    return '''<!DOCTYPE html>
<html style="margin:0;padding:0;background:#0a0a0a;overflow:hidden">
<head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
  *{margin:0;padding:0;box-sizing:border-box;user-select:none}
  body{overflow:hidden;background:#0a0a0a;touch-action:none}
  canvas{display:block;width:100%!important;height:100%!important}
  #loading{position:fixed;top:0;left:0;width:100%;height:100%;display:flex;
    flex-direction:column;align-items:center;justify-content:center;
    background:#0a0a0a;z-index:20}
  #loadRing{width:44px;height:44px;border:3px solid #1a1a1a;
    border-top-color:#ffa000;border-radius:50%;animation:spin 0.8s linear infinite}
  @keyframes spin{to{transform:rotate(360deg)}}
  #loadLabel{color:#ffa000;font-family:sans-serif;font-size:11px;
    letter-spacing:3px;margin-top:14px}
  #controls-hint{position:fixed;bottom:12px;left:50%;transform:translateX(-50%);
    background:rgba(255,160,0,0.1);border:1px solid rgba(255,160,0,0.25);
    color:#ffa000;font-family:sans-serif;font-size:10px;letter-spacing:1px;
    padding:6px 16px;border-radius:20px;pointer-events:none;white-space:nowrap;
    transition:opacity 0.5s;z-index:10}
</style>
</head>
<body>
<div id="loading"><div id="loadRing"></div><div id="loadLabel">PREPARING 3D</div></div>
<div id="controls-hint">DRAG TO POSITION • PINCH TO SCALE</div>

<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/loaders/GLTFLoader.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/controls/OrbitControls.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/geometries/DecalGeometry.js"></script>

<script>
const W = window.innerWidth, H = window.innerHeight;
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x0a0a0a);

const camera = new THREE.PerspectiveCamera(40, W/H, 0.01, 100);
camera.position.set(0, 0.1, 2.5);

const renderer = new THREE.WebGLRenderer({antialias:true, alpha:false});
renderer.setSize(W, H);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.2;
document.body.appendChild(renderer.domElement);

// Lighting
scene.add(new THREE.AmbientLight(0xffffff, 2.2));
const key = new THREE.DirectionalLight(0xffffff, 1.5);
key.position.set(2, 4, 5); scene.add(key);

const controls = new THREE.OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.autoRotate = ${widget.autoRotate};
controls.autoRotateSpeed = 1.0;
controls.enablePan = false;
controls.minDistance = 1.2;
controls.maxDistance = 4;

let mainMesh = null;
let decalMesh = null;
let decalTexture = null;
const decalPos = new THREE.Vector3(0, 0.1, 0.5);
const decalSize = new THREE.Vector3(0.4, 0.4, 0.4);
const decalRot = new THREE.Euler(0, 0, 0);

const glbUrl = "${glbData.replaceAll('"', '\\"')}";
const initialDesign = "${designUrl.replaceAll('"', '\\"')}";

function updateDecal() {
  if (!mainMesh || !decalTexture) return;
  if (decalMesh) scene.remove(decalMesh);

  const geometry = new THREE.DecalGeometry(mainMesh, decalPos, decalRot, decalSize);
  const material = new THREE.MeshStandardMaterial({
    map: decalTexture,
    transparent: true,
    depthTest: true,
    depthWrite: false,
    polygonOffset: true,
    polygonOffsetFactor: -4,
    roughness: 0.8,
    metalness: 0.1
  });

  decalMesh = new THREE.Mesh(geometry, material);
  scene.add(decalMesh);

  if (window.FlutterBridge) {
    window.FlutterBridge.postMessage(`COORDS:\${decalPos.x},\${decalPos.y},\${decalPos.z},\${decalSize.x},\${decalRot.z}`);
  }
}

window.updateDecalScale = function(s) {
  decalSize.set(s, s, s);
  updateDecal();
};

function applyDesignTexture(url) {
  if (!url) return;
  new THREE.TextureLoader().load(url, tex => {
    tex.colorSpace = THREE.SRGBColorSpace;
    decalTexture = tex;
    updateDecal();
  });
}

function fitModel(model) {
  const box = new THREE.Box3().setFromObject(model);
  const size = box.getSize(new THREE.Vector3());
  const maxDim = Math.max(size.x, size.y, size.z);
  model.scale.setScalar(1.8 / maxDim);
  
  model.traverse(child => {
    if (child.isMesh) {
      child.material = child.material.clone();
      if (!mainMesh) mainMesh = child; 
    }
  });
}

// Interaction logic for moving the decal
let isDragging = false;
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

function onTouch(e) {
  const t = (e.touches && e.touches.length > 0) ? e.touches[0] : e;
  const rect = renderer.domElement.getBoundingClientRect();
  mouse.x = ((t.clientX - rect.left) / rect.width) * 2 - 1;
  mouse.y = -((t.clientY - rect.top) / rect.height) * 2 + 1;
  
  raycaster.setFromCamera(mouse, camera);
  // Intersect the whole scene to find a mesh
  const intersects = raycaster.intersectObjects(scene.children, true);
  
  // Find first mesh that isn't the decal itself
  const hit = intersects.find(i => i.object.isMesh && i.object !== decalMesh);
  
  if (hit) {
    mainMesh = hit.object;
    decalPos.copy(hit.point);
    updateDecal();
    controls.enabled = false;
    isDragging = true;
    document.getElementById('controls-hint').style.opacity = '0';
  }
}

window.addEventListener('mousedown', onTouch);
window.addEventListener('touchstart', onTouch);
window.addEventListener('mouseup', () => { controls.enabled = true; isDragging = false; });
window.addEventListener('touchend', () => { controls.enabled = true; isDragging = false; });

window.addEventListener('mousemove', (e) => {
  if (!isDragging) return;
  onTouch(e);
});
window.addEventListener('touchmove', (e) => {
  if (!isDragging) return;
  onTouch(e);
});

function loadGLB() {
  if (!glbUrl) { hideLoading(); return; }
  const loader = new THREE.GLTFLoader();
  loader.load(glbUrl, gltf => {
    fitModel(gltf.scene);
    scene.add(gltf.scene);
    if (initialDesign) applyDesignTexture(initialDesign);
    hideLoading();
  }, undefined, err => {
    console.error('GLB error:', err);
    hideLoading();
  });
}

function hideLoading() {
  const el = document.getElementById('loading');
  if (el) { el.style.opacity = '0'; setTimeout(() => el.remove(), 400); }
}

window.applyDesignTexture = applyDesignTexture;
loadGLB();

function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}
animate();
</script>
</body></html>''';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            if (_glbBase64 != null || widget.glbUrl.isNotEmpty)
              WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: const Color(0xFF0A0A0A),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 36, height: 36,
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFA000), strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('LOADING 3D',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFA000),
                          fontSize: 10, letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
