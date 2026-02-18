import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { fetchDataBySlug } from '../lib/supabase';
import {
    Menu, X, Instagram, MapPin, Mail, Phone, ShoppingBag,
    Star, ArrowRight, Briefcase, Share2, MessageCircle, Award, Heart, ShieldCheck
} from 'lucide-react';
import { motion, AnimatePresence, useScroll, useTransform } from 'framer-motion';

const hexToRgba = (hex, alpha) => {
    if (!hex) return `rgba(0,0,0,${alpha})`;
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

const ProfilePage = () => {
    const { slug } = useParams();
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    const [hasScrolled, setHasScrolled] = useState(false);
    const [activeCategory, setActiveCategory] = useState('All');

    const { scrollY } = useScroll();
    const heroY = useTransform(scrollY, [0, 500], [0, 150]);
    const heroOpacity = useTransform(scrollY, [0, 300], [1, 0]);

    useEffect(() => {
        const load = async () => {
            const res = await fetchDataBySlug(slug);
            setData(res);
            setLoading(false);
        };
        load();
        const handle = () => setHasScrolled(window.scrollY > 50);
        window.addEventListener('scroll', handle);
        return () => window.removeEventListener('scroll', handle);
    }, [slug]);

    if (loading) return (
        <div className="h-screen flex flex-col items-center justify-center bg-white">
            <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1.5, ease: "linear" }} className="w-8 h-8 border-2 border-slate-200 border-t-slate-800 rounded-full mb-4" />
            <span className="text-[10px] uppercase tracking-[0.2em] font-medium text-slate-400">Analysing Business Credentials</span>
        </div>
    );

    if (!data) return <div className="h-screen flex items-center justify-center bg-[#0A0A0A] text-white/40 uppercase tracking-widest">Boutique Not Found</div>;

    const { profile, gallery, services, threads } = data;
    const theme = {
        bg: profile.bg_color_code || '#0A0A0A',
        text: profile.bg_text_color || '#FFFFFF',
        primary: profile.button_color_code || '#D4AF37',
        onPrimary: profile.button_text_color || '#000000',
    };

    // --- ACCESS CONTROL: PREMIUM STATUS ---
    if (profile.is_premium === false) {
        return (
            <div className="h-screen flex flex-col items-center justify-center bg-[#f8fafc] text-center p-6">
                <motion.div
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="bg-white p-12 md:p-24 rounded-[40px] shadow-2xl shadow-slate-200/50 border border-slate-100 max-w-xl relative overflow-hidden"
                >
                    <div className="w-20 h-20 bg-slate-50 rounded-3xl flex items-center justify-center mx-auto mb-10">
                        <ShieldCheck className="w-10 h-10 text-slate-300" />
                    </div>
                    <h1 className="text-4xl md:text-6xl font-black text-slate-900 mb-6 tracking-tighter uppercase">Not Premium User</h1>
                    <p className="text-slate-500 font-semibold leading-relaxed mb-12 text-sm md:text-base px-4">
                        This digital corporate presence is reserved for **Handskill Premium Partners**.
                        Authentication failed for the selected profile.
                    </p>
                    <a
                        href={`https://wa.me/${profile.mobile || profile.phone_no}?text=I%20want%20to%20upgrade%20to%20premium`}
                        className="inline-block px-12 py-5 bg-slate-900 text-white rounded-2xl font-bold text-[11px] uppercase tracking-[0.2em] hover:bg-slate-800 transition-all shadow-xl shadow-slate-200"
                    >
                        Contact Administration
                    </a>
                </motion.div>
            </div>
        );
    }

    const categories = ['All', ...new Set(gallery.map(i => i.category || 'Collection'))];
    const filteredGallery = activeCategory === 'All' ? gallery : gallery.filter(i => (i.category || 'Collection') === activeCategory);

    const scrollTo = (id) => {
        document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
        setMobileMenuOpen(false);
    };

    return (
        <div className="min-h-screen bg-[#f8fafc] font-sans selection:bg-blue-100 selection:text-blue-900" style={{ color: theme.text }}>
            {/* Business Header */}
            <nav className={`fixed top-0 inset-x-0 z-[100] transition-all duration-300 ${hasScrolled ? 'py-3 shadow-md bg-white border-b border-slate-100' : 'py-5 bg-transparent'}`}>
                <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
                    <button onClick={() => scrollTo('home')} className="flex items-center gap-4 group">
                        <div className="w-10 h-10 rounded-xl bg-slate-900 flex items-center justify-center text-white font-bold text-xl shadow-lg group-hover:bg-blue-600 transition-colors">
                            {profile.shop_name?.charAt(0) || profile.name?.charAt(0)}
                        </div>
                        <span className={`font-bold text-xl tracking-tight transition-colors ${hasScrolled ? 'text-slate-900' : 'text-white'}`}>
                            {profile.shop_name || profile.name}
                        </span>
                    </button>

                    <div className="hidden md:flex items-center gap-8">
                        {['Catalogue', 'Solutions', 'Performance'].map(l => (
                            <button key={l} onClick={() => scrollTo(l.toLowerCase())} className={`text-xs uppercase tracking-widest font-bold transition-all ${hasScrolled ? 'text-slate-500 hover:text-blue-600' : 'text-white/70 hover:text-white'}`}>{l}</button>
                        ))}
                        <button
                            onClick={() => scrollTo('footer')}
                            className={`px-6 py-2.5 rounded-xl text-[10px] uppercase tracking-widest font-black transition-all shadow-sm ${hasScrolled ? 'bg-slate-900 text-white hover:bg-blue-600' : 'bg-white text-slate-900 hover:bg-slate-100'}`}
                        >
                            Connect
                        </button>
                    </div>
                </div>
            </nav>

            {/* Enterprise Hero Section */}
            <section id="home" className="relative pt-32 pb-20 px-6 overflow-hidden bg-slate-950 min-h-[70vh] flex items-center">
                <div className="absolute inset-0 opacity-20">
                    <img src={profile.banner_image_url} className="w-full h-full object-cover" alt="" />
                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/40 to-transparent" />
                </div>

                <div className="max-w-7xl mx-auto relative z-10 w-full">
                    <div className="grid lg:grid-cols-2 gap-16 items-center">
                        <motion.div initial={{ opacity: 0, x: -30 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.8 }}>
                            <div className="inline-flex items-center gap-3 px-4 py-2 bg-blue-600/10 border border-blue-500/20 rounded-full mb-8">
                                <ShieldCheck className="w-4 h-4 text-blue-400" />
                                <span className="text-[10px] uppercase tracking-[0.2em] font-black text-blue-400">Verified Enterprise</span>
                            </div>
                            <h1 className="text-5xl md:text-8xl font-black text-white mb-8 tracking-tighter leading-none uppercase">
                                {profile.shop_name || profile.name}
                            </h1>
                            <p className="max-w-xl opacity-60 text-white text-lg md:text-xl mb-12 font-medium leading-relaxed">
                                {profile.bio}
                            </p>
                            <div className="flex flex-wrap gap-5">
                                <button onClick={() => scrollTo('catalogue')} className="px-10 py-4 bg-white text-slate-950 rounded-2xl font-bold text-[11px] uppercase tracking-widest hover:scale-105 transition-all shadow-xl shadow-slate-900/40">Explore Catalogue</button>
                                <button onClick={() => scrollTo('solutions')} className="px-10 py-4 border border-white/20 text-white rounded-2xl font-bold text-[11px] uppercase tracking-widest hover:bg-white/5 transition-all">Business Services</button>
                            </div>
                        </motion.div>

                        <motion.div
                            initial={{ opacity: 0, scale: 0.9 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 1 }}
                            className="hidden lg:block relative"
                        >
                            <div className="aspect-square rounded-[48px] overflow-hidden border-8 border-white/5 shadow-2xl relative group">
                                <img src={profile.profile_image_url} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110" alt="" />
                                <div className="absolute inset-0 bg-blue-600/20 opacity-0 group-hover:opacity-100 transition-opacity" />
                            </div>
                        </motion.div>
                    </div>
                </div>
            </section>

            {/* Product Catalogue - E-commerce Style */}
            <section id="catalogue" className="py-24 max-w-7xl mx-auto px-6">
                <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-8">
                    <div>
                        <h2 className="text-4xl font-black text-slate-900 mb-4 tracking-tight uppercase">Product Catalogue</h2>
                        <div className="h-1.5 w-20 bg-blue-600 rounded-full" />
                    </div>
                    <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-none">
                        {categories.map(c => (
                            <button
                                key={c}
                                onClick={() => setActiveCategory(c)}
                                className={`px-6 py-2.5 rounded-xl text-[10px] uppercase tracking-widest font-black transition-all border ${activeCategory === c ? 'bg-slate-900 border-slate-900 text-white shadow-lg shadow-slate-200' : 'bg-white border-slate-200 text-slate-400 hover:border-slate-400'}`}
                            >
                                {c}
                            </button>
                        ))}
                    </div>
                </div>

                <motion.div layout className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                    <AnimatePresence mode="popLayout">
                        {filteredGallery.map((item) => (
                            <motion.div
                                layout
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                key={item.id}
                                className="bg-white rounded-[28px] overflow-hidden border border-slate-100 hover:shadow-2xl hover:shadow-slate-200 transition-all duration-500 group flex flex-col h-full"
                            >
                                <div className="aspect-[1/1] overflow-hidden bg-slate-50 relative p-4">
                                    <img src={item.image_url} className="w-full h-full object-contain mix-blend-multiply group-hover:scale-110 transition-transform duration-700" alt="" />
                                    <div className="absolute top-4 right-4 h-8 w-8 bg-white/80 backdrop-blur-md rounded-full flex items-center justify-center shadow-lg cursor-pointer hover:bg-white text-slate-400 hover:text-red-500 transition-all">
                                        <Heart className="w-4 h-4" />
                                    </div>
                                </div>

                                <div className="p-6 flex flex-col flex-grow">
                                    <div className="flex justify-between items-start mb-2">
                                        <span className="text-[10px] font-bold text-blue-600 uppercase tracking-widest bg-blue-50 px-2 py-0.5 rounded-md">{item.category || 'Standard'}</span>
                                        <div className="flex items-center gap-1 text-amber-400">
                                            <Star className="w-3 h-3 fill-current" />
                                            <span className="text-[10px] font-black text-slate-400">4.9</span>
                                        </div>
                                    </div>
                                    <h4 className="text-xl font-bold text-slate-900 mb-4 line-clamp-2">{item.title}</h4>

                                    <div className="mt-auto pt-6 flex items-center justify-between border-t border-slate-50">
                                        <div className="flex flex-col">
                                            <span className="text-[10px] font-bold text-slate-300 uppercase tracking-tighter">Availability</span>
                                            <span className="text-xs font-black text-emerald-500">In Stock</span>
                                        </div>
                                        <button className="h-12 w-12 bg-slate-900 text-white rounded-2xl flex items-center justify-center hover:bg-blue-600 transition-all group-hover:scale-110 shadow-lg shadow-slate-100">
                                            <ShoppingBag className="w-5 h-5" />
                                        </button>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </motion.div>
            </section>

            {/* Business Solutions Section */}
            <section id="solutions" className="py-24 bg-slate-900 overflow-hidden relative">
                <div className="absolute top-0 right-0 w-1/3 h-full bg-blue-600/10 skew-x-12 translate-x-20" />
                <div className="max-w-7xl mx-auto px-6 relative z-10">
                    <div className="mb-20">
                        <span className="text-[10px] uppercase tracking-[0.4em] text-blue-400 font-bold mb-4 block">Enterprise Services</span>
                        <h2 className="text-4xl md:text-6xl font-black text-white uppercase tracking-tight">Business Solutions</h2>
                    </div>

                    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-12">
                        {services.map((service, i) => (
                            <motion.div
                                key={service.id}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                transition={{ delay: i * 0.1 }}
                                className="p-10 bg-white/5 border border-white/10 rounded-[40px] hover:bg-white/10 hover:border-blue-500/50 transition-all group"
                            >
                                <div className="w-14 h-14 bg-blue-600/20 rounded-2xl flex items-center justify-center mb-10 group-hover:scale-110 transition-transform">
                                    <Layers className="w-7 h-7 text-blue-400" />
                                </div>
                                <h3 className="text-2xl font-bold text-white mb-6 uppercase tracking-tight">{service.title}</h3>
                                <p className="text-white/40 leading-relaxed mb-10 text-sm font-medium">{service.description}</p>
                                <button className="w-full py-4 border border-white/20 text-white rounded-2xl font-bold text-[10px] uppercase tracking-widest hover:bg-blue-600 hover:border-blue-600 transition-all">Enquire Service</button>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Performance Stats */}
            <section id="performance" className="py-24 max-w-7xl mx-auto px-6">
                <div className="bg-white rounded-[48px] p-12 md:p-24 border border-slate-100 shadow-2xl shadow-slate-200/50 flex flex-col md:flex-row items-center justify-between gap-16">
                    <div className="max-w-md">
                        <h2 className="text-4xl font-black text-slate-900 mb-6 uppercase tracking-tight">Operational Excellence</h2>
                        <p className="text-slate-500 font-medium leading-relaxed italic">
                            "Our commitment to quality ensures that every partner interaction and transaction on this portal delivers peak performance and reliability."
                        </p>
                    </div>
                    <div className="grid grid-cols-2 gap-12 w-full md:w-auto">
                        <div className="text-center md:text-left">
                            <div className="text-6xl font-black text-slate-900 mb-2">99<span className="text-blue-600">%</span></div>
                            <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Satisfaction</div>
                        </div>
                        <div className="text-center md:text-left">
                            <div className="text-6xl font-black text-slate-900 mb-2">24<span className="text-blue-600">/7</span></div>
                            <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Availability</div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer id="footer" className="bg-slate-50 py-24 px-6 border-t border-slate-100">
                <div className="max-w-7xl mx-auto">
                    <div className="grid md:grid-cols-4 gap-16 mb-20">
                        <div className="md:col-span-2">
                            <div className="w-12 h-12 bg-slate-900 rounded-xl flex items-center justify-center text-white font-bold text-2xl mb-8">
                                {profile.shop_name?.charAt(0) || profile.name?.charAt(0)}
                            </div>
                            <h3 className="text-2xl font-black text-slate-900 mb-6 uppercase tracking-tighter">{profile.shop_name || profile.name}</h3>
                            <p className="max-w-xs text-slate-400 font-medium leading-relaxed">{profile.bio}</p>
                        </div>
                        <div>
                            <h5 className="text-[10px] font-black text-slate-900 uppercase tracking-[0.3em] mb-10">Network</h5>
                            <div className="flex flex-col gap-6">
                                <a href={`tel:${profile.phone_no}`} className="text-sm font-bold text-slate-500 hover:text-blue-600 transition-colors flex items-center gap-4">
                                    <div className="h-10 w-10 bg-white rounded-xl flex items-center justify-center shadow-sm"><Phone className="w-4 h-4" /></div>
                                    {profile.phone_no}
                                </a>
                                {profile.insta_id && (
                                    <a href={profile.insta_link} className="text-sm font-bold text-slate-500 hover:text-blue-600 transition-colors flex items-center gap-4">
                                        <div className="h-10 w-10 bg-white rounded-xl flex items-center justify-center shadow-sm"><Globe className="w-4 h-4" /></div>
                                        @{profile.insta_id}
                                    </a>
                                )}
                            </div>
                        </div>
                        <div>
                            <h5 className="text-[10px] font-black text-slate-900 uppercase tracking-[0.3em] mb-10">Status</h5>
                            <div className="inline-flex items-center gap-3 px-4 py-2 bg-emerald-50 text-emerald-600 rounded-full">
                                <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse" />
                                <span className="text-[10px] font-black uppercase tracking-widest">Systems Online</span>
                            </div>
                        </div>
                    </div>
                    <div className="pt-10 border-t border-slate-200 flex flex-col md:flex-row justify-between items-center gap-8">
                        <p className="text-[10px] font-bold text-slate-300 uppercase tracking-[0.3em]">© 2026 Handskill Protocol Service</p>
                        <div className="flex gap-10">
                            <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest cursor-pointer hover:text-slate-900 transition-colors">Infrastructure</span>
                            <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest cursor-pointer hover:text-slate-900 transition-colors">Security</span>
                        </div>
                    </div>
                </div>
            </footer>
        </div>
    );
};

export default ProfilePage;
