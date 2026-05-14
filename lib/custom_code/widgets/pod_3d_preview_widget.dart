import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// A WebView-based 3D product preview using Three.js.
/// Renders a GLB model and applies a design image as a texture.
/// Falls back to a styled flat preview if the GLB fails to load.
class Pod3DPreviewWidget extends StatefulWidget {
  final String glbUrl;
  final String? designImageUrl;
  final String productSlug;
  final double width;
  final double height;
  final bool autoRotate;

  const Pod3DPreviewWidget({
    super.key,
    required this.glbUrl,
    this.designImageUrl,
    required this.productSlug,
    required this.width,
    required this.height,
    this.autoRotate = true,
  });

  @override
  State<Pod3DPreviewWidget> createState() => Pod3DPreviewWidgetState();
}

class Pod3DPreviewWidgetState extends State<Pod3DPreviewWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A0A))
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage msg) {
          debugPrint('[POD-3D] JS message: ${msg.message}');
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadHtmlString(_buildHtml());
  }

  /// Apply a new design texture dynamically (call from parent after upload)
  Future<void> applyDesign(String designUrl) async {
    await _controller.runJavaScript('applyDesignTexture("$designUrl")');
  }

  /// Toggle auto-rotation
  Future<void> setAutoRotate(bool value) async {
    await _controller.runJavaScript('setAutoRotate(${value ? 'true' : 'false'})');
  }

  String _buildHtml() {
    final glbUrl = widget.glbUrl.isNotEmpty ? widget.glbUrl : '';
    final designUrl = widget.designImageUrl ?? '';

    return '''<!DOCTYPE html>
<html style="margin:0;padding:0;background:#0a0a0a;overflow:hidden">
<head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{overflow:hidden;background:#0a0a0a}
  canvas{display:block;width:100%!important;height:100%!important}
  #loading{position:fixed;top:0;left:0;width:100%;height:100%;display:flex;
    flex-direction:column;align-items:center;justify-content:center;
    background:#0a0a0a;z-index:20}
  #loadRing{width:44px;height:44px;border:3px solid #1a1a1a;
    border-top-color:#ffa000;border-radius:50%;animation:spin 0.8s linear infinite}
  @keyframes spin{to{transform:rotate(360deg)}}
  #loadLabel{color:#ffa000;font-family:sans-serif;font-size:11px;
    letter-spacing:3px;margin-top:14px}
  #badge{position:fixed;bottom:12px;left:50%;transform:translateX(-50%);
    background:rgba(255,160,0,0.1);border:1px solid rgba(255,160,0,0.25);
    color:#ffa000;font-family:sans-serif;font-size:10px;letter-spacing:2px;
    padding:4px 12px;border-radius:20px;pointer-events:none}
</style>
</head>
<body>
<div id="loading"><div id="loadRing"></div><div id="loadLabel">LOADING 3D</div></div>
<div id="badge">DRAG TO ROTATE</div>

<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/loaders/GLTFLoader.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/controls/OrbitControls.js"></script>
<script>
const W = window.innerWidth, H = window.innerHeight;
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x0a0a0a);

const camera = new THREE.PerspectiveCamera(40, W/H, 0.01, 100);
camera.position.set(0, 0.1, 2.8);

const renderer = new THREE.WebGLRenderer({antialias:true, alpha:false});
renderer.setSize(W, H);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.3;
renderer.shadowMap.enabled = true;
document.body.appendChild(renderer.domElement);

// Lighting
const ambient = new THREE.AmbientLight(0xffffff, 2.0); scene.add(ambient);
const key = new THREE.DirectionalLight(0xffffff, 2.5);
key.position.set(2, 4, 5); key.castShadow = true; scene.add(key);
const fill = new THREE.DirectionalLight(0xffa000, 0.4);
fill.position.set(-3, -1, -2); scene.add(fill);
const rim = new THREE.DirectionalLight(0x4488ff, 0.3);
rim.position.set(0, 5, -5); scene.add(rim);

// Controls
const controls = new THREE.OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.06;
controls.autoRotate = ${widget.autoRotate};
controls.autoRotateSpeed = 1.2;
controls.enablePan = false;
controls.minDistance = 1.2;
controls.maxDistance = 6;
controls.minPolarAngle = Math.PI * 0.1;
controls.maxPolarAngle = Math.PI * 0.85;

let printMeshes = [];
const glbUrl = "${glbUrl.replaceAll('"', '\\"')}";
const initialDesign = "${designUrl.replaceAll('"', '\\"')}";

function hideBadge() {
  setTimeout(() => {
    const b = document.getElementById('badge');
    if(b) b.style.opacity = '0';
  }, 3000);
}

function hideLoading() {
  const el = document.getElementById('loading');
  if (el) { el.style.transition = 'opacity 0.4s'; el.style.opacity = '0';
    setTimeout(() => el.remove(), 400); }
}

function fitModel(model) {
  const box = new THREE.Box3().setFromObject(model);
  const center = box.getCenter(new THREE.Vector3());
  const size = box.getSize(new THREE.Vector3());
  const maxDim = Math.max(size.x, size.y, size.z);
  model.position.sub(center);
  model.scale.setScalar(1.8 / maxDim);
}

function collectPrintMeshes(model) {
  model.traverse(child => {
    if (child.isMesh) {
      child.material = child.material.clone();
      child.receiveShadow = true;
      child.castShadow = true;
      printMeshes.push(child);
    }
  });
}

function applyDesignTexture(url) {
  if (!url) return;
  new THREE.TextureLoader().load(url, tex => {
    tex.colorSpace = THREE.SRGBColorSpace;
    tex.flipY = false;
    printMeshes.forEach(m => {
      m.material.map = tex;
      m.material.needsUpdate = true;
    });
  }, undefined, err => console.warn('Texture load failed:', err));
}
window.applyDesignTexture = applyDesignTexture;
window.setAutoRotate = v => { controls.autoRotate = v; };
window.resetDesign = () => { printMeshes.forEach(m => { m.material.map = null; m.material.needsUpdate = true; }); };

function buildFallbackMesh() {
  // Stylized flat preview — used when no GLB or loading fails
  const geo = new THREE.PlaneGeometry(1.2, 1.5, 1, 1);
  const mat = new THREE.MeshStandardMaterial({color:0x222222, roughness:0.9, metalness:0.05});
  const mesh = new THREE.Mesh(geo, mat);
  scene.add(mesh);

  // Amber border frame
  const frameShape = new THREE.Shape();
  const w=0.64, h=0.79, r=0.05;
  frameShape.moveTo(-w+r,-h); frameShape.lineTo(w-r,-h);
  frameShape.quadraticCurveTo(w,-h,w,-h+r); frameShape.lineTo(w,h-r);
  frameShape.quadraticCurveTo(w,h,w-r,h); frameShape.lineTo(-w+r,h);
  frameShape.quadraticCurveTo(-w,h,-w,h-r); frameShape.lineTo(-w,-h+r);
  frameShape.quadraticCurveTo(-w,-h,-w+r,-h);
  const hole = new THREE.Path();
  const iw=0.60, ih=0.75, ir=0.04;
  hole.moveTo(-iw+ir,-ih); hole.lineTo(iw-ir,-ih);
  hole.quadraticCurveTo(iw,-ih,iw,-ih+ir); hole.lineTo(iw,ih-ir);
  hole.quadraticCurveTo(iw,ih,iw-ir,ih); hole.lineTo(-iw+ir,ih);
  hole.quadraticCurveTo(-iw,ih,-iw,ih-ir); hole.lineTo(-iw,-ih+ir);
  hole.quadraticCurveTo(-iw,-ih,-iw+ir,-ih);
  frameShape.holes.push(hole);
  const frameGeo = new THREE.ShapeGeometry(frameShape);
  const frameMat = new THREE.MeshStandardMaterial({color:0xffa000, roughness:0.4, metalness:0.3});
  const frame = new THREE.Mesh(frameGeo, frameMat);
  frame.position.z = 0.001; scene.add(frame);

  printMeshes = [mesh];
  if (initialDesign) applyDesignTexture(initialDesign);
  hideLoading(); hideBadge();
}

function loadGLB() {
  if (!glbUrl) { buildFallbackMesh(); return; }
  const loader = new THREE.GLTFLoader();
  loader.load(glbUrl,
    gltf => {
      fitModel(gltf.scene);
      collectPrintMeshes(gltf.scene);
      scene.add(gltf.scene);
      if (initialDesign) applyDesignTexture(initialDesign);
      hideLoading(); hideBadge();
    },
    undefined,
    () => buildFallbackMesh()
  );
}

function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

loadGLB();
animate();

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});
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
