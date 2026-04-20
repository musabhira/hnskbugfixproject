
import os

file_path = r'f:\pocket-mates-app-ne72dv\lib\custom_code\widgets\courses_widget.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
fixed = False
for line in lines:
    new_lines.append(line)
    if 'void _showWhatsAppPaymentSheet1() {' in line and not fixed:
        # Check if previous non-empty line was a single '}'
        for i in range(len(new_lines) - 2, -1, -1):
            if new_lines[i].strip() == '}':
                # Found the catch closure, now need method closure
                new_lines.insert(i + 1, '  }\n\n')
                fixed = True
                break
            elif new_lines[i].strip() != '':
                break

if fixed:
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print("Fixed successfully")
else:
    print("Could not find insertion point")
