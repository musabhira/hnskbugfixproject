
import os

try:
    with open('analysis_log.txt', 'r', encoding='utf-8') as f:
        print(f.read())
except Exception as e:
    # Try different encoding
    try:
        with open('analysis_log.txt', 'r', encoding='utf-16') as f:
            print(f.read())
    except Exception as e2:
        print(f"Error reading file: {e}, {e2}")
