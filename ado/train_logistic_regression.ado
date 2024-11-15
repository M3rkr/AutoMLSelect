*! version 2.3
program define train_logistic_regression
    // =========================================================================
    // train_logistic_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a Logistic Regression model using the specified target and predictors.
    //
    // Syntax:
    // train_logistic_regression, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ robust ] ///
    //     save(filename)
    //
    // Options:
    //   target(string)         - The target variable for classification.
    //   predictors(varlist)    - Predictor variables.
    //   robust                 - Use robust standard errors.
    //   save(string)           - Filename to save the trained model estimates (.ster).
    //
    // Example:
    // train_logistic_regression, ///
    //     target(Purchase) ///
    //     predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    //     robust ///
    //     save("logistic_regression_model.ster")
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
        display as error "train_logistic_regression: Both 'target' and 'predictors' must be specified."
        exit 198
    }
    
    // Train Logistic Regression Model
    if ("`robust'" != "") {
        logistic `target' `predictors', robust
    }
    else {
        logistic `target' `predictors'
    }
    
    if (_rc != 0) {
        display as error "train_logistic_regression: Logistic Regression training failed."
        exit 198
    }
    
    // Save the model estimates
    if ("`save'" != "") {
        estimates store lr_model
        estimates save "`save'", replace
        if (_rc != 0) {
            display as error "train_logistic_regression: Failed to save model estimates."
            exit 198
        }
        display "Logistic Regression model trained and saved to `save'."
    }
    else {
        display as warning "train_logistic_regression: No save path provided. Model estimates not saved."
    }
end
