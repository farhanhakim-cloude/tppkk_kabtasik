import 'dart:io';

void main() {
  final directory = Directory('lib');
  
  final replacements = {
    '0xFF0F9E8E': '0xFF2563EB', // Teal -> Blue
    '0xFFF5FAF9': '0xFFF8FAFC', // Teal-white -> Slate-50
    '0xFF009688': '0xFF3B82F6', // Darker Teal -> Blue
    '// teal, sesuai referensi': '// blue, sesuai permintaan'
  };

  for (var entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      var newContent = content;
      
      replacements.forEach((oldStr, newStr) {
        newContent = newContent.replaceAll(oldStr, newStr);
      });
      
      if (content != newContent) {
        entity.writeAsStringSync(newContent);
        print('Updated ${entity.path}');
      }
    }
  }
}
