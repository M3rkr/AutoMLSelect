*! version 2.3
program define select_best_model
    // =========================================================================
    // select_best_model.ado
    // =========================================================================
    //
    // Description:
    // Selects the best-performing model based on the specified metric.
    //
    // Syntax:
    // select_best_model, ///
    //     using(metrics_filename) ///
    //     task(regression|classification) ///
    //     metric(metric_name) ///
    //     direction(maximize|minimize) ///
    //     [ save_results(results_filename) ]
    //
    // Options:
    //   using(string)            - The metrics CSV file.
    //   task(regression|classification) - The type of task.
    //   metric(string)           - The metric to base selection on.
    //   direction(maximize|minimize) - Whether to maximize or minimize the metric.
    //   save_results(string)     - Filename to save the best model details (.csv).
    //
    // Example:
    // select_best_model, ///
    //     using("metrics/combined_metrics.csv") ///
    //     task(regression) ///
    //     metric("RMSE") ///
    //     direction(minimize) ///
    //     save_results("metrics/best_regression_model.csv")
    //
    // =========================================================================
    
    version 16.0
    syntax using(string) , ///
        task(string) ///
        metric(string) ///
        direction(string) ///
        [ save_results(string) ]

    // Load metrics
    import delimited using "`using'", clear

    // Validate task type
    if ("`task'" != "regression" & "`task'" != "classification") {
        display as error "select_best_model: Invalid task '`task''. Use 'regression' or 'classification'."
        exit 198
    }

    // Define valid metrics based on task
    if ("`task'" == "regression") {
        local valid_metrics "RMSE R-squared MAE MAPE"
    }
    else if ("`task'" == "classification") {
        local valid_metrics "Accuracy Precision Recall F1_Score AUC"
    }

    // Verify the specified metric is valid for the task
    local is_valid_metric = 0
    foreach m in `valid_metrics' {
        if ("`m'" == "`metric'") {
            local is_valid_metric = 1
            break
        }
    }

    if (`is_valid_metric' == 0) {
        display as error "select_best_model: Metric '`metric'' is not valid for task '`task''."
        exit 198
    }

    // Check if the metric exists in the data
    count if metric == "`metric'"
    if
