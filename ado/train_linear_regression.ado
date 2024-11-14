*! version 1.0
program define train_linear_regression
    // =========================================================================
    // train_linear_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a linear regression model using the specified target and predictor variables.
    //
    // Syntax:
    // train_linear_regression, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ robust ]
    //
    // Options:
    //   target(varname)      - Target variable for the regression model.
    //   predictors(varlist)  - Predictor variables for the regression model.
    //   robust                - Use robust standard errors.
    //
    // Example:
    // train_linear_regression, ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location_north Location_south) ///
    //     robust
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ robust ]

    // -------------------------------------------------------------------------
    // 1. Train Linear Regression Model
    // -------------------------------------------------------------------------
    display "Training Linear Regression Model..."
    if "`robust'" != "" {
        regress `target' `predictors', robust
    }
    else {
        regress `target' `predictors'
    }

    // -------------------------------------------------------------------------
    // 2. Save Model Estimates
    // -------------------------------------------------------------------------
    local model_name "linear_regression"
    estimates store `model_name'
    display "Linear Regression Model trained and estimates stored as `model_name'."

end
