
import os

path = r'f:\pocket-mates-app-ne72dv\gallery_analysis_2.txt'
if os.path.exists(path):
    with open(path, 'rb') as f:
        data = f.read()
    
    for enc in ['utf-16le', 'utf-16', 'utf-8', 'latin-1']:
        try:
            content = data.decode(enc)
            for line in content.splitlines():
                if ' - ' in line:
                    print(line.strip())
            break
        except:
            continue
