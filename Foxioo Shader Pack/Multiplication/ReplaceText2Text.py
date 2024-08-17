import os

def replace_text_in_file(file_path, old_text, new_text):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    new_content = content.replace(old_text, new_text)
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(new_content)

def main():
    file_extension = input("Podaj rozszerzenie plików (np. .fx): ")
    old_text = input("Podaj tekst do zamiany: ")
    new_text = input("Podaj nowy tekst: ")
    
    current_directory = os.getcwd()
    files_to_modify = [f for f in os.listdir(current_directory) if f.endswith(file_extension)]
    
    for file_name in files_to_modify:
        file_path = os.path.join(current_directory, file_name)
        replace_text_in_file(file_path, old_text, new_text)
        print(f"Zmieniono tekst w pliku: {file_name}")

if __name__ == "__main__":
    main()
