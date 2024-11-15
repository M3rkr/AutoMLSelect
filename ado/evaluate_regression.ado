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
    //     target(target_variable) ///
    //     prediction(predicted_variable) ///
    //     save_metrics(filename)
    //
    // Options:
    //   target(string)         - The true target variable.
    //   prediction(string)     - The predicted values from the model.
    //   save_metrics(string)   - Filename to save the evaluation metrics.
    //
    // Example:
    // evaluate_regression, ///
    //     target(Price) ///
    //     prediction(Price_pred_linear_regression) ///
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
    
    // Calculate evaluation metrics
    display "Calculating Regression Metrics..."
    generate double residual = `target' - `prediction'
    
    // RMSE
    quietly summarize residual, meanonly
    generate double mse = mean(residual^2)
    generate double RMSE = sqrt(mse)
    
    // MAE
    generate double abs_residual = abs(residual)
    summarize abs_residual, meanonly
    generate double MAE = r(mean)
    
    // MAPE
    generate double abs_percentage_error = abs(residual / `target') * 100
    summarize abs_percentage_error, meanonly
    generate double MAPE = r(mean)
    
    // R-squared
    regress `target' `prediction'
    local R_squared = e(r2)
    
    // Create metrics dataset
    clear
    input str25 metric double value
    "RMSE" .
    "R-squared" .
    "MAE" .
    "MAPE" .
    end
    replace value = RMSE in 1
    replace value = `R_squared' in 2
    replace value = MAE in 3
    replace value = MAPE in 4
    
    // Save metrics
    export delimited using "`save_metrics'", replace
    display "Regression metrics saved to `save_metrics'."
end
