import { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import {
    X, MapPin, Mail, Phone, ShoppingBag,
    ArrowRight, MessageCircle, Star, Sparkles
} from 'lucide-react';

const Instagram = (props) => (
    <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        {...props}
    >
        <rect width="20" height="20" x="2" y="2" rx="5" ry="5" />
        <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
        <line x1="17.5" x2="17.51" y1="6.5" y2="6.5" />
    </svg>
);


import { motion, AnimatePresence } from 'framer-motion';

// Helper for dynamic colors
const hexToRgba = (hex, alpha) => {
    if (!hex) return `rgba(255,255,255,${alpha})`;
    let r = 0, g = 0, b = 0;
    if (hex.length === 4) {
        r = parseInt(hex[1] + hex[1], 16);
        g = parseInt(hex[2] + hex[2], 16);
        b = parseInt(hex[3] + hex[3], 16);
    } else if (hex.length >= 7) {
        r = parseInt(hex.slice(1, 3), 16);
        g = parseInt(hex.slice(3, 5), 16);
        b = parseInt(hex.slice(5, 7), 16);
    }
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};


const ItemDetailModal = ({ item, onClose, accentColor }) => {
    if (!item) return null;
    return (
        <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/90 backdrop-blur-xl"
            onClick={onClose}
        >
            <motion.div
                initial={{ scale: 0.9, y: 20 }}
                animate={{ scale: 1, y: 0 }}
                exit={{ scale: 0.9, y: 20 }}
                className="bg-[#0b0c10] border border-white/10 rounded-3xl max-w-2xl w-full max-h-[90vh] overflow-y-auto relative shadow-2xl"
                style={{ borderColor: hexToRgba(accentColor, 0.3) }}
                onClick={e => e.stopPropagation()}
            >
                <button onClick={onClose} className="absolute top-4 right-4 p-2 bg-black/50 hover:bg-white/10 rounded-full text-white z-10 border border-white/10">
                    <X className="w-6 h-6" />
                </button>
                {(item.gallery_image_url || item.image_url) && (
                    <div className="w-full h-80 relative">
                        <img src={item.gallery_image_url || item.image_url} alt="Detail" className="w-full h-full object-cover" />
                        <div className="absolute inset-0 bg-gradient-to-t from-[#0b0c10] to-transparent" />
                    </div>
                )}
                <div className="p-8">
                    <div className="flex items-center gap-3 mb-4">
                        <div 
                            className="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest border"
                            style={{ 
                                color: accentColor, 
                                borderColor: hexToRgba(accentColor, 0.3),
                                backgroundColor: hexToRgba(accentColor, 0.1)
                            }}
                        >
                            {item.gallery_category || item.category || (item.is_service ? 'Service' : 'Product')}
                        </div>
                    </div>
                    <h2 className="text-4xl font-bold text-white mb-4 tracking-tight">
                        {item.gallery_title || item.title || "Untitled"}
                    </h2>
                    <p className="text-gray-400 leading-relaxed text-lg mb-8">
                        {item.gallery_description || item.description || "No description provided."}
                    </p>
                    <div className="flex gap-4">
                        {(item.gallery_price || item.price) ? (
                            <div 
                                className="px-6 py-3 rounded-xl border flex items-center gap-3"
                                style={{ 
                                    borderColor: hexToRgba(accentColor, 0.3),
                                    backgroundColor: hexToRgba(accentColor, 0.05)
                                }}
                            >
                                <span className="text-xl font-bold" style={{ color: accentColor }}>₹{item.gallery_price || item.price}</span>
                            </div>
                        ) : null}
                    </div>
                </div>
            </motion.div>
        </motion.div>
    );
};

const ProfileThreeJS = ({ data }) => {
    const { profile, gallery = [], services = [], threads = [], banners = [] } = data;
    const [selectedItem, setSelectedItem] = useState(null);
    const [activeCategory, setActiveCategory] = useState('All');
    const containerRef = useRef(null);

    const accentColor = profile.button_color_code || '#FFD60A';
    const bgColor = profile.bg_color_code || '#0F0F12';
    const textColor = profile.bg_text_color || '#FFFFFF';

    // Mix products and services together under unified Showcase
    const combinedShowcase = [...gallery, ...services.map(s => ({ ...s, is_service: true }))];
    const categories = ['All', ...new Set(combinedShowcase.map(i => i.category || (i.is_service ? 'Services' : 'Products')))];
    const filteredShowcase = activeCategory === 'All' 
        ? combinedShowcase 
        : combinedShowcase.filter(i => (i.category || (i.is_service ? 'Services' : 'Products')) === activeCategory);

    useEffect(() => {
        if (!containerRef.current) return;

        // Scene set up
        const scene = new THREE.Scene();
        scene.fog = new THREE.FogExp2(bgColor, 0.02);

        const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        camera.position.z = 15;

        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        containerRef.current.appendChild(renderer.domElement);

        // Lights
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
        scene.add(ambientLight);

        const dirLight = new THREE.DirectionalLight(accentColor, 1.5);
        dirLight.position.set(5, 10, 7);
        scene.add(dirLight);

        // Particle System (3D Stars/Constellation)
        const particleCount = 250;
        const particleGeometry = new THREE.BufferGeometry();
        const positions = new Float32Array(particleCount * 3);

        for (let i = 0; i < particleCount * 3; i += 3) {
            positions[i] = (Math.random() - 0.5) * 45;
            positions[i + 1] = (Math.random() - 0.5) * 45;
            positions[i + 2] = (Math.random() - 0.5) * 45;
        }

        particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
        const particleMaterial = new THREE.PointsMaterial({
            color: new THREE.Color(accentColor),
            size: 0.18,
            transparent: true,
            opacity: 0.7
        });
        const particles = new THREE.Points(particleGeometry, particleMaterial);
        scene.add(particles);

        // Floating 3D Geometric shapes
        const shapes = [];
        const geometries = [
            new THREE.TorusGeometry(1.5, 0.4, 16, 100),
            new THREE.OctahedronGeometry(1.5),
            new THREE.ConeGeometry(1, 2, 4),
            new THREE.DodecahedronGeometry(1.2)
        ];

        const shapeMaterial = new THREE.MeshStandardMaterial({
            color: new THREE.Color(accentColor),
            metalness: 0.8,
            roughness: 0.2,
            wireframe: true
        });

        for (let i = 0; i < 8; i++) {
            const geom = geometries[i % geometries.length];
            const mesh = new THREE.Mesh(geom, shapeMaterial);
            mesh.position.set(
                (Math.random() - 0.5) * 30,
                (Math.random() - 0.5) * 20,
                (Math.random() - 0.5) * 10 - 5
            );
            mesh.rotation.set(Math.random() * Math.PI, Math.random() * Math.PI, 0);
            mesh.userData = {
                rotSpeedX: (Math.random() - 0.5) * 0.01,
                rotSpeedY: (Math.random() - 0.5) * 0.01
            };
            scene.add(mesh);
            shapes.push(mesh);
        }

        // Mouse Interactivity
        let mouseX = 0, mouseY = 0;
        const handleMouseMove = (e) => {
            mouseX = (e.clientX - window.innerWidth / 2) / 100;
            mouseY = (e.clientY - window.innerHeight / 2) / 100;
        };

        window.addEventListener('mousemove', handleMouseMove);

        // Resize handler
        const handleResize = () => {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        };
        window.addEventListener('resize', handleResize);

        // Animation Loop
        const clock = new THREE.Clock();
        const animate = () => {
            requestAnimationFrame(animate);
            const elapsedTime = clock.getElapsedTime();

            // Rotate Particle field
            particles.rotation.y = elapsedTime * 0.03;
            particles.rotation.x = elapsedTime * 0.01;

            // Parallax effect with mouse
            camera.position.x += (mouseX - camera.position.x) * 0.05;
            camera.position.y += (-mouseY - camera.position.y) * 0.05;
            camera.lookAt(scene.position);

            // Rotate floating meshes
            shapes.forEach(shape => {
                shape.rotation.x += shape.userData.rotSpeedX;
                shape.rotation.y += shape.userData.rotSpeedY;
                shape.position.y += Math.sin(elapsedTime + shape.position.x) * 0.005;
            });

            renderer.render(scene, camera);
        };

        animate();

        // Cleanup
        return () => {
            window.removeEventListener('mousemove', handleMouseMove);
            window.removeEventListener('resize', handleResize);
            if (renderer.domElement && containerRef.current) {
                containerRef.current.removeChild(renderer.domElement);
            }
            renderer.dispose();
        };
    }, [bgColor, accentColor]);

    return (
        <div 
            className="min-h-screen text-white font-sans overflow-x-hidden relative"
            style={{ backgroundColor: bgColor }}
        >
            {/* Three.js Background Canvas */}
            <div ref={containerRef} className="fixed inset-0 z-0 pointer-events-none opacity-40" />

            <AnimatePresence>
                {selectedItem && (
                    <ItemDetailModal 
                        item={selectedItem} 
                        onClose={() => setSelectedItem(null)} 
                        accentColor={accentColor} 
                    />
                )}
            </AnimatePresence>

            {/* Profile Content Overlay */}
            <div className="relative z-10">
                {/* Header/Hero Section */}
                <header className="max-w-7xl mx-auto px-6 pt-28 pb-16">
                    <div className="flex flex-col md:flex-row items-center gap-12">
                        {/* Avatar */}
                        <motion.div 
                            initial={{ scale: 0.9, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            className="relative"
                        >
                            <div 
                                className="absolute -inset-2 rounded-full blur-xl opacity-30 animate-pulse"
                                style={{ backgroundColor: accentColor }}
                            />
                            <div 
                                className="w-48 h-48 md:w-56 md:h-56 rounded-full p-1.5 bg-gradient-to-tr overflow-hidden shadow-2xl"
                                style={{ backgroundImage: `linear-gradient(to tr, ${accentColor}, transparent)` }}
                            >
                                <img 
                                    src={profile.profile_image_url} 
                                    alt={profile.name} 
                                    className="w-full h-full object-cover rounded-full bg-[#0b0c10]" 
                                />
                            </div>
                        </motion.div>

                        {/* Title Info */}
                        <div className="text-center md:text-left flex-1">
                            <motion.div
                                initial={{ y: 20, opacity: 0 }}
                                animate={{ y: 0, opacity: 1 }}
                                transition={{ delay: 0.1 }}
                            >
                                <div className="flex items-center justify-center md:justify-start gap-3 mb-4">
                                    <Sparkles className="w-5 h-5" style={{ color: accentColor }} />
                                    <span className="text-xs font-bold uppercase tracking-[0.25em] opacity-60">Interactive 3D Space</span>
                                </div>
                                <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-4 uppercase">
                                    {profile.shop_name || profile.name}
                                </h1>
                                <p className="text-lg text-gray-300 max-w-2xl mb-8 leading-relaxed">
                                    {profile.bio || "Handcrafted creation meets state-of-the-art interactive WebGL experience."}
                                </p>
                                <div className="flex flex-wrap gap-4 justify-center md:justify-start">
                                    <button 
                                        onClick={() => window.open(`https://wa.me/${profile.phone_no}`, '_blank')}
                                        className="px-8 py-3.5 rounded-xl font-bold uppercase text-sm tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition-all"
                                        style={{ backgroundColor: accentColor, color: profile.button_text_color || '#000000' }}
                                    >
                                        Inquire Now
                                    </button>
                                </div>
                            </motion.div>
                        </div>
                    </div>
                </header>

                {/* Unified Showcase (Products & Services Mixed) */}
                <main className="max-w-7xl mx-auto px-6 py-16">
                    {/* Category Filter */}
                    <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6 mb-12 border-b border-white/5 pb-8">
                        <h2 className="text-3xl font-extrabold uppercase tracking-wide">Studio Showcase</h2>
                        <div className="flex flex-wrap gap-2">
                            {categories.map(cat => (
                                <button
                                    key={cat}
                                    onClick={() => setActiveCategory(cat)}
                                    className="px-5 py-2 rounded-xl text-xs font-bold uppercase tracking-wider border transition-all"
                                    style={{
                                        borderColor: activeCategory === cat ? accentColor : 'rgba(255,255,255,0.08)',
                                        backgroundColor: activeCategory === cat ? hexToRgba(accentColor, 0.1) : 'transparent',
                                        color: activeCategory === cat ? accentColor : 'rgba(255,255,255,0.6)'
                                    }}
                                >
                                    {cat}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Showcase Cards Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                        {filteredShowcase.map((item, idx) => (
                            <motion.div
                                key={item.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: idx * 0.05 }}
                                whileHover={{ y: -8, scale: 1.01 }}
                                onClick={() => setSelectedItem(item)}
                                className="group bg-white/[0.02] hover:bg-white/[0.04] border border-white/[0.06] rounded-3xl overflow-hidden cursor-pointer shadow-xl backdrop-blur-md transition-all flex flex-col h-full"
                            >
                                {/* Card image with 3D perspective hover effect */}
                                {(item.gallery_image_url || item.image_url) && (
                                    <div className="h-64 relative overflow-hidden">
                                        <img 
                                            src={item.gallery_image_url || item.image_url} 
                                            alt={item.title} 
                                            className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-108"
                                        />
                                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
                                    </div>
                                )}
                                
                                {/* Info */}
                                <div className="p-6 flex-1 flex flex-col justify-between">
                                    <div>
                                        <div className="flex items-center gap-2 mb-3">
                                            <span 
                                                className="text-[9px] font-extrabold uppercase tracking-widest px-2.5 py-1 rounded-md border"
                                                style={{ 
                                                    color: accentColor, 
                                                    borderColor: hexToRgba(accentColor, 0.2),
                                                    backgroundColor: hexToRgba(accentColor, 0.05)
                                                }}
                                            >
                                                {item.is_service ? 'Service' : 'Product'}
                                            </span>
                                            {item.category && (
                                                <span className="text-[9px] font-bold uppercase tracking-widest text-white/40">
                                                    {item.category}
                                                </span>
                                            )}
                                        </div>
                                        <h3 className="text-xl font-bold mb-2 group-hover:text-white/90 line-clamp-1">
                                            {item.gallery_title || item.title}
                                        </h3>
                                        <p className="text-sm text-white/50 mb-4 line-clamp-2 leading-relaxed">
                                            {item.gallery_description || item.description || "No description provided."}
                                        </p>
                                    </div>

                                    <div className="flex items-center justify-between pt-4 border-t border-white/5 mt-auto">
                                        {(item.gallery_price || item.price) ? (
                                            <span className="text-lg font-black" style={{ color: accentColor }}>
                                                ₹{item.gallery_price || item.price}
                                            </span>
                                        ) : (
                                            <span className="text-xs font-bold text-white/30 uppercase tracking-widest">
                                                Enquire Price
                                            </span>
                                        )}
                                        <span className="flex items-center gap-1.5 text-xs font-extrabold uppercase tracking-widest opacity-0 group-hover:opacity-100 transition-opacity duration-300" style={{ color: accentColor }}>
                                            View <ArrowRight className="w-3.5 h-3.5" />
                                        </span>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </main>

                {/* Footer */}
                <footer className="py-24 border-t border-white/5 text-center mt-20">
                    <p className="text-sm text-white/30 tracking-widest uppercase mb-4">
                        &copy; 2026 {profile.shop_name || profile.name}
                    </p>
                    <p className="text-[10px] text-white/20 uppercase tracking-[0.3em]">
                        Handcrafted with precision &bull; 3D Experience
                    </p>
                </footer>
            </div>
        </div>
    );
};

export default ProfileThreeJS;
