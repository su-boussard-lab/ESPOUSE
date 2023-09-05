library(reticulate)
source_python("fs/feature_evaluation.py")

# Set the path to the runPlp.rds file obtained from running logistic regression with all covariates.
lrRdsPath <- "./PlpMultiOutput-LR/Analysis_1/plpResult/runPlp.rds"
lrRDS <- readRDS(lrRdsPath)

covariate_summary_csv <- './fs/allCovariateSummary.csv'
write.csv(lrRDS$covariateSummary, covariate_summary_csv)

# It selects all concept ids from all domains using the PNF metric, whose metric values are greater than 1.5.
run_feature_selection(covariate_summary_csv = covariate_summary_csv, metric_name='pnf', output_dir = './fs', fs_file_name = 'fs-pnf')
