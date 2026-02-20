import { useEffect, useState } from 'react';
import { useParams, useSearchParams } from 'react-router-dom';
import { fetchDataBySlug } from '../lib/supabase';
import ProfileDefault from '../templates/ProfileDefault';
import ProfileNeon from '../templates/ProfileNeon';
import ProfileElite from '../templates/ProfileElite';
import ProfileGlass from '../templates/ProfileGlass';

const TEMPLATES = {
    'default': ProfileDefault,
    'neon': ProfileNeon,
    'elite': ProfileElite,
    'glass': ProfileGlass
};

const ProfilePage = () => {
    const { slug } = useParams();
    const [searchParams] = useSearchParams();
    const templateOverride = searchParams.get('template');
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const load = async () => {
            const res = await fetchDataBySlug(slug);
            setData(res);
            setLoading(false);
        };
        load();
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

    const templateId = templateOverride || data.profile.web_template_id || 'default';
    const TemplateComponent = TEMPLATES[templateId] || ProfileDefault;

    return <TemplateComponent data={data} />;
};

export default ProfilePage;
