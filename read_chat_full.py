
import sys

def read_full():
    encodings = ['utf-16le', 'utf-16', 'utf-8', 'latin-1']
    for enc in encodings:
        try:
            with open('chat_analysis.txt', 'r', encoding=enc) as f:
                content = f.read()
                if content:
                    print(content)
                    return
        except:
            continue

read_full()
