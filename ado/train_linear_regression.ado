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
    //     [ robust ] ///
    //     save(filename)
    //
    // Options:
    //   target(string)         - The target variable for regression.
    //   predictors(varlist)    - Predictor variables.
    //   robust                 - Use robust standard errors.
    //   save(string)           - Filename to save the trained model estimates (.ster).
    //
    // Example:
    // train_linear_regression, ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    //     robust ///
    //     save("linear_regression_model.ster")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ robust ///
          save(string) ]
    
    // Check if target and predictors are specified
    if ("`target'" == "" | "`predictors'" == "") {
        display as error "train_linear_regression: Both 'target' and 'predictors' must be specified."
        exit 198
    }
    
    // Train Linear Regression Model
    if ("`robust'" != "") {
        regress `target' `predictors', robust
    }
    else {
        regress `target' `predictors'
    }
    
    if (_rc != 0) {
        display as error "train_linear_regression: Linear Regression training failed."
        exit 198
    }
    
    // Save the model estimates
    if ("`save'" != "") {
        estimates store lr_model
        estimates save "`save'", replace
        if (_rc != 0) {
            display as error "train_linear_regression: Failed to save model estimates."
            exit 198
        }
        display "Linear Regression model trained and saved to `save'."
    }
    else {
        display as warning "train_linear_regression: No save path provided. Model estimates not saved."
    }
end
