devtools::install_github("OHDSI/ETL-Synthea")
library(ETLSyntheaBuilder)

cd <- DatabaseConnector::createConnectionDetails(
  dbms     = "duckdb",
  server = "./data/synthea_omop_etl.duckdb"
)

cd <- DatabaseConnector::createConnectionDetails(
  dbms     = "postgresql", 
  server   = "localhost/ohdsi", 
  user     = "postgres", 
  password = "postgres", 
  port     = 5432
)

cdmSchema      <- "etl_synthea"
cdmVersion     <- "5.4"
syntheaVersion <- "3.0.0"
syntheaSchema  <- "etl_synthea"
vocabSchema   <- "dbt_synthea_dev"
syntheaFileLoc <- "./seeds/synthea"

ETLSyntheaBuilder::CreateSyntheaTables(connectionDetails = cd, syntheaSchema = syntheaSchema, syntheaVersion = syntheaVersion)
ETLSyntheaBuilder::LoadSyntheaTables(connectionDetails = cd, syntheaSchema = syntheaSchema, syntheaFileLoc = syntheaFileLoc)


ETLSyntheaBuilder::CreateCDMTables(connectionDetails = cd, cdmSchema = cdmSchema, cdmVersion = cdmVersion)
# connection <- DatabaseConnector::connect(cd)
# sql <- readLines("https://raw.githubusercontent.com/OHDSI/CommonDataModel/main/inst/ddl/5.4/duckdb/OMOPCDM_duckdb_5.4_ddl.sql")
# sql <- SqlRender::render(paste(sql, collapse = "\n"), cdmDatabaseSchema = "etl_synthea")
# sql <- gsub("concept_id BIGINT", "concept_id integer", gsub("_id integer", "_id BIGINT", sql))
# DatabaseConnector::executeSql(connection, sql)
# DatabaseConnector::disconnect(connection)

#ETLSyntheaBuilder::LoadVocabFromCsv(connectionDetails = cd, cdmSchema = cdmSchema, vocabFileLoc = vocabFileLoc)
ETLSyntheaBuilder::LoadVocabFromSchema(connectionDetails = cd, cdmSourceSchema = vocabSchema, cdmTargetSchema = cdmSchema)

ETLSyntheaBuilder::CreateMapAndRollupTables(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, cdmVersion = cdmVersion, syntheaVersion = syntheaVersion)

## Optional Step to create extra indices
ETLSyntheaBuilder::CreateExtraIndices(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, syntheaVersion = syntheaVersion)

ETLSyntheaBuilder::LoadEventTables(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, cdmVersion = cdmVersion, syntheaVersion = syntheaVersion)

# List of table names to compare
tables_to_compare <- c("person", "observation_period", "death",
                       "visit_occurrence", "visit_detail", "procedure_occurrence",
                       "drug_exposure", "device_exposure", "condition_occurrence",
                       "measurement", "observation", "provider",
                       "payer_plan_period", "cost", "drug_era", "condition_era")

conn <- DatabaseConnector::connect(cd)

# Function to get row count of a table in a specific schema
get_row_count <- function(conn, table_name, schema) {
  result <- DatabaseConnector::renderTranslateQuerySql(conn, "SELECT COUNT(*) FROM @schema.@table_name;", schema = schema, table_name = table_name)
  
  if (nrow(result) == 0) {
    warning(paste("No result returned for table", table_name, "in schema", schema))
    return(0)
  }
  
  return(as.integer(result[1,1]))
}

# Loop through tables and compare row counts
comparison_results <- data.frame(
  Table = tables_to_compare
)

comparison_results$Schema1_Count <- NA
comparison_results$Schema2_Count <- NA
comparison_results$Counts_Match <- NA

for (i in 1:nrow(comparison_results)) {
  table <- comparison_results$Table[i]
  count1 <- get_row_count(conn, table, "dbt_synthea_dev")
  count2 <- get_row_count(conn, table, "etl_synthea")
  comparison_results$Schema1_Count[i] <- count1
  comparison_results$Schema2_Count[i] <- count2
  comparison_results$Counts_Match[i] <- (count1 == count2)
}

# Print comparison results
print(comparison_results)

# Disconnect from databases
disconnect(conn)
