import os

def rename_files_with_extension(file_extension, old_text, new_text):
    current_directory = os.getcwd()
    files_to_rename = [f for f in os.listdir(current_directory) if f.endswith(file_extension)]
    
    for file_name in files_to_rename:
        if old_text in file_name:
            new_file_name = file_name.replace(old_text, new_text)
            old_file_path = os.path.join(current_directory, file_name)
            new_file_path = os.path.join(current_directory, new_file_name)
            os.rename(old_file_path, new_file_path)
            print(f"Zmieniono nazwę pliku: {file_name} na {new_file_name}")

def main():
    file_extension = input("Podaj rozszerzenie plików (np. .fx): ")
    old_text = input("Podaj tekst do zamiany w nazwie pliku: ")
    new_text = input("Podaj nowy tekst do nazwy pliku: ")
    
    rename_files_with_extension(file_extension, old_text, new_text)

if __name__ == "__main__":
    main()
