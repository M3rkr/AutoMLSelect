*! version 1.0
program define train_logistic_regression
    // =========================================================================
    // train_logistic_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a logistic regression model using the specified target and predictor variables.
    // Stores the model estimates for later evaluation or selection.
    //
    // Syntax:
    // train_logistic_regression target(varname) predictors(varlist) [options]
    //
    // Options:
    //   robust      - Use robust standard errors
    //   save(name)  - Save the model estimates with a specified name
    //
    // Example:
    // . train_logistic_regression target(Purchase) predictors(Age Gender Income Region) robust save(lr_purchase)
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

    // Check if target variable exists and is binary categorical
    cap confirm variable `target'
    if _rc != 0 {
        display as error "Error: Target variable `target' does not exist in the dataset."
        exit 198
    }

    qui tabulate `target', missing
    if r(r) != 2 {
        display as error "Error: Target variable `target' must be binary (contain exactly two unique values) for logistic regression."
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
    // 2. Train Logistic Regression Model
    // -------------------------------------------------------------------------
    display "Training Logistic Regression model..."
    
    // Construct the logistic regression command
    local logit_cmd "logit `target' `predictors'"

    // Append robust option if specified
    if "`robust'" != "" {
        local logit_cmd "`logit_cmd', vce(robust)"
    }

    // Execute the logistic regression
    qui {
        // Clear previous estimates if any
        estimates clear

        // Run the logistic regression
        `logit_cmd'

        // Store the estimates with a unique name
        estimates store logistic_regression_model
    }

    display "Logistic Regression model trained and stored as 'logistic_regression_model'."

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
