import 'dart:io';

void main() {
  final dir = Directory('lib/custom_code/widgets');
  if (!dir.existsSync()) return;
  
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (var file in files) {
    var content = file.readAsStringSync();
    final regex = RegExp(r'\.withOpacity\(\s*([\d\.]+(?:\s*\*\s*[\d\.]+)?)\s*\)', multiLine: true);
    
    if (regex.hasMatch(content)) {
      content = content.replaceAllMapped(regex, (match) {
        return '.withValues(alpha: ${match.group(1)})';
      });
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }
  print('Done!');
}
