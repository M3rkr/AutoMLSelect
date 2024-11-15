*! version 2.3
program define train_linear_regression
    // =========================================================================
    // train_linear_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a Linear Regression model using the specified target and predictors.
    //
    // Syntax:
    // train_linear_regression, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     robust ///
    //     save(filename)
    //
    // Options:
    //   target(string)         - The target variable for regression.
    //   predictors(varlist)    - Predictor variables.
    //   robust                 - Use robust standard errors.
    //   save(string)           - Filename to save the trained model.
    //
    // Example:
    // train_linear_regression, ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    //     robust ///
    //     save("models/linear_regression_model.dta")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ robust ///
          save(string) ]
    
    // Train Linear Regression Model
    display "Training Linear Regression Model..."
    regress `target' `predictors', robust
    
    if _rc {
        display as error "Linear Regression training failed."
        exit 198
    }
    
    // Save the model
    if "`save'" != "" {
        estimates store lr_model
        save "`save'", replace
    }
    
    display "Linear Regression model trained and saved to `save'."
end
