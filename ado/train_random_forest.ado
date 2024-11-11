*! version 1.0
program define train_random_forest
    // =========================================================================
    // train_random_forest.ado
    // =========================================================================
    //
    // Description:
    // Trains a Random Forest model using the specified target and predictor variables.
    // Utilizes the user-contributed 'randomforest' package.
    // Stores the model estimates for later evaluation or selection.
    //
    // Syntax:
    // train_random_forest target(varname) predictors(varlist) [options]
    //
    // Options:
    //   trees(#)    - Number of trees to grow (default: 500)
    //   mtry(#)     - Number of variables to possibly split at in each node (default: sqrt(#predictors))
    //   save(name)  - Save the model results with a specified name
    //
    // Example:
    // . train_random_forest target(Purchase) predictors(Age Gender Income Region) trees(1000) mtry(3) save(rf_purchase)
    //
    // =========================================================================

    version 16.0
    syntax, ///
        target(string) ///
        predictors(varlist) ///
        [ trees(integer 500) mtry(integer) save(string) ]

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

    // Check if target variable exists
    cap confirm variable `target'
    if _rc != 0 {
        display as error "Error: Target variable `target' does not exist in the dataset."
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

    // Determine if the problem is classification or regression based on target variable
    qui describe `target'
    if r(type) == "string" {
        local problem "classification"
    }
    else if r(type) == "float" | r(type) == "double" | r(type) == "long" | r(type) == "int" | r(type) == "byte" {
        // Check if target variable is binary for classification
        qui tabulate `target', missing
        if r(r) == 2 {
            local problem "classification"
        }
        else {
            local problem "regression"
        }
    }
    else {
        display as error "Error: Unsupported target variable type."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 2. Check and Install 'randomforest' Package if Necessary
    // -------------------------------------------------------------------------
    capture which randomforest
    if _rc != 0 {
        display "The 'randomforest' package is not installed. Attempting to install..."
        ssc install randomforest, replace
        if _rc != 0 {
            display as error "Error: Failed to install the 'randomforest' package. Please install it manually."
            exit 198
        }
        else {
            display "Successfully installed the 'randomforest' package."
        }
    }
    else {
        display "The 'randomforest' package is already installed."
    }

    // -------------------------------------------------------------------------
    // 3. Set Default Parameters if Not Specified
    // -------------------------------------------------------------------------
    // Number of trees
    if "`trees'" == "" {
        local trees 500
    }
    else {
        local trees `trees'
    }

    // Number of variables to possibly split at in each node
    if "`mtry'" == "" {
        local num_predictors : word count `predictors'
        local mtry = ceil(sqrt(`num_predictors'))
    }
    else {
        local mtry `mtry'
    }

    // -------------------------------------------------------------------------
    // 4. Train Random Forest Model
    // -------------------------------------------------------------------------
    display "Training Random Forest model..."
    display "Number of trees: `trees'"
    display "Number of variables tried at each split (mtry): `mtry'"

    // Set seed for reproducibility
    set seed 12345

    // Train the Random Forest model
    qui {
        if "`problem'" == "classification" {
            randomforest `target' `predictors', ///
                trees(`trees') ///
                mtry(`mtry') ///
                classification ///
                importance ///
                keep
        }
        else if "`problem'" == "regression" {
            randomforest `target' `predictors', ///
                trees(`trees') ///
                mtry(`mtry') ///
                regression ///
                importance ///
                keep
        }
    }

    display "Random Forest model trained successfully."

    // -------------------------------------------------------------------------
    // 5. Save the Model Results if Specified
    // -------------------------------------------------------------------------
    if "`save'" != "" {
        // Save the random forest model results
        // Note: The 'randomforest' package does not have a built-in save function.
        // Therefore, we save the entire dataset with model predictions.

        // Generate predictions
        predict double rf_predicted if e(sample), ///
            pr(`target')  // For classification, predicted probabilities

        // Save the predictions and model details
        save "`save'.dta", replace

        if _rc == 0 {
            display "Random Forest model predictions saved as '`save'.dta'."
        }
        else {
            display as error "Error: Failed to save model predictions."
        }
    }

    // -------------------------------------------------------------------------
    // 6. Store the Model (if possible)
    // -------------------------------------------------------------------------
    // Since 'randomforest' does not integrate with Stata's 'estimates' system,
    // we can store relevant information manually or utilize user-contributed methods.

    // For demonstration, we will store basic model information
    tempname rf_info
    qui {
        postfile `rf_info' str20 model_type int trees float mtry using rf_model_info, replace
        post `rf_info' ("Random_Forest") (`trees') (`mtry')
        postclose `rf_info'
    }

    // Append to estimates
    append using rf_model_info.dta, force

    display "Random Forest model information stored."

    // -------------------------------------------------------------------------
    // 7. End of Program
    // -------------------------------------------------------------------------
    display "Training completed successfully."

end
