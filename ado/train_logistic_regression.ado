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
    //     robust ///
    //     save(filename)
    //
    // Options:
    //   target(string)         - The target variable for classification.
    //   predictors(varlist)    - Predictor variables.
    //   robust                 - Use robust standard errors.
    //   save(string)           - Filename to save the trained model.
    //
    // Example:
    // train_logistic_regression, ///
    //     target(Purchase) ///
    //     predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    //     robust ///
    //     save("models/logistic_regression_model.dta")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ robust ///
          save(string) ]
    
    // Train Logistic Regression Model
    display "Training Logistic Regression Model..."
    logistic `target' `predictors', robust
    
    if _rc {
        display as error "Logistic Regression training failed."
        exit 198
    }
    
    // Save the model
    if "`save'" != "" {
        estimates store lr_model
        save "`save'", replace
    }
    
    display "Logistic Regression model trained and saved to `save'."
end
