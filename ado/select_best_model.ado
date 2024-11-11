*! version 1.0
program define select_best_model
    // =========================================================================
    // select_best_model.ado
    // =========================================================================
    //
    // Description:
    // Evaluates the performance metrics of multiple trained models and selects the
    // best-performing model based on user-specified criteria (e.g., highest R-squared
    // for regression, highest AUC for classification).
    //
    // Syntax:
    // select_best_model using "metrics.csv", ///
    //     task(regression|classification) ///
    //     metric("Metric_Name") ///
    //     maximize ///
    //     save_results("best_model.csv")
    //
    // Options:
    //   task(string)           - Type of task: "regression" or "classification"
    //   metric(string)         - The performance metric to prioritize (e.g., "R-squared", "AUC")
    //   maximize               - Specify if the metric should be maximized (default: maximize)
    //   minimize               - Specify if the metric should be minimized
    //   save_results(string)   - Save the best model's details to a CSV file
    //
    // Example:
    // . select_best_model using "model_metrics.csv", ///
    //       task(regression) ///
    //       metric("R-squared") ///
    //       maximize ///
    //       save_results("best_regression_model.csv")
    //
    // =========================================================================

    version 16.0
    syntax using/ , ///
        task(string) ///
        metric(string) ///
        [ maximize minimize ] ///
        [ save_results(string) ]

    // -------------------------------------------------------------------------
    // 1. Validate Inputs
    // -------------------------------------------------------------------------
    if "`task'" == "" {
        display as error "Error: Task type must be specified using the 'task()' option."
        exit 198
    }

    if "`metric'" == "" {
        display as error "Error: Performance metric must be specified using the 'metric()' option."
        exit 198
    }

    // Ensure that either maximize or minimize is specified; default is maximize
    local direction "maximize"
    if "`minimize'" != "" & "`maximize'" != "" {
        display as error "Error: Specify either 'maximize' or 'minimize', not both."
        exit 198
    }
    else if "`minimize'" != "" {
        local direction "minimize"
    }
    else if "`maximize'" != "" {
        local direction "maximize"
    }
    // else default is maximize

    // Check if the input file exists
    local filepath "`using'"

    if "`filepath'" == "" {
        display as error "Error: No input file specified."
        exit 198
    }

    if !fileexists("`filepath'") {
        display as error "Error: The file `filepath' does not exist."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 2. Import the Metrics File
    // -------------------------------------------------------------------------
    display "Importing metrics from `filepath'..."
    import delimited using "`filepath'", clear varnames(1) encoding(UTF8)

    // -------------------------------------------------------------------------
    // 3. Validate Task Type and Metric
    // -------------------------------------------------------------------------
    // Define expected metrics based on task type
    local regression_metrics "RMSE R-squared MAE MAPE"
    local classification_metrics "Accuracy Precision Recall F1-Score AUC"

    if "`task'" == "regression" {
        // Check if the specified metric is valid for regression
        tokenize `regression_metrics'
        local valid_metric 0
        foreach m of local regression_metrics {
            if "`m'" == "`metric'" {
                local valid_metric 1
                continue, break
            }
        }
        if `valid_metric' == 0 {
            display as error "Error: Specified metric '`metric'' is not valid for regression. Valid metrics are: `regression_metrics'"
            exit 198
        }
    }
    else if "`task'" == "classification" {
        // Check if the specified metric is valid for classification
        tokenize `classification_metrics'
        local valid_metric 0
        foreach m of local classification_metrics {
            if "`m'" == "`metric'" {
                local valid_metric 1
                continue, break
            }
        }
        if `valid_metric' == 0 {
            display as error "Error: Specified metric '`metric'' is not valid for classification. Valid metrics are: `classification_metrics'"
            exit 198
        }
    }
    else {
        display as error "Error: Task type must be either 'regression' or 'classification'."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 4. Validate Presence of Metric Column
    // -------------------------------------------------------------------------
    ds, has(`metric')
    if "`r(varlist)'" == "" {
        display as error "Error: The specified metric '`metric'' does not exist in the dataset."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 5. Select the Best Model Based on the Specified Metric and Direction
    // -------------------------------------------------------------------------
    display "Selecting the best model based on `metric' and `direction'..."

    // Depending on direction, sort and select the best
    if "`direction'" == "maximize" {
        sort `metric'
        gsort -`metric'
    }
    else if "`direction'" == "minimize" {
        sort `metric'
    }

    // The first observation is the best model
    local best_model = model[1]
    // Assuming the metrics file has a column named 'model' for model names
    // If not, prompt an error or allow specifying the model identifier column

    // Check if there is a 'model' column
    ds, has(model)
    if "`r(varlist)'" == "" {
        display as error "Error: The metrics dataset must contain a 'model' column identifying each model."
        exit 198
    }

    local best_model_name = model[1]

    // Extract all metrics for the best model
    preserve
    keep if model == "`best_model_name'"
    // Optionally, keep only relevant columns
    // list in this data

    // Display the best model and its metrics
    display as text "----------------------------------------"
    display as text "Best Model Selection:"
    display as text "----------------------------------------"
    display as result "Model: `best_model_name'"
    display as text "Performance Metrics:"
    list, clean noobs

    display as text "----------------------------------------"

    // -------------------------------------------------------------------------
    // 6. Save the Best Model's Details if Specified
    // -------------------------------------------------------------------------
    if "`save_results'" != "" {
        // Export the best model's details to a CSV file
        export delimited using "`save_results'", replace
        if _rc == 0 {
            display "Best model details saved to '`save_results''."
        }
        else {
            display as error "Error: Failed to save best model details to '`save_results''."
        }
    }

    restore

    // -------------------------------------------------------------------------
    // 7. End of Program
    // -------------------------------------------------------------------------
    display "Best model selection completed successfully."

end
