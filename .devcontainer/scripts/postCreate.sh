# Set up git
git config --global --add safe.directory /workspaces/dbt-synthea
git config --global init.defaultBranch main

# Install requirements
cd /workspaces/dbt-synthea
pip install -r .devcontainer/scripts/minimal_requirements.txt

# Setup pre-commit
pre-commit install

# Setup bash history search
cat >> ~/.inputrc <<'EOF'
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF



# Setup dbt profile
mkdir /home/vscode/.dbt
cat >> /home/vscode/.dbt/profiles.yml <<'EOF'
synthea_omop_etl:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ./data/synthea_omop_etl.duckdb
      schema: dbt_synthea_dev
EOF

# Setup dbt

echo "Setting up duckdb synthetic data and dbt"
mkdir ./data

dbt deps
dbt seed
