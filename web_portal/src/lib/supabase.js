import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://gswhynuabdspnwudltth.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzd2h5bnVhYmRzcG53dWRsdHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1NzMyNTcsImV4cCI6MjAzOTE0OTI1N30.zHIM5iEITnzAzED7neVkMJR7VAHIlSpR_ipNLSPhH_U';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export const fetchDataBySlug = async (slug) => {
    // 1. Get profile
    const { data: profile, error: profileError } = await supabase
        .from('profile')
        .select('*')
        .eq('slug', slug)
        .single();

    if (profileError || !profile) return null;

    const userId = profile.user_id;

    // 2. Get gallery, threads, banners in parallel
    const [galleryRes, threadsRes, bannersRes] = await Promise.all([
        supabase.from('gallery').select('*').eq('user_id', userId).order('created_at', { ascending: false }),
        supabase.from('threads').select('*').eq('user_id', userId).order('created_at', { ascending: false }),
        supabase.from('premiumbannergallery').select('*').eq('user_id', userId).order('created_at', { ascending: false })
    ]);

    const allGallery = galleryRes.data || [];
    const galleryItems = allGallery.filter(item => item.is_service !== true);
    const serviceItems = allGallery.filter(item => item.is_service === true);

    return {
        profile,
        gallery: galleryItems,
        services: serviceItems,
        threads: threadsRes.data || [],
        banners: bannersRes.data || []
    };
};
