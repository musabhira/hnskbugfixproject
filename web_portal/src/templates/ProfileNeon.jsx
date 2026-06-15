import { useState } from 'react';
import {
    X, MapPin, Mail, Phone, ShoppingBag,
    Star, ArrowRight, Briefcase, MessageCircle, ShieldCheck, Quote, Hash, Award
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
                className="bg-[#0a0a0a] border border-cyan-500/30 rounded-3xl max-w-2xl w-full max-h-[90vh] overflow-y-auto relative shadow-[0_0_50px_rgba(6,182,212,0.2)]"
                onClick={e => e.stopPropagation()}
            >
                <button onClick={onClose} className="absolute top-4 right-4 p-2 bg-black/50 hover:bg-cyan-500/20 rounded-full text-white z-10 border border-white/10">
                    <X className="w-6 h-6" />
                </button>
                {(item.gallery_image_url || item.image_url) && (
                    <div className="w-full h-80 relative">
                        <img src={item.gallery_image_url || item.image_url} alt="Detail" className="w-full h-full object-cover" />
                        <div className="absolute inset-0 bg-gradient-to-t from-[#0a0a0a] to-transparent" />
                    </div>
                )}
                <div className="p-8">
                    <div className="flex items-center gap-3 mb-4">
                        <div className="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest text-cyan-400 border border-cyan-400/30 bg-cyan-400/10">
                            {item.gallery_category || item.category || 'Portfolio'}
                        </div>
                    </div>
                    <h2 className="text-4xl font-bold text-white mb-4 tracking-tight">
                        {item.gallery_title || item.title || "Untitled"}
                    </h2>
                    <p className="text-gray-400 leading-relaxed text-lg mb-8">
                        {item.gallery_description || item.description || "No description provided."}
                    </p>
                    <div className="flex gap-4">
                        {item.gallery_price || item.price ? (
                            <div className="px-6 py-3 rounded-xl bg-cyan-500/10 border border-cyan-500/30 flex items-center gap-3">
                                <span className="text-xl font-bold text-cyan-400">{item.gallery_price || item.price}</span>
                            </div>
                        ) : null}
                    </div>
                </div>
            </motion.div>
        </motion.div>
    );
};

