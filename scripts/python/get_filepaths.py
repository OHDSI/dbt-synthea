#!/usr/bin/env  -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///

# get a list of all csv or parquet files in a directory and return a json object with the file names as keys and the file paths as values

import json
import sys
from pathlib import Path

# Create a resolved path from passed in directory argument.
directory: Path = Path(sys.argv[1]).resolve()

# Create a list of csv file paths.
csv_file_paths: list[Path] = [
    path for path in directory.iterdir() if path.suffix == ".csv"
]
parquet_file_paths: list[Path] = [
    path for path in directory.iterdir() if path.suffix == ".parquet"
]

# Create a dictionary of filename: path_string and print in JSON format.
if csv_file_paths and parquet_file_paths:
    raise ValueError(
        "Both CSV and Parquet files found — only one format should be present to avoid ambiguity."
    )
elif csv_file_paths:
    file_dict: dict[str, str] = {path.stem: str(path) for path in csv_file_paths}
elif parquet_file_paths:
    file_dict = {path.stem: str(path) for path in parquet_file_paths}
else:
    raise FileNotFoundError(f"No csv or parquet files found in {directory}.")

# Print dictionary as JSON.
print(json.dumps(file_dict))
