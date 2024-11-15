*! version 2.4
program define evaluate_regression
    // =========================================================================
    // evaluate_regression.ado
    // =========================================================================
    //
    // Description:
    // Evaluates regression model predictions by calculating performance metrics.
    //
    // Syntax:
    // evaluate_regression, ///
    //     target(target_variable) ///
    //     prediction(prediction_variable) ///
    //     save_metrics(metrics_filename)
    //
    // Options:
    //   target(string)         - The true target variable.
    //   prediction(string)     - The predicted values from the model.
    //   save_metrics(string)   - Path to save the evaluation metrics (.csv).
    //
    // Example:
    // evaluate_regression, ///
    //     target(Price) ///
    //     prediction(Price_pred) ///
    //     save_metrics("metrics/regression_metrics.csv")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        save_metrics(string)

    // Validate options
    if ("`target'" == "" | "`prediction'" == "") {
        display as error "evaluate_regression: Both 'target' and 'prediction' must be specified."
        exit 198
    }
    
    if ("`save_metrics'" == "") {
        display as error "evaluate_regression: 'save_metrics' must be specified."
        exit 198
    }

    // Confirm variables exist
    confirm variable `target'
    confirm variable `prediction'

    // Calculate Metrics
    quietly {
        // Residuals and absolute residuals
        gen double residual = `target' - `prediction'
        gen double abs_residual = abs(residual)
        
        // Mean Absolute Error (MAE)
        summarize abs_residual, meanonly
        scalar MAE = r(mean)

        // Root Mean Squared Error (RMSE)
        summarize residual^2, meanonly
        scalar RMSE = sqrt(r(mean))

        // R-squared (if possible)
        scalar R_squared = .
        capture {
            regress `target' `prediction'
            scalar R_squared = e(r2)
        }

        // Mean Absolute Percentage Error (MAPE)
        gen double abs_residual_pct = abs(residual) / abs(`target')
        replace abs_residual_pct = . if `target' == 0  // Handle divide-by-zero cases
        summarize abs_residual_pct, meanonly
        scalar MAPE = r(mean) * 100
    }

    // Prepare to save metrics
    tempfile metrics_temp
    postfile handle str32 metric double value using `metrics_temp', replace
    post handle ("RMSE") (RMSE)
    post handle ("MAE") (MAE)

    // Include R-squared if calculable
    if (!missing(R_squared)) {
        post handle ("R-squared") (R_squared)
    }

    // Include MAPE if calculable
    if (!missing(MAPE)) {
        post handle ("MAPE") (MAPE)
    }

    postclose handle

    // Save metrics to the specified path
    use `metrics_temp', clear
    export delimited using "`save_metrics'", replace

    display "Regression metrics saved to `save_metrics'."
end
