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
        <div className="h-screen flex flex-col items-center justify-center bg-[#0A0A0A]">
            <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 2, ease: "linear" }} className="w-10 h-10 border-2 border-white/10 border-t-white rounded-full mb-4" />
            <span className="text-[10px] uppercase tracking-[0.4em] opacity-20">Authenticating Excellence</span>
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

    const categories = ['All', ...new Set(gallery.map(i => i.category || 'Collection'))];
    const filteredGallery = activeCategory === 'All' ? gallery : gallery.filter(i => (i.category || 'Collection') === activeCategory);

    const scrollTo = (id) => {
        document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
        setMobileMenuOpen(false);
    };

    return (
        <div className="min-h-screen bg-dot-pattern relative" style={{ backgroundColor: theme.bg, color: theme.text }}>
            <div className="noise-overlay" />

            {/* Nav */}
            <nav className={`fixed top-0 inset-x-0 z-[100] transition-all duration-700 ${hasScrolled ? 'py-4 backdrop-blur-2xl bg-black/40 border-b border-white/5' : 'py-8'}`}>
                <div className="max-w-7xl mx-auto px-8 flex justify-between items-center">
                    <button onClick={() => scrollTo('home')} className="flex items-center gap-3 group">
                        <img src={profile.profile_image_url} className="w-10 h-10 rounded-full border border-white/10 object-cover" alt="" />
                        <span className="font-luxury text-xl tracking-wide group-hover:italic transition-all">{profile.shop_name || profile.name}</span>
                    </button>
                    <div className="hidden md:flex gap-10">
                        {['Collection', 'Bespeak', 'Journal'].map(l => (
                            <button key={l} onClick={() => scrollTo(l.toLowerCase())} className="text-[10px] uppercase tracking-[0.3em] opacity-40 hover:opacity-100 transition-all font-bold">{l}</button>
                        ))}
                        <button onClick={() => scrollTo('footer')} className="text-[10px] uppercase tracking-[0.3em] font-bold" style={{ color: theme.primary }}>Contact</button>
                    </div>
                    <button className="md:hidden" onClick={() => setMobileMenuOpen(true)}><Menu className="w-6 h-6" /></button>
                </div>
            </nav>

            <AnimatePresence>
                {mobileMenuOpen && (
                    <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }} className="fixed inset-0 z-[110] bg-black/95 backdrop-blur-3xl flex flex-col items-center justify-center gap-10">
                        <button className="absolute top-10 right-10" onClick={() => setMobileMenuOpen(false)}><X className="w-8 h-8 opacity-40" /></button>
                        {['Home', 'Collection', 'Bespeak', 'Journal'].map(l => (
                            <button key={l} onClick={() => scrollTo(l.toLowerCase().replace('home', 'hero'))} className="font-luxury text-5xl hover:italic transition-all">{l}</button>
                        ))}
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Hero */}
            <section id="home" className="relative h-screen flex items-center justify-center overflow-hidden">
                <motion.div style={{ y: heroY, opacity: heroOpacity }} className="absolute inset-0">
                    <img src={profile.banner_image_url} className="w-full h-full object-cover scale-110" alt="" />
                    <div className="absolute inset-0 bg-black/60 backdrop-blur-[1px]" />
                </motion.div>
                <div className="relative text-center px-6">
                    <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1 }}>
                        {profile.verified && <div className="inline-flex items-center gap-2 px-4 py-2 glass rounded-full mb-8"><Star className="w-3 h-3 text-[#D4AF37] fill-[#D4AF37]" /> <span className="text-[8px] uppercase tracking-[0.4em] font-bold">Verified House</span></div>}
                        <h1 className="text-6xl md:text-9xl font-luxury mb-8">{profile.shop_name || profile.name}</h1>
                        <p className="max-w-xl mx-auto opacity-60 font-light italic text-lg lg:text-xl mb-12">"{profile.bio}"</p>
                        <div className="flex justify-center gap-6">
                            <button onClick={() => scrollTo('collection')} className="px-10 py-4 rounded-full font-bold text-[10px] uppercase tracking-widest shadow-xl transition-transform hover:scale-105" style={{ backgroundColor: theme.primary, color: theme.onPrimary }}>View Showcase</button>
                            <button onClick={() => scrollTo('bespeak')} className="px-10 py-4 rounded-full border border-white/20 text-[10px] uppercase tracking-widest font-bold hover:bg-white/5">Our Ethos</button>
                        </div>
                    </motion.div>
                </div>
            </section>

            {/* The Foundation - Trust Section */}
            <section className="py-32 relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />
                <div className="max-w-7xl mx-auto px-8 relative">
                    <div className="grid md:grid-cols-3 gap-24 text-center">
                        {[
                            { Icon: Award, t: 'The Craft', d: 'Every piece in our collection is curated with an eye for timeless elegance and artisanal detail.' },
                            { Icon: ShieldCheck, t: 'Verified House', d: 'We are a verified boutique partner, ensuring every transaction and product meets our House standards.' },
                            { Icon: Heart, t: 'Bespoke Spirit', d: 'Our services are tailored to your unique identity, moving beyond trends to capture true essence.' }
                        ].map((f, i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, y: 30 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ delay: i * 0.2 }}
                                className="space-y-8 group"
                            >
                                <div className="w-16 h-16 mx-auto rounded-full border border-white/5 flex items-center justify-center group-hover:border-[#D4AF37]/50 transition-all duration-700">
                                    <f.Icon className="w-8 h-8 opacity-20 group-hover:opacity-100 group-hover:text-[#D4AF37] transition-all duration-700" />
                                </div>
                                <h3 className="font-luxury text-3xl tracking-wide italic">{f.t}</h3>
                                <p className="text-sm opacity-40 font-light leading-relaxed max-w-[280px] mx-auto">{f.d}</p>
                            </motion.div>
                        ))}
                    </div>
                </div>
                <div className="absolute bottom-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />
            </section>

            {/* Gallery */}
            <section id="collection" className="py-32 max-w-7xl mx-auto px-8">
                <div className="flex flex-col md:flex-row justify-between items-end mb-20 gap-8">
                    <div>
                        <span className="text-[10px] uppercase tracking-[0.5em] opacity-40 mb-3 block text-gold font-bold">The Archive</span>
                        <h2 className="text-5xl md:text-7xl font-luxury">Featured Pieces</h2>
                    </div>
                    <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-none">
                        {categories.map(c => (
                            <button key={c} onClick={() => setActiveCategory(c)} className={`px-6 py-2 rounded-full text-[10px] uppercase tracking-widest font-bold transition-all ${activeCategory === c ? 'bg-white text-black' : 'border border-white/10 opacity-40 hover:opacity-100'}`}>{c}</button>
                        ))}
                    </div>
                </div>
                <motion.div layout className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-16">
                    <AnimatePresence mode="popLayout">
                        {filteredGallery.map((item, idx) => (
                            <motion.div layout initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.9 }} key={item.id} className="group cursor-pointer">
                                <div className="aspect-[4/5] overflow-hidden bg-white/5 mb-6 relative rounded-sm">
                                    <img src={item.image_url} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110" alt="" />
                                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                        <button className="px-8 py-3 rounded-full text-[10px] uppercase font-bold tracking-widest shadow-2xl transition-transform hover:scale-110" style={{ backgroundColor: theme.primary, color: theme.onPrimary }}>Enquire Now</button>
                                    </div>
                                    {idx % 3 === 0 && <span className="absolute top-6 left-6 text-[8px] font-bold uppercase tracking-widest glass px-3 py-1">Limited Edition</span>}
                                </div>
                                <div className="flex justify-between items-center group-hover:px-2 transition-all">
                                    <h4 className="font-luxury text-2xl opacity-80 group-hover:opacity-100 transition-all">{item.title}</h4>
                                    <ArrowRight className="w-4 h-4 opacity-0 group-hover:opacity-100 -rotate-45 transition-all" />
                                </div>
                                <p className="text-[10px] uppercase tracking-widest opacity-30 mt-1">{item.category}</p>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </motion.div>
            </section>

            {/* Verified Authenticity Section */}
            <section className="py-40 bg-white/[0.01] relative overflow-hidden">
                <div className="max-w-7xl mx-auto px-8 grid lg:grid-cols-2 gap-24 items-center">
                    <motion.div
                        initial={{ opacity: 0, x: -50 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        className="relative"
                    >
                        <div className="aspect-square glass rounded-full flex items-center justify-center p-20 border-[#D4AF37]/20 relative overflow-hidden group">
                            <div className="absolute inset-0 bg-gradient-to-br from-[#D4AF37]/5 to-transparent group-hover:opacity-100 transition-opacity" />
                            <Star className="w-40 h-40 text-[#D4AF37] opacity-20 group-hover:scale-110 group-hover:opacity-40 transition-all duration-1000" />
                            <div className="absolute inset-0 flex items-center justify-center">
                                <div className="text-center">
                                    <div className="font-luxury text-7xl text-gold mb-2">100%</div>
                                    <div className="text-[10px] uppercase tracking-[0.5em] font-bold opacity-40">Authentic</div>
                                </div>
                            </div>
                        </div>
                    </motion.div>
                    <motion.div
                        initial={{ opacity: 0, x: 50 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        className="space-y-10"
                    >
                        <span className="text-[10px] uppercase tracking-[0.5em] text-[#D4AF37] font-bold">Trust & Integrity</span>
                        <h2 className="text-5xl md:text-7xl font-luxury leading-tight italic">Verified <br />Authenticity</h2>
                        <p className="text-lg font-light opacity-50 leading-relaxed italic">
                            "Every piece hosted at {profile.shop_name} undergoes a rigorous verification process. We ensure that our curators maintain the highest levels of quality, craftsmanship, and ethical sourcing."
                        </p>
                        <div className="flex items-center gap-6">
                            <div className="w-12 h-px bg-[#D4AF37]/30" />
                            <span className="text-[10px] uppercase tracking-[0.3em] font-bold opacity-40">The Gold Protocol Applied</span>
                        </div>
                    </motion.div>
                </div>
            </section>

            {/* Services */}
            <section id="bespeak" className="py-32 bg-white/[0.02]">
                <div className="max-w-7xl mx-auto px-8">
                    <div className="grid lg:grid-cols-2 gap-24 items-center">
                        <div className="space-y-8">
                            <span className="text-[10px] uppercase tracking-[0.5em] opacity-40 text-gold font-bold">Services</span>
                            <h2 className="text-5xl md:text-7xl font-luxury leading-tight">Bespoke <br />Curations</h2>
                            <p className="text-xl font-light opacity-50 leading-relaxed italic">"Every detail crafted to mirror your inner elegance."</p>
                            <button className="flex items-center gap-4 group text-[10px] uppercase tracking-widest font-bold">
                                Contact Curators <div className="w-12 h-12 rounded-full border border-white/10 flex items-center justify-center group-hover:bg-white group-hover:text-black transition-all"><ArrowRight className="w-4 h-4" /></div>
                            </button>
                        </div>
                        <div className="space-y-6">
                            {services.map(s => (
                                <div key={s.id} className="glass p-8 rounded-xl hover:bg-white/5 transition-colors group">
                                    <div className="flex justify-between items-center mb-2">
                                        <h4 className="font-luxury text-2xl">{s.title}</h4>
                                        <span className="text-sm font-bold opacity-0 group-hover:opacity-100 transition-opacity" style={{ color: theme.primary }}>{s.price ? `₹${s.price}` : 'Quote'}</span>
                                    </div>
                                    <p className="text-xs opacity-40 font-light">{s.description}</p>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </section>

            {/* Journal */}
            <section id="journal" className="py-40 px-8 relative overflow-hidden">
                <div className="max-w-4xl mx-auto relative z-10">
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        className="text-center mb-32"
                    >
                        <span className="text-[10px] uppercase tracking-[0.5em] text-[#D4AF37] font-bold mb-4 block">Editorial</span>
                        <h2 className="text-6xl md:text-8xl font-luxury italic leading-tight">The Boutique <br />Journal</h2>
                        <div className="w-20 h-px bg-[#D4AF37]/30 mx-auto mt-12" />
                    </motion.div>

                    <div className="space-y-52">
                        {threads.map((t, i) => (
                            <motion.div
                                key={t.id}
                                initial={{ opacity: 0, y: 50 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true, margin: "-100px" }}
                                className="relative group"
                            >
                                <span className="absolute -top-32 -left-20 text-[200px] font-luxury opacity-[0.02] select-none transition-all duration-1000 group-hover:opacity-[0.05] group-hover:-translate-y-4">0{i + 1}</span>
                                <div className="pl-16 md:pl-24 border-l border-white/5 relative group-hover:border-[#D4AF37]/20 transition-all duration-1000">
                                    <div className="absolute top-0 left-0 w-4 h-px bg-[#D4AF37]/50 -translate-x-full" />
                                    <span className="text-[10px] uppercase tracking-[0.4em] opacity-30 block mb-10 font-bold">{new Date(t.created_at).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })}</span>
                                    <h3 className="text-3xl md:text-5xl font-luxury leading-[1.3] tracking-wide mb-12 opacity-80 group-hover:opacity-100 transition-opacity duration-700 italic">
                                        "{t.content}"
                                    </h3>
                                    <div className="flex items-center gap-8 opacity-30 text-[9px] uppercase tracking-[0.4em] font-bold">
                                        <div className="flex items-center gap-2">
                                            <Heart className="w-3 h-3 text-[#D4AF37] fill-[#D4AF37]" />
                                            <span>{t.fake_likes || 0} Appreciated</span>
                                        </div>
                                        <div className="w-px h-3 bg-white/20" />
                                        <button className="hover:text-white transition-colors flex items-center gap-3 group/btn">
                                            Share Entry <Share2 className="w-3 h-3 group-hover/btn:scale-110 transition-transform" />
                                        </button>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer id="footer" className="py-40 px-8 bg-[#050505] relative overflow-hidden">
                <div className="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-[#D4AF37]/20 to-transparent" />
                <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between gap-32 md:items-end relative z-10">
                    <div className="space-y-16">
                        <div className="space-y-4">
                            <span className="text-[10px] uppercase tracking-[0.5em] text-[#D4AF37] font-bold opacity-60">The Final Word</span>
                            <h2 className="text-6xl md:text-9xl font-luxury leading-none">Visit the <br />House.</h2>
                        </div>
                        <div className="flex flex-wrap gap-6">
                            <a href={`mailto:${profile.email}`} className="px-12 py-5 glass rounded-full text-[10px] uppercase tracking-[0.4em] font-bold hover:bg-white hover:text-black transition-all duration-700 hover:scale-105">Email House</a>
                            <a href={`tel:${profile.mobile}`} className="px-12 py-5 glass rounded-full text-[10px] uppercase tracking-[0.4em] font-bold hover:bg-white hover:text-black transition-all duration-700 hover:scale-105">Call House</a>
                        </div>
                    </div>
                    <div className="space-y-20">
                        <div className="flex gap-8">
                            <motion.a whileHover={{ y: -5 }} href="#" className="opacity-40 hover:opacity-100 transition-all duration-500"><Instagram className="w-6 h-6" /></motion.a>
                            <motion.a whileHover={{ y: -5 }} href="#" className="opacity-40 hover:opacity-100 transition-all duration-500"><Share2 className="w-6 h-6" /></motion.a>
                            <motion.a whileHover={{ y: -5 }} href="#" className="opacity-40 hover:opacity-100 transition-all duration-500"><MapPin className="w-6 h-6" /></motion.a>
                        </div>
                        <div className="text-[10px] uppercase tracking-[0.4em] font-bold space-y-4">
                            <div className="opacity-20 space-y-1">
                                <p>© 2024 {profile.shop_name}. All Rights Reserved.</p>
                                <p>Authenticated Boutique House.</p>
                            </div>
                            <div className="flex items-center gap-4 text-gold">
                                <Star className="w-3 h-3 fill-current" />
                                <span className="opacity-100">CRAFTED BY HANDSKILL</span>
                            </div>
                        </div>
                    </div>
                </div>
                {/* Abstract Background Element */}
                <div className="absolute -bottom-20 -right-20 w-96 h-96 rounded-full bg-[#D4AF37]/5 blur-[120px]" />
            </footer>

            {/* Floating Luxury Concierge */}
            {(profile.mobile || profile.phone_no) && (
                <div className="fixed bottom-10 right-10 z-[120] flex flex-col items-end gap-6">
                    <AnimatePresence>
                        {hasScrolled && (
                            <motion.div
                                initial={{ opacity: 0, x: 20 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: 20 }}
                                className="glass px-6 py-3 rounded-full border-[#D4AF37]/30 flex items-center gap-3"
                            >
                                <Star className="w-3 h-3 text-[#D4AF37] fill-[#D4AF37]" />
                                <span className="text-[10px] uppercase tracking-[0.3em] font-bold text-[#D4AF37]">Concierge Online</span>
                            </motion.div>
                        )}
                    </AnimatePresence>
                    <motion.a
                        href={`https://wa.me/${profile.mobile || profile.phone_no}`}
                        target="_blank"
                        rel="noreferrer"
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        className="bg-[#25D366] p-6 rounded-full shadow-[0_20px_60px_rgba(37,211,102,0.4)] animate-float flex items-center gap-4 group relative overflow-hidden"
                    >
                        <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-500" />
                        <MessageCircle className="w-6 h-6 fill-white relative z-10" />
                        <span className="max-w-0 group-hover:max-w-xs overflow-hidden transition-all duration-700 whitespace-nowrap text-[10px] uppercase tracking-[0.4em] font-bold text-white relative z-10">
                            Bespoke Inquiry
                        </span>
                    </motion.a>
                </div>
            )}
        </div>
    );
};

export default ProfilePage;
