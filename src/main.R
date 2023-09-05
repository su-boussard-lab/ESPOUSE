source("src/cohortGenerator.R")

config <- yaml::yaml.load_file('./config/config.yml')

if (is.null(config) || "run" %in% names(config) == FALSE || 
    "cdm" %in% names(config) == FALSE){
  stop("Missing config parameters!")
}


if (tolower(config$run$type) == "multiple") {
  source("src/multiplePrediction.R")
  print("Multiple prediction module is running ...")
  res_time <- system.time(runMultiplePrediction())
  sprintf(
    "Multiple prediction was completed in %.3f mins",
    res_time[3] / 60
  )
} else if (tolower(config$run$type) == "ensemble") {
  source("src/multiplePrediction.R")
  source("src/ensembleLearning.R")
  print("Ensemble prediction module is running ...")
  res_time <- system.time(runEnsembleLearning())
  sprintf(
    "Ensemble prediction was completed in %.3f mins",
    res_time[3] / 60
  )
} else if (tolower(config$run$type) == "cohort") {
  print("cohort generator is running ...")
  generateCohorts()
} else {
  sprintf("Error: Missing run type in the config file! The run type must be given as cohort, multiple or ensemble.")
}
  
  