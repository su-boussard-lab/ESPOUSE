<img src="docs/boussardlab.png" style="margin-right: 20px; margin-top: 10px;" />

----------------------------

# ESPOUSE: EnSemble learning for Prolonged Opioid USE

-----------------------------
This project proposes an ensemble model for predicting patients at risk of postoperative prolonged opioid. The model incorporates two machine learning models that are trained using different covariates, resulting in high precision and recall.

## Objectives
- Develop a machine learning model for identifying patients at risk of postoperative prolonged opioid use.
- Investigate three ensemble models using machine learning models trained on two different feature sets.
- Highlight the potential of ensemble learning to improve machine learning performance by allowing a trade-off between model precision and recall.

## Publication
Naderalvojoud, B., Hernandez-Boussard, T. **Improving machine learning with ensemble learning on observational healthcare data.** *AMIA 2023 Annual Symposium Proceedings. American Medical Informatics Association.*

## Development
ESPOUSE was developed in R Studio using the OHDSI PatientLevelPrediction and EnsemblePatientLevelPrediction R packages.

## Usage

### Requirements
- R version 4.1.3
- RStudio 2022.02.0
- Python 3.8
- JAVA JDK >= 8 

### Installation

```sh
install.packages("SqlRender")
install.packages("DatabaseConnector")
install.packages("remotes")
remotes::install_github("ohdsi/FeatureExtraction")
remotes::install_github("ohdsi/PatientLevelPrediction")
remotes::install_github("ohdsi/EnsemblePatientLevelPrediction")
```

If the CDM dataset is in BigQuery, the following package must be installed: 
```
remotes::install_github("jdposada/BQJdbcConnectionStringR")
```

### How to run
To run the project, first run the cohort generation module to generate target and outcome cohorts, then run the ensemble learning module to create ensemble models and evaluation results.

#### Run cohort generation
- Set up the config/config.yml file as follows:
    ```
    run:
      type: "ensemble"
    ```
- If the data warehouse is BigQuery, set the `bq`  parameters as follows: Otherwise, remove it and set the `db` parameters. As database connection methods may be different based on institutions' policies, the `getDbConnectionDetails()` function in ./src/databaseConnection.R  can be manually modified to set the parameters.
    ```
    bq:
      credentials: "path to gcloud/application_default_credentials.json"
      driverPath: "path to JDBCDriverforGoogleBigQuery"
      projectId: "BQ project id"
      defaultDataset: "dataset name"
    ```
    ```
    db:
      dbms: "postgresql" or "sql server"
      server: "server url"
      port: 5742
      user: "username"
      password: "password"
      driverPath: "path to db driver"
    ```
- Set the CDM dataset parameters as follows:
    ```
    cdm:
      target_database_schema: "target database schema (working schema where the cohort table will be generated)"
      cohort_table: "cohort"
      target_cohort_id: 1
      outcome_cohort_id: 2
      vocabulary_database_schema: "CDM database schema"
      cdm_database_schema: "CDM database schema"
      cdm_database_name: "CDM database name e.g., STARR-OMOP"
    ```

- After saving the configuration, run the project main module as follows:
    ```
    Rscript ./src/main.R
    ```

#### Run ensemble learning
- Change the configuration as follows:
    ```
    run:
      type: "ensemble""
      models:
      - LR
      - LRFS
    ```
    You can include a larger number of models, such as RF, RFFS, GB, GBFS, AB, ABFS, NB, and NBFS. The first two letters refer to the model name, and FS refers to feature selection. 

- After saving the configuration, run the project main module as follows:
    ```
    Rscript ./src/main.R
    ```
The current FS models will use the features already selected based on the STARR-OMOP dataset. To run FS models based on a new CDM dataset, run the feature selection module as described in the next section.

#### Run feature selection
- Set the config file to run a logistic regression (LR) model with all covariates: 
    ``` 
    run:
      type: "multiple""
      models:
      - LR
    ```
- Train the LR model by running the main module:
    ```
    Rscript ./src/main.R
    ```

- Run the feature selection module:
    ```
    Rscript ./src/featureSelection.R
    ```
    
## License
MIT License. 
Copyright (c) 2023 Boussard Lab


