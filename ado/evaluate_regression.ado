*! version 2.3
program define evaluate_regression
    // =========================================================================
    // evaluate_regression.ado
    // =========================================================================
    //
    // Description:
    // Evaluates regression models by calculating evaluation metrics.
    //
    // Syntax:
    // evaluate_regression, ///
    //     target("Price") ///
    //     prediction("Price_pred_linear_regression") ///
    //     save_metrics("metrics/regression_metrics.csv")
    //
    // Options:
    //   target(string)         - The true target variable.
    //   prediction(string)     - The predicted values from the model.
    //   save_metrics(string)   - Filename to save the evaluation metrics.
    //
    // Example:
    // evaluate_regression, ///
    //     target("Price") ///
    //     prediction("Price_pred_linear_regression") ///
    //     save_metrics("metrics/regression_metrics.csv")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        save_metrics(string)
    
    // Check if variables exist
    confirm variable `target'
    confirm variable `prediction'
    
    if _rc {
        display as error "One or both specified variables do not exist."
        exit 198
    }
    
    // Preserve the current data
    preserve
    
    // Calculate residuals
    generate double residual = `target' - `prediction'
    
    // Calculate RMSE
    generate double residual_sq = residual^2
    quietly summarize residual_sq, meanonly
    local mse = r(mean)
    local rmse = sqrt(`mse')
    
    // Calculate MAE
    generate double abs_residual = abs(residual)
    quietly summarize abs_residual, meanonly
    local mae = r(mean)
    
    // Calculate MAPE
    generate double abs_percentage_error = (abs(residual) / abs(`target')) * 100
    quietly summarize abs_percentage_error, meanonly
    local mape = r(mean)
    
    // Calculate R-squared
    regress `target' `prediction'
    local rsquared = e(r2)
    
    // Restore original data
    restore
    
    // Initialize postfile
    tempfile metrics_temp
    postfile handle str25 metric double value using "`metrics_temp'"
    
    // Post metrics
    post handle ("RMSE") (`rmse')
    post handle ("R-squared") (`rsquared')
    post handle ("MAE") (`mae')
    post handle ("MAPE") (`mape')
    
    // Close postfile
    postclose handle
    
    // Load metrics and export
    use "`metrics_temp'", clear
    export delimited using "`save_metrics'", replace
    
    display "Regression metrics saved to `save_metrics'."
end
