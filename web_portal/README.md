# Handskill Web Portal

A premium, high-speed profile experience for Handskill users.

## Features
- **Instant Search**: Find any user by their unique slug.
- **Premium Profile**: Beautiful landing pages for every user.
- **Gallery & Services**: Full showcase of user's portfolio and offerings.
- **Thoughts/Threads**: Read the latest updates from any user.
- **Dynamic Styling**: Profiles adapt to the user's preferred colors.

## Tech Stack
- React (Vite)
- Tailwind CSS
- Framer Motion
- Lucide React
- Supabase

## How to Deploy
1. Build the project:
   ```bash
   cd web_portal
   npm install
   npm run build
   ```
2. Deploy to Firebase:
   ```bash
   firebase deploy --only hosting
   ```
   *(Note: Ensure your firebase.json points to `web_portal/dist`)*
