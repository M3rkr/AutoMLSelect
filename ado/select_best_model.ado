*! version 1.0
program define select_best_model
    // =========================================================================
    // select_best_model.ado
    // =========================================================================
    //
    // Description:
    // Selects the best-performing model from a set of models based on a specified
    // performance metric and direction (maximize or minimize).
    //
    // Syntax:
    // select_best_model using "metrics.csv", ///
    //     task(regression|classification) ///
    //     metric(metric_name) ///
    //     direction(maximize|minimize) ///
    //     [ save_results(string) ]
    //
    // Options:
    //   using("metrics.csv")      - Path to the CSV file containing model metrics.
    //   task(regression|classification) - Type of machine learning task.
    //   metric(metric_name)      - Performance metric to base selection on.
    //   direction(maximize|minimize) - Whether to maximize or minimize the metric.
    //   save_results(string)      - (Optional) File path to save the best model's details as CSV.
    //
    // Example:
    // select_best_model using "combined_regression_metrics.csv", ///
    //     task(regression) ///
    //     metric("R-squared") ///
    //     direction(maximize) ///
    //     save_results("best_regression_model.csv")
    //
    // =========================================================================

    version 16.0
    syntax using/ , ///
        task(string) ///
        metric(string) ///
        direction(string) ///
        [ save_results(string) ]

    // -------------------------------------------------------------------------
    // 1. Validate Task Type
    // -------------------------------------------------------------------------
    if "`task'" != "regression" & "`task'" != "classification" {
        display as error "Error: Task type must be either 'regression' or 'classification'."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 2. Validate Direction
    // -------------------------------------------------------------------------
    if "`direction'" != "maximize" & "`direction'" != "minimize" {
        display as error "Error: Direction must be either 'maximize' or 'minimize'."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 3. Load Metrics Data
    // -------------------------------------------------------------------------
    display "Importing metrics from `using'..."
    import delimited using "`using'", clear

    // -------------------------------------------------------------------------
    // 4. Validate Presence of Metric Column
    // -------------------------------------------------------------------------
    ds, has(`"`metric'"')
    if "`r(varlist)'" == "" {
        display as error "Error: The specified metric '`metric'' does not exist in the dataset."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 5. Validate Presence of Model Column
    // -------------------------------------------------------------------------
    ds, has(model)
    if "`r(varlist)'" == "" {
        display as error "Error: The metrics dataset must contain a 'model' column identifying each model."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 6. Select the Best Model Based on the Specified Metric and Direction
    // -------------------------------------------------------------------------
    display "Selecting the best model based on `metric' and `direction'..."

    // Depending on direction, sort and select the best
    if "`direction'" == "maximize" {
        sort `"`metric'"'
        gsort -`"`metric'"'
    }
    else if "`direction'" == "minimize" {
        sort `"`metric'"'
    }

    // The first observation is the best model
    local best_model = model[1]
    local best_metric = `"`metric'"'[1]

    // Display the best model and its metric
    display as text "----------------------------------------"
    display as text "Best Model Selection:"
    display as text "----------------------------------------"
    display as result "Model: `best_model'"
    display as text "`metric': `best_metric'"
    display as text "----------------------------------------"

    // -------------------------------------------------------------------------
    // 7. Save the Best Model's Details if Specified
    // -------------------------------------------------------------------------
    if "`save_results'" != "" {
        keep if model == "`best_model'"
        export delimited using "`save_results'", replace
        if _rc == 0 {
            display "Best model details saved to '`save_results''."
        }
        else {
            display as error "Error: Failed to save best model details to '`save_results''."
        }
    }

end
