import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Sparkles } from 'lucide-react';
import { motion } from 'framer-motion';

const LandingPage = () => {
    const [search, setSearch] = useState('');
    const navigate = useNavigate();

    const handleSearch = (e) => {
        e.preventDefault();
        if (search.trim()) {
            navigate(`/${search.toLowerCase().replace(/\s+/g, '-')}`);
        }
    };

    return (
        <div className="flex flex-col items-center justify-center min-h-screen p-6 overflow-hidden relative">
            {/* Background Orbs */}
            <div className="absolute top-1/4 -left-20 w-80 h-80 bg-gold-gradient opacity-10 blur-[100px] rounded-full" />
            <div className="absolute bottom-1/4 -right-20 w-80 h-80 bg-blue-500 opacity-5 blur-[100px] rounded-full" />

            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="z-10 text-center max-w-2xl"
            >
                <div className="flex items-center justify-center mb-6">
                    <div className="w-16 h-16 bg-gold-gradient rounded-2xl flex items-center justify-center shadow-2xl">
                        <Sparkles className="text-black w-8 h-8" />
                    </div>
                </div>

                <h1 className="text-5xl md:text-7xl font-bold mb-6 font-outfit tracking-tight">
                    Your Premium <span className="text-gold">Digital Space</span>
                </h1>

                <p className="text-gray-400 text-lg md:text-xl mb-10 max-w-lg mx-auto leading-relaxed">
                    Access every user's premium profile, gallery, and services in a beautiful, high-speed experience.
                </p>

                <form onSubmit={handleSearch} className="relative max-w-md mx-auto group">
                    <input
                        type="text"
                        placeholder="Search by username (e.g. musabhira)"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-full bg-premium-gray/50 border border-white/10 rounded-2xl py-5 px-6 pl-14 text-white focus:outline-none focus:border-premium-gold/50 transition-all duration-300 glass group-hover:border-white/20"
                    />
                    <Search className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-500 w-5 h-5 group-focus-within:text-premium-gold transition-colors" />
                    <button
                        type="submit"
                        className="absolute right-3 top-1/2 -translate-y-1/2 bg-gold-gradient text-black font-semibold px-6 py-2.5 rounded-xl hover:scale-105 active:scale-95 transition-all shadow-lg"
                    >
                        Visit
                    </button>
                </form>

                <div className="mt-16 flex flex-wrap justify-center gap-8 opacity-40">
                    <div className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full bg-gold-gradient" />
                        <span className="text-sm font-medium uppercase tracking-widest">Gallery</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full bg-gold-gradient" />
                        <span className="text-sm font-medium uppercase tracking-widest">Services</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full bg-gold-gradient" />
                        <span className="text-sm font-medium uppercase tracking-widest">Thoughts</span>
                    </div>
                </div>
            </motion.div>

            <footer className="absolute bottom-8 text-gray-600 text-sm">
                Powered by <span className="text-gray-400 font-semibold tracking-wide">HANDSKILL</span>
            </footer>
        </div>
    );
};

export default LandingPage;
