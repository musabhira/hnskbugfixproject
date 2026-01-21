
import os
try:
    with open('gallery_log_2.txt', 'r', encoding='utf-8') as f:
        print(f.read())
except:
    try:
        with open('gallery_log_2.txt', 'r', encoding='utf-16') as f:
            print(f.read())
    except:
        pass
