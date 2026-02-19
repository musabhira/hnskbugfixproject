import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { fetchDataBySlug } from '../lib/supabase';
import {
    Menu, X, Instagram, MapPin, Mail, Phone, ShoppingBag,
    Star, ArrowRight, Briefcase, Share2, MessageCircle, Award, Heart, ShieldCheck, Layers, ChevronDown, Quote, Globe, Hash
} from 'lucide-react';
import { motion, AnimatePresence, useScroll, useTransform } from 'framer-motion';

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
            className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-md"
            onClick={onClose}
        >
            <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.9, opacity: 0 }}
                className="bg-[#111] border border-white/10 rounded-3xl max-w-2xl w-full max-h-[90vh] overflow-y-auto relative shadow-2xl"
                onClick={e => e.stopPropagation()}
                style={{
                    boxShadow: `0 0 50px ${hexToRgba(accentColor, 0.1)}`
                }}
            >
                <button
                    onClick={onClose}
                    className="absolute top-4 right-4 p-2 bg-black/50 hover:bg-white/20 rounded-full text-white transition-colors z-10"
                >
                    <X className="w-6 h-6" />
                </button>

                {(item.gallery_image_url || item.image_url) && (
                    <div className="w-full h-64 md:h-80 relative">
                        <img
                            src={item.gallery_image_url || item.image_url}
                            alt={item.gallery_title || item.title || "Detail"}
                            className="w-full h-full object-cover"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-[#111] via-transparent to-transparent" />
                    </div>
                )}

                <div className="p-8">
                    <div className="flex items-center gap-3 mb-4">
                        <div
                            className="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider text-black"
                            style={{ backgroundColor: accentColor || '#D4AF37' }}
                        >
                            {item.gallery_category || item.category || 'Portfolio'}
                        </div>
                        {item.created_at && (
                            <span className="text-white/40 text-xs">
                                {new Date(item.created_at).toLocaleDateString()}
                            </span>
                        )}
                    </div>

                    <h2 className="text-3xl font-serif font-bold text-white mb-4">
                        {item.gallery_title || item.title || "Untitled"}
                    </h2>

                    <p className="text-gray-300 leading-relaxed text-lg mb-8">
                        {item.gallery_description || item.description || "No description provided."}
                    </p>

                    <div className="flex flex-wrap gap-4">
                        {item.gallery_price || item.price ? (
                            <div className="px-6 py-3 rounded-xl bg-white/5 border border-white/10 flex items-center gap-3">
                                <ShoppingBag className="w-5 h-5 text-white/70" />
                                <span className="text-xl font-bold text-white">
                                    {item.gallery_price || item.price}
                                </span>
                            </div>
                        ) : null}

                        <button className="flex-1 px-8 py-3 rounded-xl font-bold bg-white text-black hover:bg-gray-200 transition-colors flex items-center justify-center gap-2">
                            <span>Enquire Now</span>
                            <ArrowRight className="w-4 h-4" />
                        </button>
                    </div>
                </div>
            </motion.div>
        </motion.div>
    );
};

