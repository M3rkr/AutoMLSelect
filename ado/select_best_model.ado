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
    //     using(filename) ///
    //     task(regression|classification) ///
    //     metric(metric_name) ///
    //     direction(maximize|minimize) ///
    //     save_results(filename)
    //
    // Options:
    //   using(string)            - The metrics CSV file.
    //   task(regression|classification) - The type of task.
    //   metric(string)           - The metric to base selection on.
    //   direction(maximize|minimize) - Whether to maximize or minimize the metric.
    //   save_results(string)     - Filename to save the best model details.
    //
    // Example:
    // select_best_model, ///
    //     using("metrics/combined_regression_metrics.csv") ///
    //     task(regression) ///
    //     metric(RMSE) ///
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
    
    // Check if metric exists
    count if metric == "`metric'"
    if r(N) == 0 {
        display as error "Metric '`metric'' not found in the metrics file."
        exit 198
    }
    
    // Select best model based on metric and direction
    if "`direction'" == "maximize" {
        quietly sort - value
    }
    else if "`direction'" == "minimize" {
        quietly sort value
    }
    else {
        display as error "Invalid direction '`direction''. Use 'maximize' or 'minimize'."
        exit 198
    }
    
    // Get the top model
    local best_model = model[1]
    local best_value = value[1]
    
    // Save the best model details
    if "`save_results'" != "" {
        clear
        input str25 model double value
        "`best_model'" `best_value'
        end
        export delimited using "`save_results'", replace
    }
    
    display "Best model based on `metric' (`direction'): `best_model' with value `best_value'."
end
