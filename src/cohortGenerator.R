library(DatabaseConnector)
library(SqlRender)

source("src/databaseConnection.R")

createCohortQueries <- function() {
  sql <- list()
  sql["target"] <- readSql("./sql/target-cohort.sql")
  sql["outcome"] <- readSql("./sql/outcome-cohort.sql")
  
  
  cohortQueries <- list()
  for (q in names(sql)) {
    cohort_id <- config$cdm$target_cohort_id
    if (q == "outcome"){
      cohort_id <- config$cdm$outcome_cohort_id
    }
    
    print(paste(q, "cohort_id is", cohort_id))
    
    cohortQueries[q] = render(
      sql[[q]],
      vocabulary_database_schema = config$cdm$vocabulary_database_schema,
      cdm_database_schema = config$cdm$cdm_database_schema,
      target_database_schema = config$cdm$target_database_schema,
      target_cohort_table = config$cdm$cohort_table,
      target_cohort_id = cohort_id
    )
  }
  
  return(cohortQueries)
}

createTestCohortQuery <- function() {
  sql <- paste(
    "SELECT cohort_definition_id, COUNT(*) AS count",
    "FROM @target_database_schema.@target_cohort_table",
    "GROUP BY cohort_definition_id"
  )
  sql <- render(
    sql,
    target_database_schema = config$cdm$target_database_schema,
    target_cohort_table = config$cdm$cohort_table
  )
  
  return(sql)
}

createCohortTableQuery <- function() {
  sql <- readSql("./sql/cohort-table.sql")
  cohortQuery = render(
    sql,
    target_database_schema = config$cdm$target_database_schema,
    target_cohort_table = config$cdm$cohort_table
  )
  return(cohortQuery)
}

generateCohorts <- function() {
  print("Database connection ...")
  connectionDetails = getConnectionDetails()
  connection <- connect(connectionDetails)
  
  print("Checking cohort table in the target schema ...")
  sql <-
    translate(createCohortTableQuery(), targetDialect = connectionDetails$dbms)
  DatabaseConnector::executeSql(connection, sql)
  
  print("Cohort queries are generating ...")
  
  queries = createCohortQueries()
  
  for (cohortName in names(queries)) {
    print(cohortName)
    print(paste(cohortName, "cohort query is translating ..."))
    sql <-
      translate(queries[[cohortName]], targetDialect = connectionDetails$dbms)
    
    print(paste(cohortName, "cohort is running ..."))
    res_time <- system.time(DatabaseConnector::executeSql(connection, sql))
    sprintf(
     "%s cohort was generated in %.3f minutes.",
     cohortName,
     res_time[3] / 60
    )
  }
  
  print("Target and outcome cohorts were generated. The results are as follows:")
  testQuery <- createTestCohortQuery()
  testSql <-
    translate(testQuery, targetDialect = connectionDetails$dbms)
  testResult <- DatabaseConnector::querySql(connection, testSql)
  print(testResult)
  disconnect(connection = connection)
}



