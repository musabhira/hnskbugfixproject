/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                premium: {
                    gold: '#FFD700',
                    black: '#0A0A0A',
                    gray: '#1A1A1A',
                    overlay: 'rgba(255, 255, 255, 0.05)',
                }
            },
            backgroundImage: {
                'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
            }
        },
    },
    plugins: [],
}
