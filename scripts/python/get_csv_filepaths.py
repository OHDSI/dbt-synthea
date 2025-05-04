# get a list of all csv files in a directory and return a json object with the file names as keys and the file paths as values

import json
import sys
from pathlib import Path

# Create a resolved path from passed in directory argument.
directory: Path = Path(sys.argv[1]).resolve()

# Create a list of csv file paths.
csv_file_paths: list[Path] = [
    path for path in directory.iterdir() if path.suffix == ".csv"
]

# Create a dictionary of filename: path_string and print in JSON format.
csv_file_dict: dict[str, str] = {path.stem: str(path) for path in csv_file_paths}

# Print dictionary as JSON.
print(json.dumps(csv_file_dict))
