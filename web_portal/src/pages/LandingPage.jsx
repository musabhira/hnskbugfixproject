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
        <div className="flex flex-col items-center justify-center min-h-screen p-6 bg-[#f8fafc] overflow-hidden relative font-sans">
            {/* Professional Grid Background */}
            <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-[0.03]" />
            <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-slate-200 via-slate-800 to-slate-200" />

            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="z-10 text-center max-w-3xl"
            >
                <div className="flex items-center justify-center mb-10">
                    <motion.div
                        whileHover={{ scale: 1.05 }}
                        className="w-20 h-20 bg-white rounded-[24px] flex items-center justify-center shadow-xl shadow-slate-200 border border-slate-100"
                    >
                        <Briefcase className="text-slate-900 w-10 h-10" />
                    </motion.div>
                </div>

                <h1 className="text-5xl md:text-8xl font-black mb-8 text-slate-900 tracking-tighter leading-none uppercase">
                    Partner <br /> <span className="text-slate-400">Portal</span>
                </h1>

                <p className="text-slate-500 text-lg md:text-xl mb-12 max-w-lg mx-auto leading-relaxed font-medium">
                    The exclusive digital infrastructure for **Handskill Premium Members**. Access verified corporate identities and boutique services.
                </p>

                <form onSubmit={handleSearch} className="relative max-w-xl mx-auto group">
                    <div className="absolute inset-0 bg-slate-900/5 blur-2xl rounded-3xl -z-10 group-focus-within:bg-slate-900/10 transition-all" />
                    <input
                        type="text"
                        placeholder="Enter partner username..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-full bg-white border border-slate-200 rounded-3xl py-6 px-8 pl-16 text-slate-900 focus:outline-none focus:ring-4 focus:ring-slate-100 transition-all duration-500 shadow-sm text-lg placeholder:text-slate-300"
                    />
                    <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 w-6 h-6 group-focus-within:text-slate-900 transition-colors" />
                    <button
                        type="submit"
                        className="absolute right-4 top-1/2 -translate-y-1/2 bg-slate-900 text-white font-bold px-8 py-3 rounded-2xl hover:bg-slate-800 active:scale-95 transition-all shadow-xl shadow-slate-200 uppercase text-xs tracking-widest"
                    >
                        Access
                    </button>
                </form>

                <div className="mt-20 flex flex-wrap justify-center gap-10">
                    <div className="flex items-center gap-3 grayscale opacity-30 hover:grayscale-0 hover:opacity-100 transition-all cursor-default">
                        <Globe className="w-5 h-5" />
                        <span className="text-[10px] font-bold uppercase tracking-[0.3em]">Global Presence</span>
                    </div>
                    <div className="flex items-center gap-3 grayscale opacity-30 hover:grayscale-0 hover:opacity-100 transition-all cursor-default">
                        <ShieldCheck className="w-5 h-5" />
                        <span className="text-[10px] font-bold uppercase tracking-[0.3em]">Verified Status</span>
                    </div>
                </div>
            </motion.div>

            <footer className="absolute bottom-10 flex flex-col items-center gap-2">
                <span className="text-[9px] font-bold text-slate-300 uppercase tracking-[0.5em]">Network Infrastructure</span>
                <div className="h-4 w-px bg-slate-200" />
                <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest">Powered by <span className="text-slate-900">Handskill Friends</span></p>
            </footer>
        </div>
    );
};

export default LandingPage;
