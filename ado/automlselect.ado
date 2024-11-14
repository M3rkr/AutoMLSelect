*! version 1.0
program define automlselect
    // =========================================================================
    // automlselect.ado
    // =========================================================================
    //
    // Description:
    // Automates the machine learning workflow, including data preprocessing,
    // model training, performance evaluation, and model selection for regression
    // and classification tasks.
    //
    // Syntax:
    // automlselect using "data.csv", ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ task(regression|classification) ///
    //       preprocess_options(...) ///
    //       train_options(...) ///
    //       evaluate_options(...) ///
    //       select_options(...) ///
    //       save_results(string) ]
    //
    // Options:
    //   using("data.csv")         - Path to the input CSV file.
    //   target(varname)          - Target variable for modeling.
    //   predictors(varlist)      - List of predictor variables.
    //   task(regression|classification) - Type of machine learning task.
    //   preprocess_options(...)  - Additional options for data preprocessing.
    //   train_options(...)       - Options for model training.
    //   evaluate_options(...)    - Options for performance evaluation.
    //   select_options(...)      - Options for model selection.
    //   save_results(string)      - File path to save the best model details.
    //
    // Example:
    // automlselect using "data.csv", ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location) ///
    //     task(regression) ///
    //     preprocess_options(handle_missing(mean mode) encode_onehot) ///
    //     train_options(models(linear_regression random_forest)) ///
    //     evaluate_options(metrics(R-squared RMSE)) ///
    //     select_options(metric("R-squared") maximize) ///
    //     save_results("best_model.csv")
    //
    // =========================================================================

    version 16.0
    syntax using/ , ///
        target(string) ///
        predictors(string) ///
        [ task(string) ///
          preprocess_options(string) ///
          train_options(string) ///
          evaluate_options(string) ///
          select_options(string) ///
          save_results(string) ]

    // Default task is regression if not specified
    if "`task'" == "" {
        local task "regression"
    }

    // -------------------------------------------------------------------------
    // 1. Data Preprocessing
    // -------------------------------------------------------------------------
    display "Starting Data Preprocessing..."
    preprocess_data using "`using'", ///
        target(`"`target'"') ///
        predictors(`"`predictors'"') ///
        `preprocess_options'

    // -------------------------------------------------------------------------
    // 2. Model Training
    // -------------------------------------------------------------------------
    display "Starting Model Training..."
    // Parse train_options to identify models to train
    tokenize "`train_options'"
    local models_list
    while "`1'" != "" {
        local models_list `models_list' `1'
        macro shift
    }

    foreach model of local models_list {
        if "`model'" == "linear_regression" {
            train_linear_regression, ///
                target(`"`target'"') ///
                predictors(`"`predictors'"') ///
                `train_options'
        }
        else if "`model'" == "logistic_regression" {
            train_logistic_regression, ///
                target(`"`target'"') ///
                predictors(`"`predictors'"') ///
                `train_options'
        }
        else if "`model'" == "random_forest" {
            train_random_forest, ///
                target(`"`target'"') ///
                predictors(`"`predictors'"') ///
                `train_options'
        }
        else {
            display as error "Unknown model type: `model'"
            exit 198
        }
    }

    // -------------------------------------------------------------------------
    // 3. Performance Evaluation
    // -------------------------------------------------------------------------
    display "Starting Performance Evaluation..."
    foreach model of local models_list {
        if "`model'" == "linear_regression" {
            evaluate_regression, ///
                target(`"`target'"') ///
                prediction(Price_pred_linear_regression) ///
                `evaluate_options'
        }
        else if "`model'" == "logistic_regression" {
            evaluate_classification, ///
                target(`"`target'"') ///
                prediction(Purchase_pred_logistic_regression) ///
                probability(Purchase_prob_logistic_regression) ///
                `evaluate_options'
        }
        else if "`model'" == "random_forest" {
            if "`task'" == "regression" {
                evaluate_regression, ///
                    target(`"`target'"') ///
                    prediction(Random_Forest_pred_regression) ///
                    `evaluate_options'
            }
            else if "`task'" == "classification" {
                evaluate_classification, ///
                    target(`"`target'"') ///
                    prediction(Random_Forest_pred_classification) ///
                    probability(Random_Forest_prob_classification) ///
                    `evaluate_options'
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. Model Selection
    // -------------------------------------------------------------------------
    display "Starting Model Selection..."
    if "`task'" == "regression" {
        select_best_model using "combined_regression_metrics.csv", ///
            task(regression) ///
            `select_options' ///
            save_results("`save_results'")
    }
    else if "`task'" == "classification" {
        select_best_model using "combined_classification_metrics.csv", ///
            task(classification) ///
            `select_options' ///
            save_results("`save_results'")
    }

    // -------------------------------------------------------------------------
    // 5. Completion Message
    // -------------------------------------------------------------------------
    display "AutoMLSelect Workflow Completed Successfully."

end
