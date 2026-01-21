
print("Reading file...")
try:
    with open('full_analysis.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        for line in lines:
            print(line.strip())
except:
    try:
        with open('full_analysis.txt', 'r', encoding='utf-16') as f:
            lines = f.readlines()
            for line in lines:
                print(line.strip())
    except Exception as e:
        print(f"Error: {e}")
