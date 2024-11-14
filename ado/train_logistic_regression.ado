*! version 1.0
program define train_logistic_regression
    // =========================================================================
    // train_logistic_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a logistic regression model using the specified target and predictor variables.
    //
    // Syntax:
    // train_logistic_regression, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ robust ]
    //
    // Options:
    //   target(varname)      - Binary target variable for the logistic regression model.
    //   predictors(varlist)  - Predictor variables for the logistic regression model.
    //   robust                - Use robust standard errors.
    //
    // Example:
    // train_logistic_regression, ///
    //     target(Purchase) ///
    //     predictors(Age Gender_income Income) ///
    //     robust
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ robust ]

    // -------------------------------------------------------------------------
    // 1. Train Logistic Regression Model
    // -------------------------------------------------------------------------
    display "Training Logistic Regression Model..."
    if "`robust'" != "" {
        logistic `target' `predictors', vce(robust)
    }
    else {
        logistic `target' `predictors'
    }

    // -------------------------------------------------------------------------
    // 2. Save Model Estimates
    // -------------------------------------------------------------------------
    local model_name "logistic_regression"
    estimates store `model_name'
    display "Logistic Regression Model trained and estimates stored as `model_name'."

end
