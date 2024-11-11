*! version 1.0
program define train_linear_regression
    // =========================================================================
    // train_linear_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a linear regression model using the specified target and predictor variables.
    // Stores the model estimates for later evaluation or selection.
    //
    // Syntax:
    // train_linear_regression target(varname) predictors(varlist) [options]
    //
    // Options:
    //   robust    - Use robust standard errors
    //   save(name) - Save the model estimates with a specified name
    //
    // Example:
    // . train_linear_regression target(Income) predictors(Age Education Experience) robust save(lm_income)
    //
    // =========================================================================

    version 16.0
    syntax, ///
        target(string) ///
        predictors(varlist) ///
        [ robust save(string) ]

    // -------------------------------------------------------------------------
    // 1. Validate Inputs
    // -------------------------------------------------------------------------
    if "`target'" == "" {
        display as error "Error: Target variable is not specified."
        exit 198
    }

    if "`predictors'" == "" {
        display as error "Error: Predictor variables are not specified."
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
        display as error "Error: Target variable `target' must be numeric for linear regression."
        exit 198
    }

    // Check if predictor variables exist
    foreach var of varlist `predictors' {
        cap confirm variable `var'
        if _rc != 0 {
            display as error "Error: Predictor variable `var' does not exist in the dataset."
            exit 198
        }
    }

    // -------------------------------------------------------------------------
    // 2. Train Linear Regression Model
    // -------------------------------------------------------------------------
    display "Training Linear Regression model..."
    
    // Construct the regression command
    local reg_cmd "regress `target' `predictors'"

    // Append robust option if specified
    if "`robust'" != "" {
        local reg_cmd "`reg_cmd', robust"
    }

    // Execute the regression
    qui {
        // Clear previous estimates if any
        estimates clear

        // Run the regression
        `reg_cmd'

        // Store the estimates with a unique name
        estimates store linear_regression_model
    }

    display "Linear Regression model trained and stored as 'linear_regression_model'."

    // -------------------------------------------------------------------------
    // 3. Save the Model Estimates if Specified
    // -------------------------------------------------------------------------
    if "`save'" != "" {
        // Save the estimates to a file
        estimates save "`save'.ster", replace

        if _rc == 0 {
            display "Model estimates saved as '`save'.ster'."
        }
        else {
            display as error "Error: Failed to save model estimates."
        }
    }

    // -------------------------------------------------------------------------
    // 4. End of Program
    // -------------------------------------------------------------------------
    display "Training completed successfully."

end
