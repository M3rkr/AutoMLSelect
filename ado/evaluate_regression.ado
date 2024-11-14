*! version 1.0
program define evaluate_regression
    // =========================================================================
    // evaluate_regression.ado
    // =========================================================================
    //
    // Description:
    // Evaluates a regression model by calculating performance metrics.
    //
    // Syntax:
    // evaluate_regression, ///
    //     target(target_variable) ///
    //     prediction(predicted_variable) ///
    //     [ metrics(metric_list) ///
    //       save_metrics(string) ]
    //
    // Options:
    //   target(varname)        - Actual target variable.
    //   prediction(varname)    - Predicted target variable.
    //   metrics(metric_list)   - List of metrics to calculate (RMSE, R-squared, MAE, MAPE).
    //   save_metrics(string)    - File path to save the calculated metrics as CSV.
    //
    // Example:
    // evaluate_regression, ///
    //     target(Price) ///
    //     prediction(Price_pred_linear_regression) ///
    //     metrics(R-squared RMSE MAE MAPE) ///
    //     save_metrics("linear_regression_metrics.csv")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        [ metrics(string) ///
          save_metrics(string) ]

    // -------------------------------------------------------------------------
    // 1. Calculate Metrics
    // -------------------------------------------------------------------------
    display "Calculating Regression Metrics..."
    qui su `prediction', meanonly
    local mean_pred = r(mean)

    qui su `target' `prediction', meanonly
    local mean_actual = r(mean)

    // Calculate RMSE
    generate double _error = `target' - `prediction'
    qui su _error^2, meanonly
    local rmse = sqrt(r(mean))

    // Calculate MAE
    generate double _abs_error = abs(`target' - `prediction')
    qui su _abs_error, meanonly
    local mae = r(mean)

    // Calculate R-squared
    qui reg `target' `prediction'
    local rsquared = e(r2)

    // Calculate MAPE
    qui su `target', meanonly
    generate double _ape = abs((_error) / r(mean)) * 100
    qui su _ape, meanonly
    local mape = r(mean)

    // Create a dataset of metrics
    clear
    input str15 metric double value
    "RMSE"        `rmse'
    "R-squared"   `rsquared'
    "MAE"         `mae'
    "MAPE"        `mape'
    end

    // -------------------------------------------------------------------------
    // 2. Display Metrics
    // -------------------------------------------------------------------------
    display as text "----------------------------------------"
    display as text "Regression Model Performance Metrics:"
    display as text "----------------------------------------"
    list, clean noobs
    display as text "----------------------------------------"

    // -------------------------------------------------------------------------
    // 3. Save Metrics to CSV
    // -------------------------------------------------------------------------
    if "`save_metrics'" != "" {
        export delimited using "`save_metrics'", replace
        if _rc == 0 {
            display "Regression metrics saved to '`save_metrics''."
        }
        else {
            display as error "Error: Failed to save regression metrics to '`save_metrics''."
        }
    }

    // -------------------------------------------------------------------------
    // 4. Cleanup
    // -------------------------------------------------------------------------
    drop _error _abs_error

end
