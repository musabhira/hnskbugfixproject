import { useState, useEffect } from 'react';
import {
    X, Instagram, MapPin, Mail, Phone, ShoppingBag,
    Star, ArrowRight, Briefcase, MessageCircle, ShieldCheck, Quote, Hash, Award, ChevronDown
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

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

const ProfileElite = ({ data }) => {
    const { profile, gallery, services, threads = [], banners = [] } = data;
    const [selectedItem, setSelectedItem] = useState(null);
    const [scrolled, setScrolled] = useState(false);

    useEffect(() => {
        const handleScroll = () => setScrolled(window.scrollY > 100);
        window.addEventListener('scroll', handleScroll);
        // Inject Google Fonts for that premium feel
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=Inter:wght@300;400;600&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const accentColor = profile.button_color_code || '#D4AF37'; // Gold
    const bgColor = profile.bg_color_code || '#080808';

    return (
        <div className="min-h-screen bg-[#080808] text-white selection:bg-white/20" style={{ fontFamily: '"Inter", sans-serif' }}>
            <style jsx global>{`
                .serif-font { font-family: 'Playfair Display', serif; }
                .elite-border { border-color: ${hexToRgba(accentColor, 0.2)}; }
                .elite-text { color: ${accentColor}; }
                .elite-bg { background-color: ${accentColor}; }
            `}</style>

            {/* Navigation Placeholder */}
            <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 px-10 py-6 flex justify-between items-center ${scrolled ? 'bg-black/80 backdrop-blur-md' : 'bg-transparent'}`}>
                <div className="serif-font text-2xl font-bold tracking-widest">{profile.shop_name?.split(' ')[0] || profile.name?.split(' ')[0]}</div>
                <div className="flex gap-8 text-[11px] uppercase tracking-[0.2em] font-semibold text-white/50">
                    <span className="hover:text-white cursor-pointer transition-colors">Portfolio</span>
                    <span className="hover:text-white cursor-pointer transition-colors">Premium</span>
                    <span className="hover:text-white cursor-pointer transition-colors">Contact</span>
                </div>
            </nav>

            {/* Centered Hero */}
            <section className="relative h-screen flex flex-col items-center justify-center text-center px-6">
                <motion.div
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 1.2 }}
                    className="max-w-4xl"
                >
                    <div className="mb-12 relative inline-block">
                        <motion.div
                            initial={{ scale: 0.8, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: 0.5, duration: 1 }}
                            className="w-40 h-40 md:w-56 md:h-56 rounded-full p-[1px] bg-gradient-to-b from-white/20 to-transparent"
                        >
                            <img src={profile.profile_image_url} alt={profile.name} className="w-full h-full object-cover rounded-full" />
                        </motion.div>
                        {profile.verified && (
                            <div className="absolute -bottom-2 right-4 bg-white text-black p-2 rounded-full shadow-2xl">
                                <Award className="w-5 h-5" />
                            </div>
                        )}
                    </div>

                    <h1 className="serif-font text-6xl md:text-8xl font-bold mb-8 tracking-tight">
                        {profile.shop_name || profile.name}
                    </h1>
                    <div className="flex items-center justify-center gap-4 mb-10">
                        <div className="h-px w-12 bg-white/20" />
                        <p className="text-white/40 uppercase tracking-[0.4em] text-xs font-bold leading-none">
                            Luxury Elite Profile
                        </p>
                        <div className="h-px w-12 bg-white/20" />
                    </div>
                    <p className="text-xl md:text-2xl text-white/60 font-light leading-relaxed max-w-2xl mx-auto italic mb-12">
                        "{profile.bio || "Crafting excellence through digital innovation and premium service delivery."}"
                    </p>
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ delay: 1.5 }}
                        className="flex flex-col items-center gap-12"
                    >
                        <button
                            onClick={() => window.open(`https://wa.me/${profile.phone_no}`, '_blank')}
                            style={{ backgroundColor: accentColor }}
                            className="px-12 py-5 text-black font-bold uppercase tracking-[0.2em] text-[11px] hover:scale-105 transition-transform"
                        >
                            Contact Me
                        </button>
                        <motion.div
                            animate={{ y: [0, 10, 0] }}
                            transition={{ repeat: Infinity, duration: 2 }}
                            className="text-white/20"
                        >
                            <ChevronDown className="w-8 h-8 font-thin" />
                        </motion.div>
                    </motion.div>
                </motion.div>
            </section>

            {/* Highlights (Banners) - Elegant Slider */}
            {banners.length > 0 && (
                <section className="py-32 px-6">
                    <div className="max-w-7xl mx-auto">
                        <div className="flex flex-col items-center mb-20">
                            <h2 className="serif-font text-4xl italic mb-4">Highlights</h2>
                            <div className="h-0.5 w-16 elite-bg" />
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-16">
                            {banners.map((banner, idx) => (
                                <motion.div
                                    key={banner.id}
                                    initial={{ opacity: 0, y: 40 }}
                                    whileInView={{ opacity: 1, y: 0 }}
                                    transition={{ delay: idx * 0.2 }}
                                    viewport={{ once: true }}
                                    className="group cursor-pointer"
                                >
                                    <div className="aspect-[16/10] overflow-hidden mb-8 bg-white/5">
                                        <img src={banner.image_url} alt="" className="w-full h-full object-cover grayscale transition-all duration-1000 group-hover:grayscale-0 group-hover:scale-105" />
                                    </div>
                                    <h3 className="serif-font text-2xl font-semibold mb-2">{banner.title}</h3>
                                    <div className="h-px w-full bg-white/10 group-hover:elite-bg transition-colors duration-500" />
                                </motion.div>
                            ))}
                        </div>
                    </div>
                </section>
            )}

            {/* Gallery Section - Masonry-ish Grid */}
            <section className="py-32 bg-white/5">
                <div className="max-w-7xl mx-auto px-6">
                    <div className="text-center mb-20 space-y-4">
                        <span className="uppercase tracking-[0.5em] text-[10px] text-white/30 font-bold block">COLLECTIONS</span>
                        <h2 className="serif-font text-5xl italic">The Portfolio</h2>
                    </div>

                    <div className="columns-1 md:columns-2 lg:columns-3 gap-8 space-y-8">
                        {gallery.map((item, idx) => (
                            <motion.div
                                key={item.id}
                                initial={{ opacity: 0 }}
                                whileInView={{ opacity: 1 }}
                                transition={{ delay: (idx % 3) * 0.1 }}
                                className="break-inside-avoid group cursor-pointer"
                                onClick={() => setSelectedItem(item)}
                            >
                                <div className="relative overflow-hidden bg-black">
                                    <img src={item.gallery_image_url || item.image_url} alt="" className="w-full h-auto opacity-70 group-hover:opacity-100 transition-opacity duration-700" />
                                    <div className="absolute inset-x-0 bottom-0 p-8 translate-y-full group-hover:translate-y-0 transition-transform duration-500 bg-gradient-to-t from-black to-transparent">
                                        <p className="elite-text text-sm font-bold uppercase tracking-widest">{item.gallery_category}</p>
                                        <h4 className="serif-font text-xl italic">{item.gallery_title}</h4>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Services Section - Clean Vertical List */}
            {services.length > 0 && (
                <section className="py-32 max-w-5xl mx-auto px-6">
                    <div className="flex flex-col items-center mb-24">
                        <h2 className="serif-font text-4xl mb-4 italic">Premium Offerings</h2>
                        <div className="h-px w-32 bg-white/10" />
                    </div>
                    <div className="space-y-20">
                        {services.map((service, i) => (
                            <motion.div
                                key={service.id}
                                initial={{ opacity: 0, x: -20 }}
                                whileInView={{ opacity: 1, x: 0 }}
                                className="flex flex-col md:flex-row items-start md:items-center justify-between gap-8 group"
                            >
                                <div className="max-w-lg">
                                    <div className="text-[10px] font-bold text-white/20 mb-2">SERVICE_0{i + 1}</div>
                                    <h3 className="serif-font text-3xl mb-4 group-hover:elite-text transition-colors">{service.service_title}</h3>
                                    <p className="text-white/40 leading-relaxed italic">{service.service_description}</p>
                                </div>
                                <div className="flex items-center gap-6">
                                    <span className="serif-font text-3xl font-bold">{service.service_price}</span>
                                    <button className="h-14 w-14 rounded-full border border-white/20 flex items-center justify-center hover:bg-white hover:text-black transition-all">
                                        <ArrowRight className="w-5 h-5" />
                                    </button>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </section>
            )}

            {/* Footer */}
            <footer className="py-32 border-t border-white/5 px-6">
                <div className="max-w-7xl mx-auto flex flex-col items-center text-center">
                    <h2 className="serif-font text-3xl mb-12 italic tracking-widest uppercase">{profile.shop_name || profile.name}</h2>
                    <div className="flex gap-16 mb-16 opacity-30">
                        <Instagram className="w-6 h-6 hover:opacity-100 cursor-pointer" />
                        <Phone className="w-6 h-6 hover:opacity-100 cursor-pointer" />
                        <Mail className="w-6 h-6 hover:opacity-100 cursor-pointer" />
                    </div>
                    <div className="text-[10px] uppercase tracking-[0.5em] text-white/20 font-bold">
                        &copy; 2026 HANDSKILL OFFICIAL PARTNER
                    </div>
                </div>
            </footer>

            {/* Modal */}
            <AnimatePresence>
                {selectedItem && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-[#080808]/fb0 backdrop-blur-2xl"
                        onClick={() => setSelectedItem(null)}
                    >
                        <motion.div
                            initial={{ scale: 0.95, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            className="bg-black border border-white/10 max-w-3xl w-full p-12 relative overflow-y-auto"
                            onClick={e => e.stopPropagation()}
                        >
                            <button onClick={() => setSelectedItem(null)} className="absolute top-6 right-6 text-white/40 hover:text-white">
                                <X className="w-8 h-8" />
                            </button>
                            <div className="grid md:grid-cols-2 gap-12">
                                <div className="aspect-square bg-white/5">
                                    <img src={selectedItem.gallery_image_url || selectedItem.image_url} alt="" className="w-full h-full object-cover" />
                                </div>
                                <div className="flex flex-col justify-center">
                                    <p className="elite-text text-[10px] font-bold tracking-[0.4em] uppercase mb-4">{selectedItem.gallery_category || "PORTFOLIO"}</p>
                                    <h2 className="serif-font text-4xl mb-6 italic">{selectedItem.gallery_title || selectedItem.title}</h2>
                                    <p className="text-white/60 leading-relaxed mb-8 font-light">{selectedItem.gallery_description || selectedItem.description}</p>
                                    {selectedItem.gallery_price && <span className="serif-font text-3xl font-bold mb-8">{selectedItem.gallery_price}</span>}
                                    <button style={{ backgroundColor: accentColor }} className="py-4 text-black font-bold uppercase tracking-widest text-[10px]">
                                        Inquire About This
                                    </button>
                                </div>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default ProfileElite;
