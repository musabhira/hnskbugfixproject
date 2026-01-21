
import sys

try:
    with open('chat_analysis.txt', 'r', encoding='utf-16le') as f:
        print(f.read())
except Exception as e:
    print(f"UTF-16LE failed: {e}")
    try:
        with open('chat_analysis.txt', 'r', encoding='utf-8') as f:
            print(f.read())
    except Exception as e2:
        print(f"UTF-8 failed: {e2}")
