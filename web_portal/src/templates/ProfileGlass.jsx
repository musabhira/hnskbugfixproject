import { useState } from 'react';
import {
    X, MapPin, Mail, Phone, ShoppingBag,
    Star, ArrowRight, Briefcase, MessageCircle, ShieldCheck, Quote, Hash, Award, HandMetal
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

const ProfileGlass = ({ data }) => {
    const { profile, gallery, services, threads = [], banners = [] } = data;
    const [selectedItem, setSelectedItem] = useState(null);
    const accentColor = profile.button_color_code || '#6366f1'; // Indigo

    return (
        <div className="min-h-screen bg-[#050510] text-white font-sans selection:bg-white/20 relative overflow-x-hidden">
            {/* Background Orbs */}
            <div className="fixed inset-0 overflow-hidden pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] rounded-full blur-[120px]"
                    style={{ background: `radial-gradient(circle, ${hexToRgba(accentColor, 0.2)} 0%, transparent 70%)` }} />
                <div className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full blur-[120px]"
                    style={{ background: `radial-gradient(circle, ${hexToRgba(accentColor, 0.15)} 0% , transparent 70%)` }} />
            </div>

            {/* Main Content Wrapper */}
            <div className="relative z-10 p-6 md:p-12">

                {/* Hero Bubble */}
                <motion.section
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="max-w-6xl mx-auto backdrop-blur-3xl bg-white/5 border border-white/10 rounded-[40px] p-8 md:p-20 overflow-hidden relative"
                >
                    <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full blur-3xl -mr-32 -mt-32" />

                    <div className="flex flex-col lg:flex-row items-center gap-12 lg:gap-24 relative">
                        <div className="relative">
                            <motion.div
                                animate={{ y: [0, -20, 0] }}
                                transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
                                className="w-64 h-64 md:w-80 md:h-80 rounded-full p-2 bg-gradient-to-tr from-white/20 to-transparent shadow-2xl"
                            >
                                <img src={profile.profile_image_url} alt={profile.name} className="w-full h-full object-cover rounded-full" />
                            </motion.div>
                            {profile.verified && (
                                <motion.div
                                    whileHover={{ scale: 1.2 }}
                                    className="absolute bottom-4 right-4 bg-white/10 backdrop-blur-xl border border-white/20 p-4 rounded-3xl"
                                >
                                    <ShieldCheck className="w-6 h-6 text-white" />
                                </motion.div>
                            )}
                        </div>

                        <div className="flex-1 text-center lg:text-left">
                            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-xs font-bold tracking-widest uppercase mb-8">
                                <span className="w-2 h-2 rounded-full elite-bg shadow-[0_0_8px_var(--accent-color)]" style={{ backgroundColor: accentColor }} />
                                Bubble Glass Profile
                            </div>
                            <h1 className="text-5xl md:text-7xl font-black mb-8 tracking-tight">
                                {profile.shop_name || profile.name}
                            </h1>
                            <p className="text-lg md:text-xl text-white/50 leading-relaxed mb-12 max-w-xl">
                                {profile.bio || "Crafting digital experiences through the lens of modern design. Part of the specialized Handskill creators network."}
                            </p>
                            <div className="flex flex-wrap gap-4 justify-center lg:justify-start">
                                <motion.button
                                    whileHover={{ scale: 1.05 }}
                                    whileTap={{ scale: 0.95 }}
                                    onClick={() => window.open(`https://wa.me/${profile.phone_no}`, '_blank')}
                                    style={{ backgroundColor: accentColor, boxShadow: `0 20px 40px ${hexToRgba(accentColor, 0.3)}` }}
                                    className="px-10 py-5 rounded-[24px] font-black uppercase text-sm tracking-widest"
                                >
                                    Contact Me
                                </motion.button>
                                <motion.button
                                    whileHover={{ backgroundColor: 'rgba(255,255,255,0.1)' }}
                                    className="px-10 py-5 rounded-[24px] border border-white/10 font-bold uppercase text-sm tracking-widest backdrop-blur-md"
                                >
                                    View Library
                                </motion.button>
                            </div>
                        </div>
                    </div>
                </motion.section>

                {/* Scroller for Banners */}
                {banners.length > 0 && (
                    <section className="py-24 max-w-7xl mx-auto">
                        <div className="flex items-center justify-between mb-12 px-4">
                            <h2 className="text-3xl font-black italic tracking-tight">The Lab</h2>
                            <div className="flex gap-2">
                                <div className="w-12 h-px bg-white/10" />
                                <div className="w-12 h-px bg-white/30" />
                            </div>
                        </div>
                        <div className="flex gap-8 overflow-x-auto pb-8 scrollbar-hide px-4">
                            {banners.map(banner => (
                                <motion.div
                                    key={banner.id}
                                    whileHover={{ y: -10 }}
                                    className="min-w-[300px] md:min-w-[450px] aspect-[16/10] rounded-[40px] overflow-hidden relative border border-white/5 shadow-2xl group cursor-pointer"
                                    onClick={() => setSelectedItem(banner)}
                                >
                                    <img src={banner.image_url} alt="" className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110" />
                                    <div className="absolute inset-x-0 bottom-0 p-10 bg-gradient-to-t from-black/80 to-transparent">
                                        <h3 className="text-xl font-bold">{banner.title}</h3>
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </section>
                )}

                {/* Mosaic Gallery */}
                <section className="py-24 max-w-7xl mx-auto px-4">
                    <h2 className="text-4xl font-black tracking-tight mb-16 text-center">Selected Artifacts</h2>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-8">
                        {gallery.map((item, idx) => (
                            <motion.div
                                key={item.id}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                transition={{ delay: idx * 0.05 }}
                                className={`rounded-[32px] overflow-hidden relative cursor-pointer group shadow-2xl ${idx % 3 === 0 ? 'md:col-span-2 md:row-span-2' : ''}`}
                                onClick={() => setSelectedItem(item)}
                            >
                                <img src={item.gallery_image_url || item.image_url} alt="" className="w-full h-full object-cover" />
                                <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-end p-8">
                                    <p className="text-[10px] font-bold tracking-[0.2em] mb-2" style={{ color: accentColor }}>{item.gallery_category}</p>
                                    <h4 className="text-xl font-bold">{item.gallery_title}</h4>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </section>

                {/* Floating Services */}
                {services.length > 0 && (
                    <section className="py-24 max-w-6xl mx-auto">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                            {services.map((service) => (
                                <motion.div
                                    key={service.id}
                                    whileHover={{ scale: 1.02 }}
                                    className="p-10 rounded-[48px] bg-white/5 border border-white/10 backdrop-blur-xl relative overflow-hidden group"
                                >
                                    <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/5 rounded-full blur-3xl group-hover:bg-accent/20 transition-all" style={{ backgroundColor: hexToRgba(accentColor, 0.05) }} />
                                    <div className="p-4 rounded-3xl bg-white/5 border border-white/10 inline-flex mb-8">
                                        <Award className="w-6 h-6" style={{ color: accentColor }} />
                                    </div>
                                    <h3 className="text-2xl font-bold mb-4">{service.service_title}</h3>
                                    <p className="text-white/40 leading-relaxed mb-8">{service.service_description}</p>
                                    <div className="flex items-center justify-between mt-auto">
                                        <span className="text-2xl font-black">{service.service_price}</span>
                                        <div className="px-6 py-2 rounded-full bg-white text-black text-[10px] font-bold tracking-widest uppercase">Premium</div>
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </section>
                )}

                {/* Organic Footer */}
                <footer className="mt-32 pt-24 pb-12 border-t border-white/5 text-center">
                    <div className="flex items-center justify-center gap-12 mb-16 px-6">
                        <div className="p-4 rounded-full bg-white/5 border border-white/10 hover:elite-bg transition-all cursor-pointer"><Instagram className="w-5 h-5" /></div>
                        <div className="p-4 rounded-full bg-white/5 border border-white/10 hover:elite-bg transition-all cursor-pointer"><Phone className="w-5 h-5" /></div>
                        <div className="p-4 rounded-full bg-white/5 border border-white/10 hover:elite-bg transition-all cursor-pointer"><Mail className="w-5 h-5" /></div>
                    </div>
                    <div className="text-5xl md:text-8xl font-black opacity-5 mb-8 tracking-tighter uppercase">{profile.shop_name || profile.name}</div>
                </footer>
            </div>

            {/* Detail Modal */}
            <AnimatePresence>
                {selectedItem && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 z-[110] flex items-center justify-center p-4 bg-black/80 backdrop-blur-3xl"
                        onClick={() => setSelectedItem(null)}
                    >
                        <motion.div
                            initial={{ scale: 0.9, y: 30 }}
                            animate={{ scale: 1, y: 0 }}
                            className="bg-[#0f0f1a] border border-white/10 max-w-4xl w-full rounded-[48px] overflow-hidden relative shadow-2xl"
                            onClick={e => e.stopPropagation()}
                        >
                            <button onClick={() => setSelectedItem(null)} className="absolute top-8 right-8 p-3 rounded-full bg-black/40 border border-white/10 hover:bg-white/10 transition-all z-20">
                                <X className="w-6 h-6" />
                            </button>
                            <div className="flex flex-col md:flex-row h-full max-h-[90vh]">
                                <div className="flex-1 min-h-[40vh] relative">
                                    <img src={selectedItem.gallery_image_url || selectedItem.image_url} alt="" className="w-full h-full object-cover" />
                                </div>
                                <div className="flex-1 p-12 md:p-16 flex flex-col justify-center bg-white/2 overflow-y-auto">
                                    <div className="inline-flex px-4 py-1 rounded-full bg-white/5 border border-white/10 text-[10px] font-bold tracking-widest uppercase mb-6" style={{ color: accentColor }}>{selectedItem.gallery_category || "Vault"}</div>
                                    <h2 className="text-4xl font-black mb-6 tracking-tight">{selectedItem.gallery_title || selectedItem.title}</h2>
                                    <p className="text-white/50 leading-relaxed mb-10 text-lg">{selectedItem.gallery_description || selectedItem.description}</p>
                                    <div className="flex items-center gap-6 mt-auto">
                                        {selectedItem.gallery_price && <span className="text-3xl font-black">{selectedItem.gallery_price}</span>}
                                        <button style={{ backgroundColor: accentColor }} className="flex-1 py-5 rounded-[24px] font-black uppercase tracking-widest text-xs">Aquire Item</button>
                                    </div>
                                </div>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default ProfileGlass;
