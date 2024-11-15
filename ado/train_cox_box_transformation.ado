*! version 1.0
program define train_cox_box_regression
    // =========================================================================
    // train_cox_box_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a regression model using a Box-Cox transformation on the target variable.
    //
    // Syntax:
    // train_cox_box_regression, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     lambda(value) ///
    //     [ robust ] ///
    //     save(filename)
    //
    // Options:
    //   target(string)         - The target variable for regression.
    //   predictors(varlist)    - Predictor variables.
    //   lambda(real)           - Lambda parameter for the Box-Cox transformation.
    //   robust                 - Use robust standard errors.
    //   save(string)           - Filename to save the trained model estimates (.ster).
    //
    // Example:
    // train_cox_box_regression, ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    //     lambda(0.5) ///
    //     robust ///
    //     save("cox_box_regression_model.ster")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        lambda(real) ///
        [ robust ///
          save(string) ]
    
    // Validate inputs
    if ("`target'" == "" | "`predictors'" == "") {
        display as error "train_cox_box_regression: Both 'target' and 'predictors' must be specified."
        exit 198
    }
    
    if ("`lambda'" == "") {
        display as error "train_cox_box_regression: Lambda value for Box-Cox transformation must be specified."
        exit 198
    }
    
    // Apply Box-Cox transformation to the target variable
    display "Applying Box-Cox transformation with lambda = `lambda'..."
    gen double boxcox_target = cond(`lambda' == 0, log(`target'), ///
        (`target'^`lambda' - 1) / `lambda')
    if (_rc != 0) {
        display as error "train_cox_box_regression: Failed to apply Box-Cox transformation."
        exit 198
    }
    
    // Train the regression model
    display "Training regression model on Box-Cox transformed target..."
    if ("`robust'" != "") {
        regress boxcox_target `predictors', robust
    }
    else {
        regress boxcox_target `predictors'
    }
    
    if (_rc != 0) {
        display as error "train_cox_box_regression: Regression training failed."
        exit 198
    }
    
    // Save the model estimates
    if ("`save'" != "") {
        estimates store cox_box_model
        estimates save "`save'", replace
        if (_rc != 0) {
            display as error "train_cox_box_regression: Failed to save model estimates."
            exit 198
        }
        display "Box-Cox Regression model trained and saved to `save'."
    }
    else {
        display as warning "train_cox_box_regression: No save path provided. Model estimates not saved."
    }
end
