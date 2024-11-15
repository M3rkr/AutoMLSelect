*! version 2.3
program define automlselect
    // =========================================================================
    // automlselect.ado
    // =========================================================================
    //
    // Description:
    // Main entry point for the AutoMLSelect package. Facilitates training, evaluation,
    // and selection of the best model for regression and classification tasks.
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
    // =========================================================================
    
    version 16.0
    syntax [regression|classification], ///
        target(string) ///
        predictors(string) ///
        [ save_model(string) ///
          save_metrics(string) ]

    // Validate task specification
    if ("`regression'" != "" & "`classification'" != "") {
        display as error "automlselect: Specify either 'regression' or 'classification', not both."
        exit 198
    }

    if ("`regression'" == "" & "`classification'" == "") {
        display as error "automlselect: Specify the task type: 'regression' or 'classification'."
        exit 198
    }

    if ("`target'" == "") {
        display as error "automlselect: Specify the target variable using the 'target()' option."
        exit 198
    }

    if ("`predictors'" == "") {
        display as error "automlselect: Specify predictor variables using the 'predictors()' option."
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

    // Train the model
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

    // Evaluate the trained model
    display "Evaluating Trained Models..."
    if ("`task'" == "regression") {
        evaluate_regression, ///
            target("`target'") ///
            prediction("`save_model'") ///
            save_metrics("metrics/`save_metrics'")
    }
    else if ("`task'" == "classification") {
        evaluate_classification, ///
            target("`target'") ///
            prediction("`save_model'") ///
            save_metrics("metrics/`save_metrics'")
    }

    // Select the best model based on metrics
    display "Selecting Best Model based on Metrics..."
    if ("`task'" == "regression") {
        // Select model with the lowest RMSE
        select_best_model, ///
            using("metrics/`save_metrics'") ///
            task(regression) ///
            metric("RMSE") ///
            direction(minimize) ///
            save_results("metrics/best_regression_model.csv")
    }
    else if ("`task'" == "classification") {
        // Select model with the highest AUC
        select_best_model, ///
            using("metrics/`save_metrics'") ///
            task(classification) ///
            metric("AUC") ///
            direction(maximize) ///
            save_results("metrics/best_classification_model.csv")
    }

    display "AutoMLSelect process completed successfully."
end
