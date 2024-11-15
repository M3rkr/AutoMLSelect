*! version 2.3
program define automlselect
    // =========================================================================
    // automlselect.ado
    // =========================================================================
    //
    // Description:
    // Main entry point for the AutoMLSelect package. Facilitates training and evaluation
    // of Linear and Logistic Regression models for regression and classification tasks.
    //
    // Syntax:
    // automlselect [regression|classification], ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ save_model(string) ///
    //       save_metrics(string) ]
    //
    // Options:
    //   regression|classification - Specifies the type of task.
    //   target(string)             - The target variable.
    //   predictors(varlist)        - Predictor variables.
    //   save_model(string)         - Filename to save the trained model estimates (.ster).
    //   save_metrics(string)       - Filename to save the evaluation metrics (.csv).
    //
    // Example:
    // automlselect regression, ///
    //     target(Price) ///
    //     predictors("Size Bedrooms Age Location_east Location_north Location_south Location_west") ///
    //     save_model("linear_regression_model.ster") ///
    //     save_metrics("regression_metrics.csv")
    //
    // automlselect classification, ///
    //     target(Purchase) ///
    //     predictors("Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west") ///
    //     save_model("logistic_regression_model.ster") ///
    //     save_metrics("classification_metrics.csv")
    //
    // =========================================================================
    
    version 16.0
    syntax [regression|classification], ///
        target(string) ///
        predictors(string) ///
        [ save_model(string) ///
          save_metrics(string) ]

    // Validate task specification
    if ("`regression'" != "" & "`classification'" != "") {
        display as error "automlselect: Please specify either 'regression' or 'classification', not both."
        exit 198
    }

    if ("`regression'" == "" & "`classification'" == "") {
        display as error "automlselect: Please specify the task type: 'regression' or 'classification'."
        exit 198
    }

    if ("`target'" == "") {
        display as error "automlselect: Please specify the target variable using the 'target()' option."
        exit 198
    }

    if ("`predictors'" == "") {
        display as error "automlselect: Please specify predictor variables using the 'predictors()' option."
        exit 198
    }

    // Determine task type
    if ("`regression'" != "") {
        local task = "regression"
    }
    else {
        local task = "classification"
    }

    // Determine save paths
    if ("`save_model'" == "") {
        local save_model = "`task'_model.ster"
    }

    if ("`save_metrics'" == "") {
        local save_metrics = "`task'_metrics.csv"
    }

    // Train Linear or Logistic Regression
    if ("`task'" == "regression") {
        display "Training Linear Regression Model..."
        train_linear_regression, ///
            target("`target'") ///
            predictors("`predictors'") ///
            robust ///
            save("models/`save_model'")
    }
    else if ("`task'" == "classification") {
        display "Training Logistic Regression Model..."
        train_logistic_regression, ///
            target("`target'") ///
            predictors("`predictors'") ///
            robust ///
            save("models/`save_model'")
    }

    // Evaluate Models
    display "Evaluating Trained Models..."
    evaluate_models, ///
        target("`target'") ///
        save_metrics("metrics/`save_metrics'")

    // Select Best Model based on Metrics
    display "Selecting Best Model based on Metrics..."
    if ("`task'" == "regression") {
        // Example: Select model with lowest RMSE
        select_best_model, ///
            using("metrics/`save_metrics'") ///
            task(regression) ///
            metric("RMSE") ///
            direction(minimize) ///
            save_results("metrics/best_regression_model.csv")
    }
    else if ("`task'" == "classification") {
        // Example: Select model with highest AUC
        select_best_model, ///
            using("metrics/`save_metrics'") ///
            task(classification) ///
            metric("AUC") ///
            direction(maximize) ///
            save_results("metrics/best_classification_model.csv")
    }

    display "AutoMLSelect process completed successfully."
end
