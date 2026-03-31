import 'dart:io';

void main() {
  final file = File('lib/custom_code/widgets/verfied_search_profile_detail_page.dart');
  if (!file.existsSync()) return;
  
  var content = file.readAsStringSync();
  final regex = RegExp(r'\.withOpacity\(\s*([\d\.]+(?:\s*\*\s*[\d\.]+)?)\s*\)', multiLine: true);
  
  content = content.replaceAllMapped(regex, (match) {
    return '.withValues(alpha: ${match.group(1)})';
  });
  
  file.writeAsStringSync(content);
  print('Done!');
}
