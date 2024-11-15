*! version 2.3
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
        gen double residual = `target' - `prediction'
        gen double abs_residual = abs(residual)
        summarize residual, meanonly
        scalar mean_residual = r(mean)
        scalar var_residual = r(Var)
        scalar MAE = sum(abs_residual) / _N

        // Calculate RMSE
        scalar RMSE = sqrt(sum(residual^2) / _N)

        // Attempt to calculate R-squared if available
        capture {
            // For linear regression, R-squared is available after regress
            scalar R_squared = e(r2)
        }

        // Calculate MAPE
        capture {
            gen double abs_residual_pct = abs(residual) / abs(`target')
            replace abs_residual_pct = . if `target' == 0
            summarize abs_residual_pct, meanonly
            scalar MAPE = r(mean) * 100
        }
    }

    // Prepare to save metrics
    tempfile metrics_temp
    postfile handle str32 metric double value using `metrics_temp', replace
    post handle ("RMSE") (RMSE)
    post handle ("MAE") (MAE)

    // If R-squared exists and is not missing, include it
    if (c(rc) == 0 & !missing(R_squared)) {
        post handle ("R-squared") (R_squared)
    }

    // If MAPE is calculable and not missing, include it
    if (c(rc) == 0 & !missing(MAPE)) {
        post handle ("MAPE") (MAPE)
    }

    postclose handle

    // Save metrics to specified path
    use `metrics_temp', clear
    export delimited using "`save_metrics'", replace

    display "Regression metrics saved to `save_metrics'."
end
