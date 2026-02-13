import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { fetchDataBySlug } from '../lib/supabase';
import {
    ChevronLeft,
    MapPin,
    ShoppingBag,
    MessageSquare,
    Heart,
    Share2,
    ExternalLink,
    Verified,
    Image as ImageIcon,
    Briefcase,
    Quote
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const ProfilePage = () => {
    const { slug } = useParams();
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [activeTab, setActiveTab] = useState('gallery');

    useEffect(() => {
        const loadData = async () => {
            setLoading(true);
            const result = await fetchDataBySlug(slug);
            setData(result);
            setLoading(false);
        };
        loadData();
    }, [slug]);

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center min-h-screen bg-premium-black">
                <div className="w-12 h-12 border-4 border-premium-gold/20 border-t-premium-gold rounded-full animate-spin mb-4" />
                <p className="text-gray-400 font-medium tracking-widest animate-pulse uppercase text-xs">Loading Experience</p>
            </div>
        );
    }

    if (!data) {
        return (
            <div className="flex flex-col items-center justify-center min-h-screen p-6 text-center">
                <h2 className="text-3xl font-bold mb-4 font-outfit">Profile Not Found</h2>
                <p className="text-gray-400 mb-8">This digital space hasn't been claimed yet.</p>
                <Link to="/" className="bg-gold-gradient text-black px-6 py-2 rounded-xl font-bold">Return Home</Link>
            </div>
        );
    }

    const { profile, gallery, services, threads } = data;

    const btnColor = profile.button_color_code || '#FFD700';
    const bgColor = profile.bg_color_code || '#0A0A0A';
    const textColor = profile.bg_text_color || '#FFFFFF';

    return (
        <div className="min-h-screen pb-20" style={{ backgroundColor: bgColor, color: textColor }}>
            {/* Banner */}
            <div className="h-64 md:h-80 w-full relative overflow-hidden">
                {profile.banner_image_url ? (
                    <img src={profile.banner_image_url} alt="banner" className="w-full h-full object-cover" />
                ) : (
                    <div className="w-full h-full bg-premium-gray/50" />
                )}
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />

                <Link to="/" className="absolute top-6 left-6 p-2 glass rounded-full hover:bg-white/10 transition-colors">
                    <ChevronLeft className="w-6 h-6" />
                </Link>
            </div>

            {/* Profile Info */}
            <div className="max-w-4xl mx-auto px-6 -mt-20 relative z-10">
                <div className="flex flex-col md:flex-row md:items-end gap-6 mb-8 text-center md:text-left">
                    <motion.div
                        initial={{ scale: 0.8, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        className="w-40 h-40 rounded-3xl border-[6px] border-premium-black overflow-hidden mx-auto md:mx-0 shadow-2xl"
                    >
                        {profile.profile_image_url ? (
                            <img src={profile.profile_image_url} alt={profile.name} className="w-full h-full object-cover" />
                        ) : (
                            <div className="w-full h-full bg-premium-gray flex items-center justify-center">
                                <span className="text-4xl font-bold opacity-30">{profile.name?.[0]}</span>
                            </div>
                        )}
                    </motion.div>

                    <div className="flex-1 pb-2">
                        <div className="flex items-center justify-center md:justify-start gap-2 mb-2">
                            <h1 className="text-4xl font-bold font-outfit">{profile.name || profile.shop_name}</h1>
                            {profile.verified && <Verified className="w-6 h-6 text-blue-400 fill-blue-400/20" />}
                        </div>
                        <div className="flex flex-wrap items-center justify-center md:justify-start gap-4 text-sm font-medium opacity-60">
                            {profile.city && (
                                <div className="flex items-center gap-1.5">
                                    <MapPin className="w-4 h-4" />
                                    {profile.city}, {profile.country}
                                </div>
                            )}
                            {profile.insta_id && (
                                <a href={profile.insta_link} target="_blank" rel="noreferrer" className="flex items-center gap-1.5 hover:text-premium-gold transition-colors">
                                    <ExternalLink className="w-4 h-4" />
                                    @{profile.insta_id}
                                </a>
                            )}
                        </div>
                    </div>

                    <div className="flex gap-3 justify-center">
                        <button className="flex items-center gap-2 px-6 py-3 rounded-2xl font-bold transition-all hover:scale-105 active:scale-95"
                            style={{ backgroundColor: btnColor, color: profile.button_text_color || '#000000' }}
                        >
                            <MessageSquare className="w-5 h-5" />
                            Contact
                        </button>
                        <button className="p-3 glass rounded-2xl hover:bg-white/10 transition-colors">
                            <Share2 className="w-5 h-5" />
                        </button>
                    </div>
                </div>

                {profile.bio && (
                    <p className="text-lg opacity-70 mb-10 max-w-2xl leading-relaxed whitespace-pre-wrap">
                        {profile.bio}
                    </p>
                )}

                {/* Tabs */}
                <div className="flex gap-1 p-1 bg-white/5 rounded-2xl mb-8 backdrop-blur-md border border-white/5">
                    {['gallery', 'services', 'thoughts'].map((tab) => (
                        <button
                            key={tab}
                            onClick={() => setActiveTab(tab)}
                            className={`flex-1 flex items-center justify-center gap-2 py-3.5 rounded-xl font-semibold transition-all duration-300 capitalize ${activeTab === tab ? 'bg-white/10 text-white shadow-xl translate-y-[-1px]' : 'text-white/40 hover:text-white/60'
                                }`}
                        >
                            {tab === 'gallery' && <ImageIcon className="w-4 h-4" />}
                            {tab === 'services' && <Briefcase className="w-4 h-4" />}
                            {tab === 'thoughts' && <Quote className="w-4 h-4" />}
                            {tab}
                        </button>
                    ))}
                </div>

                {/* Content Area */}
                <AnimatePresence mode="wait">
                    <motion.div
                        key={activeTab}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        transition={{ duration: 0.2 }}
                        className="grid gap-6"
                    >
                        {activeTab === 'gallery' && (
                            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                                {gallery.length > 0 ? gallery.map((item) => (
                                    <div key={item.id} className="group relative aspect-square rounded-2xl overflow-hidden glass hover:border-white/20 transition-all shadow-lg hover:-translate-y-1">
                                        <img src={item.image_url} alt={item.title} className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" />
                                        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 p-4 flex flex-col justify-end">
                                            <h3 className="font-bold text-white leading-tight">{item.title}</h3>
                                            <p className="text-white/60 text-xs mt-1 line-clamp-1">{item.category}</p>
                                        </div>
                                    </div>
                                )) : (
                                    <div className="col-span-full py-20 text-center opacity-30">
                                        <ImageIcon className="w-12 h-12 mx-auto mb-4" />
                                        <p>No gallery items shared yet.</p>
                                    </div>
                                )}
                            </div>
                        )}

                        {activeTab === 'services' && (
                            <div className="grid gap-4">
                                {services.length > 0 ? services.map((service) => (
                                    <div key={service.id} className="p-6 rounded-3xl glass hover:bg-white/[0.05] transition-all group border border-white/5">
                                        <div className="flex justify-between items-start gap-4 mb-3">
                                            <div>
                                                <h3 className="text-xl font-bold font-outfit group-hover:text-premium-gold transition-colors">{service.title}</h3>
                                                <span className="text-xs font-bold uppercase tracking-widest opacity-40 mt-1 block">{service.category}</span>
                                            </div>
                                            <div className="text-xl font-bold text-premium-gold bg-premium-gold/10 px-4 py-2 rounded-2xl">
                                                ₹{service.price}
                                            </div>
                                        </div>
                                        <p className="opacity-60 leading-relaxed">{service.description}</p>
                                        <button className="mt-6 w-full py-4 rounded-2xl bg-white/5 font-bold hover:bg-white/10 transition-all border border-white/5 active:scale-[0.98]">
                                            Enquire Service
                                        </button>
                                    </div>
                                )) : (
                                    <div className="py-20 text-center opacity-30">
                                        <Briefcase className="w-12 h-12 mx-auto mb-4" />
                                        <p>No services listed yet.</p>
                                    </div>
                                )}
                            </div>
                        )}

                        {activeTab === 'thoughts' && (
                            <div className="grid gap-4">
                                {threads.length > 0 ? threads.map((thread) => (
                                    <div key={thread.id} className="p-8 rounded-3xl glass border border-white/5 relative overflow-hidden group">
                                        <div className="absolute top-0 right-0 p-8 opacity-5 group-hover:opacity-10 transition-opacity">
                                            <Quote className="w-16 h-16" />
                                        </div>
                                        <p className="text-xl leading-relaxed font-medium mb-6 relative z-10">
                                            {thread.content}
                                        </p>
                                        <div className="flex items-center gap-6 opacity-40 text-sm font-bold relative z-10">
                                            <div className="flex items-center gap-2">
                                                <Heart className="w-4 h-4" />
                                                {thread.fake_likes || 0}
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <MessageSquare className="w-4 h-4" />
                                                Explore
                                            </div>
                                            <div className="ml-auto text-xs opacity-50">
                                                {new Date(thread.created_at).toLocaleDateString()}
                                            </div>
                                        </div>
                                    </div>
                                )) : (
                                    <div className="py-20 text-center opacity-30">
                                        <Quote className="w-12 h-12 mx-auto mb-4" />
                                        <p>No thoughts shared yet.</p>
                                    </div>
                                )}
                            </div>
                        )}
                    </motion.div>
                </AnimatePresence>
            </div>

            <nav className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50">
                <div className="glass px-8 py-4 rounded-full flex items-center gap-6 shadow-2xl border border-white/10">
                    <Link to="/" className="opacity-50 hover:opacity-100 transition-opacity font-bold text-xs uppercase tracking-tighter">Handskill</Link>
                    <div className="w-px h-4 bg-white/10" />
                    <p className="text-[10px] font-bold uppercase tracking-[0.2em] opacity-30">Premium Experience</p>
                </div>
            </nav>
        </div>
    );
};

export default ProfilePage;
