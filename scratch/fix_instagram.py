import os

files = [
    'web_portal/src/templates/ProfileDefault.jsx',
    'web_portal/src/templates/ProfileNeon.jsx',
    'web_portal/src/templates/ProfileElite.jsx',
    'web_portal/src/templates/ProfileGlass.jsx',
    'web_portal/src/templates/ProfileThreeJS.jsx'
]

instagram_svg = """
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
"""

for path in files:
    if not os.path.exists(path):
        print(f"Skipping {path} - not found")
        continue
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove from imports
    content = content.replace('Instagram, ', '')
    content = content.replace(', Instagram', '')
    
    # Find '} from \'lucide-react\';' and insert the SVG after that line
    target = "} from 'lucide-react';"
    idx = content.find(target)
    if idx != -1:
        insert_pos = idx + len(target)
        new_content = content[:insert_pos] + "\n" + instagram_svg + "\n" + content[insert_pos:]
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Successfully processed {path}")
    else:
        print(f"Failed to find import statement in {path}")
