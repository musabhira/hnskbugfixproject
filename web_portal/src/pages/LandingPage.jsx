import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Briefcase, Globe, ShieldCheck } from 'lucide-react';
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
        <div className="flex flex-col items-center justify-center min-h-screen p-6 bg-[#030303] overflow-hidden relative font-sans text-white">
            {/* Background Effects */}
            <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-slate-900 via-[#0a0a0a] to-black z-0" />
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-purple-900/20 blur-[120px] rounded-full pointer-events-none" />
            <div className="absolute bottom-0 right-0 w-[600px] h-[600px] bg-blue-900/10 blur-[100px] rounded-full pointer-events-none" />

            <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, ease: "easeOut" }}
                className="z-10 text-center max-w-4xl relative w-full"
            >
                {/* Icon */}
                <motion.div
                    whileHover={{ scale: 1.05, rotate: 5 }}
                    className="w-24 h-24 mx-auto mb-12 bg-gradient-to-tr from-slate-800 to-slate-900 rounded-[32px] flex items-center justify-center shadow-2xl shadow-black/50 border border-white/10 relative overflow-hidden group"
                >
                    <div className="absolute inset-0 bg-white/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                    <Briefcase className="text-white/90 w-10 h-10 drop-shadow-lg" strokeWidth={1.5} />
                </motion.div>

                {/* Heading */}
                <h1 className="text-6xl md:text-8xl font-serif font-medium mb-8 text-white tracking-tight leading-[1.1]">
                    Create Your <br />
                    <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-slate-200 to-slate-400 italic font-light">Digital Legacy</span>
                </h1>

                <p className="text-slate-400 text-lg md:text-xl mb-16 max-w-xl mx-auto leading-relaxed font-light tracking-wide">
                    The exclusive portal for **Handskill Premium Partners**.
                    Showcase your verified corporate identity with elegance.
                </p>

                {/* Search Form */}
                <form onSubmit={handleSearch} className="relative max-w-xl mx-auto group">
                    <div className="absolute -inset-1 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 rounded-[35px] opacity-20 group-focus-within:opacity-50 blur-xl transition-all duration-700" />
                    <div className="relative flex items-center bg-white/5 backdrop-blur-xl border border-white/10 rounded-full p-2 transition-all duration-500 group-focus-within:bg-black/40 group-focus-within:border-white/20 shadow-2xl">
                        <div className="pl-6 pr-4 pointer-events-none">
                            <Search className="text-slate-500 w-5 h-5 group-focus-within:text-white transition-colors duration-300" />
                        </div>
                        <input
                            type="text"
                            placeholder="Find a partner..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="flex-1 bg-transparent border-none text-white placeholder-slate-500 focus:outline-none focus:ring-0 text-lg py-4 font-light tracking-wide"
                        />
                        <button
                            type="submit"
                            className="bg-white text-black hover:bg-slate-200 transition-all px-8 py-3.5 rounded-full font-medium text-sm tracking-widest uppercase shadow-lg shadow-white/5"
                        >
                            Visit
                        </button>
                    </div>
                </form>

                {/* Verified Badge */}
                <div className="mt-24 flex flex-wrap justify-center gap-12 opacity-60">
                    <div className="flex items-center gap-3">
                        <Globe className="w-4 h-4 text-slate-400" />
                        <span className="text-[10px] uppercase tracking-[0.2em] font-medium text-slate-400">Global Reach</span>
                    </div>
                    <div className="w-px h-4 bg-white/10" />
                    <div className="flex items-center gap-3">
                        <ShieldCheck className="w-4 h-4 text-slate-400" />
                        <span className="text-[10px] uppercase tracking-[0.2em] font-medium text-slate-400">Verified & Secure</span>
                    </div>
                </div>
            </motion.div>

            {/* Footer */}
            <footer className="absolute bottom-8 left-0 w-full text-center">
                <p className="text-[10px] uppercase tracking-[0.4em] text-white/20 font-medium hover:text-white/40 transition-colors cursor-default">
                    Powered by Handskill Inc.
                </p>
            </footer>
        </div>
    );
};

export default LandingPage;
