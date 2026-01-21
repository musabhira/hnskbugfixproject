
import os

path = r'f:\pocket-mates-app-ne72dv\lib\custom_code\widgets\gallery_profile_search_page.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'ScaffoldMessenger.of(context)' in line:
        print(f"Line {i+1}: {line.strip()}")
        # Check if there was an await in the last 10 lines
        found_await = False
        for j in range(max(0, i-10), i):
            if 'await' in lines[j]:
                found_await = True
                print(f"  Found await at line {j+1}: {lines[j].strip()}")
        if found_await:
            print("  POTENTIAL ASYNC GAP ISSUE")
