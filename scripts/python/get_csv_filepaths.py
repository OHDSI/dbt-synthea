# get a list of all csv files in a directory and return a json object with the file names as keys and the file paths as values

import os
import json
import sys

directory = sys.argv[1]

files = os.listdir(directory)
csv_files = [file for file in files if file.endswith('.csv')]
file_names = [os.path.splitext(file)[0] for file in csv_files]

file_dict = {}
for file in csv_files:
    file_path = os.path.join(directory, file)
    file_name = os.path.splitext(file)[0]
    file_dict[file_name] = file_path

print(json.dumps(file_dict))