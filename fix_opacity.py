
import re
import os

files = [
    r'f:\pocket-mates-app-ne72dv\lib\custom_code\widgets\message_screen.dart',
    r'f:\pocket-mates-app-ne72dv\lib\custom_code\widgets\gallery_profile_search_page.dart'
]

def fix_opacity(content):
    # Regex to find .withOpacity(value)
    # Handles simple values (0.5, variable)
    # Does not handle nested parenthesis well, but withOpacity usually has simple args
    pattern = r'\.withOpacity\(([^)]+)\)'
    replacement = r'.withValues(alpha: \1)'
    return re.sub(pattern, replacement, content)

for file_path in files:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = fix_opacity(content)
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {file_path}")
        else:
            print(f"No changes for {file_path}")
    else:
        print(f"File not found: {file_path}")