const ProfileNeon = ({ data }) => {
    const { profile, gallery, services, threads = [], banners = [] } = data;
    const [selectedItem, setSelectedItem] = useState(null);
    const [activeCategory, setActiveCategory] = useState('All');

    const accentColor = profile.button_color_code || '#06b6d4'; // Cyan default
    const bgColor = profile.bg_color_code || '#000000';

    const categories = ['All', ...new Set(gallery.map(i => i.category || 'Collection'))];
    const filteredGallery = activeCategory === 'All' ? gallery : gallery.filter(i => (i.category || 'Collection') === activeCategory);

    return (
        <div className="min-h-screen bg-black text-white font-sans selection:bg-cyan-500/30 overflow-x-hidden">
            <style jsx global>{`
                .neon-glow {
                    text-shadow: 0 0 10px ${hexToRgba(accentColor, 0.5)}, 0 0 20px ${hexToRgba(accentColor, 0.3)};
                }
                .neon-border {
                    box-shadow: 0 0 15px ${hexToRgba(accentColor, 0.2)}, inset 0 0 5px ${hexToRgba(accentColor, 0.1)};
                }
            `}</style>

            <AnimatePresence>
                {selectedItem && <ItemDetailModal item={selectedItem} onClose={() => setSelectedItem(null)} accentColor={accentColor} />}
            </AnimatePresence>

            {/* Futuristic Grid Background */}
            <div className="fixed inset-0 pointer-events-none opacity-20">
                <div className="absolute inset-0" style={{
                    backgroundImage: `linear-gradient(${hexToRgba(accentColor, 0.1)} 1px, transparent 1px), linear-gradient(90deg, ${hexToRgba(accentColor, 0.1)} 1px, transparent 1px)`,
                    backgroundSize: '40px 40px',
                    maskImage: 'radial-gradient(circle at 50% 50%, black, transparent)'
                }} />
            </div>

            {/* Hero Section */}
            <div className="relative pt-32 pb-20 px-6 max-w-7xl mx-auto">
                <div className="flex flex-col lg:flex-row items-center gap-16">
                    <motion.div
                        initial={{ opacity: 0, x: -50 }}
                        animate={{ opacity: 1, x: 0 }}
                        className="relative group"
                    >
                        <div className="absolute -inset-4 bg-gradient-to-tr from-cyan-500 to-blue-500 blur-2xl opacity-20 group-hover:opacity-40 transition duration-1000" />
                        <div className="relative w-72 h-72 md:w-96 md:h-96 rounded-full p-1 bg-gradient-to-tr from-cyan-400 via-transparent to-blue-500 neon-border overflow-hidden">
                            <img src={profile.profile_image_url} alt={profile.name} className="w-full h-full object-cover rounded-full p-2" />
                        </div>
                        <div className="absolute -bottom-4 right-10 bg-black border border-cyan-500/50 px-6 py-2 rounded-full flex items-center gap-2 shadow-2xl">
                            <div className="w-2 h-2 rounded-full bg-cyan-400 animate-pulse shadow-[0_0_8px_rgba(34,211,238,0.8)]" />
                            <span className="text-[10px] font-bold tracking-widest uppercase text-cyan-400/80">Cyber Neon Profile</span>
                        </div>
                    </motion.div>

                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-center lg:text-left flex-1"
                    >
                        <h1 className="text-7xl md:text-9xl font-black italic tracking-tighter uppercase mb-6 bg-clip-text text-transparent bg-gradient-to-br from-white via-white to-gray-500 neon-glow">
                            {profile.shop_name || profile.name}
                        </h1>
                        <p className="text-xl text-cyan-100/60 font-medium tracking-wide max-w-2xl mb-12">
                            {profile.bio || "Pushing boundaries in the digital frontier. Verified partner of the Handskill ecosystem."}
                        </p>
                        <div className="flex flex-wrap gap-4 justify-center lg:justify-start">
                            <button
                                onClick={() => window.open(`https://wa.me/${profile.phone_no}`, '_blank')}
                                className="px-10 py-4 bg-cyan-500 text-black font-black uppercase tracking-widest rounded-none skew-x-[-12deg] hover:bg-white transition-all"
                            >
                                Contact Me
                            </button>
                            <button className="px-10 py-4 border border-cyan-500 text-cyan-500 font-bold uppercase tracking-widest rounded-none skew-x-[-12deg] hover:bg-cyan-500/10 transition-all">
                                Portfolio
                            </button>
                        </div>
                    </motion.div>
                </div>
            </div>

            {/* Banners Scroller */}
            {banners.length > 0 && (
                <div className="py-20 bg-cyan-500/5">
                    <div className="max-w-7xl mx-auto px-6">
                        <div className="flex items-center gap-4 mb-12 overflow-hidden">
                            <h2 className="text-2xl font-black uppercase tracking-[0.3em] text-cyan-500 whitespace-nowrap">Featured Drops</h2>
                            <div className="h-px bg-cyan-500/20 w-full" />
                        </div>
                        <div className="flex gap-6 overflow-x-auto pb-12 scrollbar-hide">
                            {banners.map((banner) => (
                                <motion.div
                                    key={banner.id}
                                    whileHover={{ scale: 1.02, y: -5 }}
                                    className="min-w-[80vw] md:min-w-[400px] h-[300px] rounded-2xl overflow-hidden relative border border-cyan-500/20 cursor-pointer"
                                    onClick={() => setSelectedItem(banner)}
                                >
                                    <img src={banner.image_url} alt="Banner" className="w-full h-full object-cover" />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black to-transparent p-8 flex flex-col justify-end">
                                        <h3 className="text-xl font-bold uppercase tracking-widest">{banner.title}</h3>
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </div>
                </div>
            )}

            {/* Gallery Grid */}
            <div className="py-32 max-w-7xl mx-auto px-6">
                <div className="flex flex-col md:flex-row items-center justify-between gap-8 mb-20">
                    <h2 className="text-5xl font-black italic uppercase tracking-tighter">The Vault</h2>
                    <div className="flex gap-2 overflow-x-auto pb-2">
                        {categories.map(cat => (
                            <button
                                key={cat}
                                onClick={() => setActiveCategory(cat)}
                                className={`px-6 py-2 rounded-none skew-x-[-10deg] text-[10px] font-bold uppercase tracking-widest transition-all ${activeCategory === cat ? 'bg-cyan-500 text-black' : 'bg-transparent border border-white/10 text-white/50'}`}
                            >
                                {cat}
                            </button>
                        ))}
                    </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {filteredGallery.map((item) => (
                        <motion.div
                            key={item.id}
                            layoutId={item.id}
                            onClick={() => setSelectedItem(item)}
                            className="group relative h-96 overflow-hidden border border-white/5 cursor-pointer"
                        >
                            <img src={item.gallery_image_url || item.image_url} alt="Work" className="w-full h-full object-cover grayscale group-hover:grayscale-0 transition-all duration-700 group-hover:scale-110" />
                            <div className="absolute inset-0 bg-cyan-500/10 opacity-0 group-hover:opacity-100 transition-opacity" />
                            <div className="absolute bottom-0 left-0 right-0 p-8 transform translate-y-full group-hover:translate-y-0 transition-transform duration-500 bg-gradient-to-t from-black to-transparent">
                                <h4 className="text-xl font-bold uppercase italic">{item.gallery_title}</h4>
                                <p className="text-cyan-400 font-bold">{item.gallery_price}</p>
                            </div>
                        </motion.div>
                    ))}
                </div>
            </div>

            {/* Services Section */}
            {services.length > 0 && (
                <section className="py-32 bg-black border-y border-white/5">
                    <div className="max-w-7xl mx-auto px-6">
                        <h2 className="text-4xl font-black italic uppercase tracking-tighter text-center mb-20">Solutions</h2>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                            {services.map((service, i) => (
                                <motion.div
                                    key={service.id}
                                    whileHover={{ x: 10 }}
                                    className="p-10 border-l-2 border-cyan-500 bg-white/5 relative group"
                                >
                                    <div className="absolute top-4 right-4 text-[40px] font-black text-white/5 leading-none">0{i + 1}</div>
                                    <h3 className="text-2xl font-bold mb-4 uppercase tracking-widest">{service.service_title}</h3>
                                    <p className="text-white/40 mb-8">{service.service_description}</p>
                                    <div className="text-cyan-400 font-bold tracking-widest">{service.service_price}</div>
                                </motion.div>
                            ))}
                        </div>
                    </div>
                </section>
            )}

            {/* Footer */}
            <footer className="py-20 border-t border-cyan-500/20 text-center">
                <div className="text-5xl font-black italic uppercase opacity-10 mb-8">{profile.shop_name || profile.name}</div>
                <div className="flex justify-center gap-12 text-[10px] font-bold uppercase tracking-[0.4em] text-white/30">
                    <span className="hover:text-cyan-400 cursor-pointer">Protocol</span>
                    <span className="hover:text-cyan-400 cursor-pointer">Network</span>
                    <span className="hover:text-cyan-400 cursor-pointer">Security</span>
                </div>
            </footer>
        </div>
    );
};

export default ProfileNeon;
