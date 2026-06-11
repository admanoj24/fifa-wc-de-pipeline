import os

BASE_DIR = os.getenv("PROJECT_DIR", os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def read_sql_file(file_path):
    full_path = os.path.join(BASE_DIR, file_path)
    with open(full_path, "r") as file:
        return file.read()