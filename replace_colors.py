import os

replacements = {
    "0xFF0F9E8E": "0xFF2563EB", # Primary teal -> Blue 600
    "0xFFF5FAF9": "0xFFF8FAFC", # Teal-white bg -> Slate 50 bg (clean blue-white)
    "0xFF009688": "0xFF3B82F6", # Galeri & Agenda teal -> Blue 500
    "const Color(0xFFF5FAF9)": "Colors.white", # Make some backgrounds pure white if needed, but let's stick to the color code replacement
}

directory = r"c:\Users\HP ELITEBOOK\tppkk_kabtasik\lib"

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            for old, new in replacements.items():
                new_content = new_content.replace(old, new)
            
            # Additional logic for main.dart to update the comment
            if file == "main.dart":
                new_content = new_content.replace("// teal, sesuai referensi", "// blue, sesuai permintaan")
            
            if content != new_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
