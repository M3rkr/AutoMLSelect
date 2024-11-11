*! version 1.0
program define evaluate_regression
    // =========================================================================
    // evaluate_regression.ado
    // =========================================================================
    //
    // Description:
    // Evaluates the performance of a regression model by calculating RMSE, R-squared,
    // MAE, and MAPE.
    //
    // Syntax:
    // evaluate_regression target(varname) prediction(varname) [options]
    //
    // Options:
    //   save_metrics(filename) - Save the calculated metrics to a CSV file
    //
    // Example:
    // . evaluate_regression target(Income) prediction(Income_pred) save_metrics(reg_metrics.csv)
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        [ save_metrics(string) ]

    // -------------------------------------------------------------------------
    // 1. Validate Inputs
    // -------------------------------------------------------------------------
    if "`target'" == "" {
        display as error "Error: Target variable is not specified."
        exit 198
    }

    if "`prediction'" == "" {
        display as error "Error: Prediction variable is not specified."
        exit 198
    }

    // Check if target variable exists and is numeric
    cap confirm variable `target'
    if _rc != 0 {
        display as error "Error: Target variable `target' does not exist in the dataset."
        exit 198
    }

    qui describe `target'
    if r(type) != "float" & r(type) != "double" & r(type) != "long" & r(type) != "int" & r(type) != "byte" {
        display as error "Error: Target variable `target' must be numeric for regression evaluation."
        exit 198
    }

    // Check if prediction variable exists and is numeric
    cap confirm variable `prediction'
    if _rc != 0 {
        display as error "Error: Prediction variable `prediction' does not exist in the dataset."
        exit 198
    }

    qui describe `prediction'
    if r(type) != "float" & r(type) != "double" & r(type) != "long" & r(type) != "int" & r(type) != "byte" {
        display as error "Error: Prediction variable `prediction' must be numeric for regression evaluation."
        exit 198
    }

    // Check for missing values in target or prediction
    qui count if missing(`target') | missing(`prediction')
    if r(N) > 0 {
        display as error "Error: There are missing values in the target or prediction variables. Please handle them before evaluation."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 2. Calculate Performance Metrics
    // -------------------------------------------------------------------------
    display "Calculating regression performance metrics..."

    // Calculate Residuals
    generate double residual = `target' - `prediction'

    // Calculate RMSE
    summarize residual, meanonly
    local rmse = sqrt(r(mean)^2 + r(sd)^2) // Alternatively, sqrt(r(mean^2 + r(sd)^2))
    // A more accurate RMSE calculation:
    qui su residual^2, meanonly
    local rmse = sqrt(r(mean))

    // Calculate MAE
    generate double abs_residual = abs(residual)
    summarize abs_residual, meanonly
    local mae = r(mean)
    drop abs_residual

    // Calculate MAPE
    generate double ape = abs_residual / abs(`target')
    summarize ape, meanonly
    local mape = r(mean) * 100
    drop ape

    // Calculate R-squared
    qui regress `target' `prediction'
    local rsq = e(r2)

    // Clean up residual variable
    drop residual

    // -------------------------------------------------------------------------
    // 3. Display Metrics
    // -------------------------------------------------------------------------
    display as text "----------------------------------------"
    display as text "Regression Performance Metrics:"
    display as text "----------------------------------------"
    display as result "RMSE: " %9.4f `rmse'
    display as result "R-squared: " %9.4f `rsq'
    display as result "MAE: " %9.4f `mae'
    display as result "MAPE: " %9.4f `mape' "%"
    display as text "----------------------------------------"

    // -------------------------------------------------------------------------
    // 4. Save Metrics to CSV if Specified
    // -------------------------------------------------------------------------
    if "`save_metrics'" != "" {
        // Create a temporary dataset to store metrics
        tempname metrics
        qui {
            postfile `metrics' str20 metric_name double metric_value using temp_metrics.dta, replace
            post `metrics' "RMSE" (`rmse')
            post `metrics' "R-squared" (`rsq')
            post `metrics' "MAE" (`mae')
            post `metrics' "MAPE" (`mape')
            postclose `metrics'
        }

        // Export the metrics to CSV
        qui {
            use temp_metrics.dta, clear
            export delimited using "`save_metrics'", replace
            drop _all
        }

        display "Performance metrics saved to '`save_metrics''."
    }

    // -------------------------------------------------------------------------
    // 5. End of Program
    // -------------------------------------------------------------------------
    display "Regression evaluation completed successfully."

end