const ProfilePage = () => {
    const { slug } = useParams();
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [activeCategory, setActiveCategory] = useState('All');
    const [scrolled, setScrolled] = useState(false);
    const [selectedItem, setSelectedItem] = useState(null);

    const { scrollY } = useScroll();
    const heroOpacity = useTransform(scrollY, [0, 400], [1, 0]);
    const heroScale = useTransform(scrollY, [0, 400], [1, 0.95]);

    useEffect(() => {
        const load = async () => {
            const res = await fetchDataBySlug(slug);
            setData(res);
            setLoading(false);
        };
        load();

        const handleScroll = () => setScrolled(window.scrollY > 50);
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, [slug]);

    if (loading) return (
        <div className="h-screen flex flex-col items-center justify-center bg-[#050505] text-white">
            <div className="w-16 h-16 border-4 border-white/10 border-t-white rounded-full animate-spin" />
        </div>
    );

    if (!data) return (
        <div className="h-screen flex items-center justify-center bg-[#050505] text-white/50 uppercase tracking-widest">
            Profile Not Found
        </div>
    );

    const { profile, gallery, services, threads = [], banners = [] } = data;

    // --- ACCESS CONTROL ---
    if (!profile.verified) {
        return (
            <div className="h-screen flex flex-col items-center justify-center bg-[#050505] text-center p-6 relative overflow-hidden">
                <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-red-900/20 via-[#050505] to-black" />
                <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="relative z-10 bg-white/5 backdrop-blur-2xl p-12 rounded-[40px] border border-white/10 max-w-lg"
                >
                    <div className="w-20 h-20 bg-gradient-to-tr from-rose-500 to-orange-500 rounded-3xl flex items-center justify-center mx-auto mb-10">
                        <ShieldCheck className="w-10 h-10 text-white" />
                    </div>
                    <h1 className="text-4xl font-serif text-white mb-6">Access Restricted</h1>
                    <p className="text-slate-400 font-light mb-12">
                        This profile is exclusive to <strong className="text-white">Verified Partners</strong>.
                    </p>
                    <a
                        href={`https://wa.me/${profile.mobile || profile.phone_no}?text=Verification%20Assistance`}
                        className="inline-flex items-center gap-3 px-8 py-3 bg-white text-black rounded-xl font-bold uppercase tracking-wider hover:bg-slate-200 transition-all"
                    >
                        <span>Contact Support</span>
                        <ArrowRight className="w-4 h-4" />
                    </a>
                </motion.div>
            </div>
        );
    }

    // Dynamic Theme Colors
    const accentColor = profile.button_color_code || '#D4AF37'; // Default Gold
    const bgColor = profile.bg_color_code || '#050505';

    // Categories
    const categories = ['All', ...new Set(gallery.map(i => i.category || 'Collection'))];
    const filteredGallery = activeCategory === 'All' ? gallery : gallery.filter(i => (i.category || 'Collection') === activeCategory);

    return (
        <div
            className="min-h-screen text-white font-sans selection:bg-white/20"
            style={{ backgroundColor: '#050505' }}
        >
            <style jsx global>{`
                :root {
                    --accent-color: ${accentColor};
                    --bg-gradient: ${bgColor};
                }
            `}</style>

            {/* Dynamic Background Mesh */}
            <div className="fixed inset-0 pointer-events-none">
                <div
                    className="absolute top-0 inset-x-0 h-[80vh] opacity-20"
                    style={{
                        background: `radial-gradient(circle at 50% 0%, ${bgColor}, transparent 70%)`
                    }}
                />
                <div className="absolute inset-0 bg-[#050505]/40 backdrop-blur-3xl" />
            </div>

            <AnimatePresence>
                {selectedItem && (
                    <ItemDetailModal
                        item={selectedItem}
                        onClose={() => setSelectedItem(null)}
                        accentColor={accentColor}
                    />
                )}
            </AnimatePresence>

            {/* Navigation */}
            <nav className={`fixed top-0 inset-x-0 z-40 transition-all duration-500 ${scrolled ? 'bg-[#050505]/80 backdrop-blur-xl border-b border-white/5 py-4' : 'bg-transparent py-6'}`}>
                <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-white/10 border border-white/5 flex items-center justify-center font-serif font-bold text-xl backdrop-blur-sm">
                            {profile.shop_name?.charAt(0) || profile.name?.charAt(0)}
                        </div>
                        <span className={`font-serif font-medium text-lg tracking-wide ${scrolled ? 'opacity-100' : 'opacity-90'}`}>
                            {profile.shop_name || profile.name}
                        </span>
                    </div>
                    <div className="hidden md:flex items-center gap-8">
                        {['Banners', 'Thoughts', 'Gallery', 'Services'].map((item) => (
                            <button
                                key={item}
                                onClick={() => document.getElementById(item.toLowerCase())?.scrollIntoView({ behavior: 'smooth' })}
                                className="text-sm font-medium uppercase tracking-widest text-white/60 hover:text-white transition-colors"
                            >
                                {item}
                            </button>
                        ))}
                    </div>
                </div>
            </nav>

            {/* Content Container */}
            <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-32 pb-20">

                {/* HERO SECTION */}
                <motion.div
                    style={{ opacity: heroOpacity, scale: heroScale }}
                    className="flex flex-col md:flex-row items-center gap-12 mb-32"
                >
                    <div className="w-full md:w-1/2 relative group">
                        <div className="absolute inset-0 bg-gradient-to-tr from-[var(--accent-color)] to-purple-500 rounded-[3rem] blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-700" />
                        <div className="relative aspect-[4/5] rounded-[3rem] overflow-hidden border border-white/10 shadow-2xl">
                            {profile.profile_image_url ? (
                                <img
                                    src={profile.profile_image_url}
                                    alt={profile.name}
                                    className="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-700"
                                />
                            ) : (
                                <div className="w-full h-full bg-slate-900 flex items-center justify-center">
                                    <Star className="w-20 h-20 text-white/20" />
                                </div>
                            )}
                            <div className="absolute bottom-0 inset-x-0 p-8 bg-gradient-to-t from-black/90 via-black/50 to-transparent">
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-md rounded-full border border-white/5">
                                        <ShieldCheck className="w-4 h-4 text-[var(--accent-color)]" />
                                        <span className="text-xs font-bold uppercase tracking-wider">Verified Partner</span>
                                    </div>
                                    <div className="flex gap-2">
                                        {profile.insta_link && (
                                            <a href={profile.insta_link} target="_blank" rel="noreferrer" className="p-2 bg-white/10 rounded-full hover:bg-white text-white hover:text-black transition-all">
                                                <Instagram className="w-5 h-5" />
                                            </a>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="w-full md:w-1/2 space-y-8">
                        <div>
                            <h1 className="text-6xl md:text-8xl font-serif font-medium leading-tight mb-4 bg-clip-text text-transparent bg-gradient-to-r from-white via-white to-white/50">
                                {profile.shop_name || profile.name}
                            </h1>
                            <div className="flex items-center gap-2 text-white/60 mb-8">
                                <MapPin className="w-4 h-4 text-[var(--accent-color)]" />
                                <span className="uppercase tracking-widest text-sm">
                                    {[profile.city, profile.state, profile.country].filter(Boolean).join(' • ')}
                                </span>
                            </div>
                            <p className="text-xl text-slate-300 font-light leading-relaxed max-w-lg border-l-2 border-[var(--accent-color)] pl-6">
                                {profile.bio || "Crafting excellence through dedicated service and premium quality offerings."}
                            </p>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            {[
                                { label: 'Connect', icon: MessageCircle, action: () => window.open(`https://wa.me/${profile.phone_no}`, '_blank') },
                                { label: 'Call Now', icon: Phone, action: () => window.open(`tel:${profile.phone_no}`) }
                            ].map((btn, i) => (
                                <button
                                    key={i}
                                    onClick={btn.action}
                                    className="flex items-center justify-center gap-3 py-4 rounded-xl border border-white/10 hover:border-[var(--accent-color)] hover:bg-[var(--accent-color)]/10 transition-all group"
                                >
                                    <btn.icon className="w-5 h-5 text-white/70 group-hover:text-[var(--accent-color)]" />
                                    <span className="font-medium uppercase tracking-widest text-sm">{btn.label}</span>
                                </button>
                            ))}
                        </div>
                    </div>
                </motion.div>

                {/* THOUGHTS / THREADS SECTION */}
                {threads.length > 0 && (
                    <section id="thoughts" className="mb-32">
                        <div className="flex items-end justify-between mb-12">
                            <h2 className="text-4xl font-serif">Deep Thoughts</h2>
                            <Quote className="w-10 h-10 text-white/10" />
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {threads.map((thread, i) => (
                                <motion.div
                                    key={thread.id}
                                    initial={{ opacity: 0, y: 20 }}
                                    whileInView={{ opacity: 1, y: 0 }}
                                    viewport={{ once: true }}
                                    transition={{ delay: i * 0.1 }}
                                    className="bg-white/5 border border-white/5 p-8 rounded-3xl hover:bg-white/10 transition-colors relative group"
                                >
                                    <p className="text-lg leading-relaxed text-slate-300 italic mb-6">
                                        "{thread.content}"
                                    </p>
                                    <div className="flex items-center justify-between mt-auto">
                                        <div className="flex items-center gap-2">
                                            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-white/20 to-transparent" />
                                            <span className="text-sm text-white/40">{new Date(thread.created_at).toLocaleDateString()}</span>
                                        </div>
                                        <Hash className="w-5 h-5 text-white/20 group-hover:text-[var(--accent-color)] transition-colors" />
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </section>
                )}

                {/* BANNERS SECTION */}
                {banners.length > 0 && (
                    <section id="banners" className="mb-32">
                        <h2 className="text-4xl font-serif mb-12">Featured Highlights</h2>
                        <div className="overflow-x-auto pb-8 -mx-6 px-6 scrollbar-hide flex gap-6">
                            {banners.map((banner, i) => (
                                <motion.div
                                    key={banner.id}
                                    initial={{ opacity: 0, x: 50 }}
                                    whileInView={{ opacity: 1, x: 0 }}
                                    viewport={{ once: true }}
                                    className="min-w-[85vw] md:min-w-[500px] aspect-video relative rounded-3xl overflow-hidden border border-white/10 group cursor-pointer"
                                    onClick={() => setSelectedItem(banner)}
                                >
                                    <img src={banner.image_url} alt={banner.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black via-black/20 to-transparent p-8 flex flex-col justify-end">
                                        <h3 className="text-2xl font-bold mb-2">{banner.title}</h3>
                                        <p className="text-white/70 line-clamp-2">{banner.description}</p>
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </section>
                )}

                {/* GALLERY GRID */}
                <section id="gallery" className="mb-32">
                    <div className="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-12">
                        <div>
                            <h2 className="text-4xl font-serif mb-4">Curated Gallery</h2>
                            <p className="text-white/50">Explore our finest work and collections</p>
                        </div>
                        <div className="flex flex-wrap gap-2">
                            {categories.map(cat => (
                                <button
                                    key={cat}
                                    onClick={() => setActiveCategory(cat)}
                                    className={`px-4 py-2 rounded-full text-xs uppercase tracking-wider font-bold transition-all ${activeCategory === cat ? 'bg-white text-black' : 'bg-white/5 text-white/60 hover:bg-white/10'}`}
                                >
                                    {cat}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="columns-1 md:columns-2 lg:columns-3 gap-6 space-y-6">
                        {filteredGallery.map((item, i) => (
                            <motion.div
                                key={item.id}
                                layoutId={item.id}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ delay: i % 3 * 0.1 }}
                                className="break-inside-avoid relative rounded-2xl overflow-hidden group cursor-pointer border border-white/5 bg-white/5"
                                onClick={() => setSelectedItem(item)}
                            >
                                <img
                                    src={item.gallery_image_url || item.image_url}
                                    alt={item.gallery_title}
                                    className="w-full h-auto object-cover transition-all duration-700 group-hover:scale-105 group-hover:opacity-80"
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-6">
                                    <span className="text-[10px] uppercase tracking-widest text-[var(--accent-color)] mb-2 font-bold">{item.gallery_category}</span>
                                    <h3 className="text-xl font-serif font-medium">{item.gallery_title}</h3>
                                    {item.gallery_price && <p className="text-white/70 mt-1">{item.gallery_price}</p>}
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </section>

                {/* SERVICES / OFFERINGS */}
                {services.length > 0 && (
                    <section id="services" className="mb-32">
                        <h2 className="text-4xl font-serif mb-12 text-center">Premium Offerings</h2>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {services.map((service, i) => (
                                <motion.div
                                    key={service.id}
                                    initial={{ opacity: 0, scale: 0.95 }}
                                    whileInView={{ opacity: 1, scale: 1 }}
                                    viewport={{ once: true }}
                                    className="p-8 rounded-3xl bg-gradient-to-br from-white/5 to-transparent border border-white/10 hover:border-[var(--accent-color)]/50 transition-all hover:shadow-2xl hover:shadow-[var(--accent-color)]/10 group"
                                >
                                    <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center mb-6 group-hover:bg-[var(--accent-color)] transition-colors">
                                        <Award className="w-6 h-6 text-white group-hover:text-black" />
                                    </div>
                                    <h3 className="text-2xl font-serif mb-3">{service.service_title}</h3>
                                    <p className="text-white/50 leading-relaxed mb-6">{service.service_description}</p>
                                    <div className="flex items-center justify-between border-t border-white/5 pt-6">
                                        <span className="text-xl font-bold">{service.service_price}</span>
                                        <button className="p-2 rounded-full bg-white text-black hover:scale-110 transition-transform">
                                            <ArrowRight className="w-4 h-4" />
                                        </button>
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </section>
                )}

            </div>

            {/* FOOTER */}
            <footer className="border-t border-white/10 bg-[#020202] py-20 relative overflow-hidden">
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[500px] h-[500px] bg-[var(--accent-color)] opacity-5 blur-[120px] rounded-full pointer-events-none" />
                <div className="max-w-7xl mx-auto px-6 relative z-10 text-center">
                    <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-white/10 to-transparent border border-white/10 flex items-center justify-center mx-auto mb-8 font-serif font-bold text-2xl">
                        {profile.shop_name?.charAt(0) || "H"}
                    </div>
                    <h2 className="text-3xl font-serif mb-2">{profile.shop_name || profile.name}</h2>
                    <p className="text-white/40 mb-12">Verified Handskill Partner</p>

                    <div className="flex justify-center gap-8 mb-16">
                        <a href="#" className="hover:text-[var(--accent-color)] transition-colors">Privacy</a>
                        <a href="#" className="hover:text-[var(--accent-color)] transition-colors">Terms</a>
                        <a href="#" className="hover:text-[var(--accent-color)] transition-colors">Contact</a>
                    </div>

                    <div className="pt-12 border-t border-white/5 flex items-center justify-between text-xs text-white/30 uppercase tracking-widest">
                        <span>© 2024 Handskill Friends</span>
                        <div className="flex items-center gap-2">
                            <span>Powered by</span>
                            <span className="text-white font-bold">Handskill</span>
                        </div>
                    </div>
                </div>
            </footer>
        </div>
    );
};

export default ProfilePage;
