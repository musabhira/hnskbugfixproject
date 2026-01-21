
try:
    with open('final_analysis_8.txt', 'r', encoding='utf-8') as f:
        for line in f:
            print(line.strip())
except:
    try:
        with open('final_analysis_8.txt', 'r', encoding='utf-16') as f:
            for line in f:
                print(line.strip())
    except Exception as e:
        print(e)
