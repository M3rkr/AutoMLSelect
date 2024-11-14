*! version 1.0
program define train_random_forest
    // =========================================================================
    // train_random_forest.ado
    // =========================================================================
    //
    // Description:
    // Trains a Random Forest model using the specified target and predictor variables.
    // Supports both regression and classification tasks based on the target variable.
    //
    // Syntax:
    // train_random_forest, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ trees(integer) ///
    //       mtry(integer) ]
    //
    // Options:
    //   target(varname)      - Target variable for the Random Forest model.
    //   predictors(varlist)  - Predictor variables for the Random Forest model.
    //   trees(integer)       - Number of trees to grow in the forest. Default is 500.
    //   mtry(integer)        - Number of variables randomly sampled as candidates at each split. Default is square root of number of predictors for classification and one-third for regression.
    //
    // Example:
    // train_random_forest, ///
    //     target(Purchase) ///
    //     predictors(Age Gender_income Income) ///
    //     trees(1000) ///
    //     mtry(3)
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ trees(integer) ///
          mtry(integer) ]

    // -------------------------------------------------------------------------
    // 1. Set Defaults for Optional Parameters
    // -------------------------------------------------------------------------
    if "`trees'" == "" {
        local trees = 500
    }

    if "`mtry'" == "" {
        // Calculate default mtry based on task
        // If target is binary, assume classification; else regression
        qui count if `target' == 0 | `target' == 1
        if _rc == 0 & r(N) > 0 {
            local mtry = ceil(sqrt(`: word count `predictors''))
        }
        else {
            local mtry = ceil(`: word count `predictors'` / 3)
        }
    }

    // -------------------------------------------------------------------------
    // 2. Determine Task Type
    // -------------------------------------------------------------------------
    // Assume classification if target is binary; else regression
    qui tabulate `target', missing
    if r(rng_min) == 0 & r(rng_max) == 1 & r(rng_min) != r(rng_max) {
        local task "classification"
    }
    else {
        local task "regression"
    }

    display "Training Random Forest Model for `task'..."
    
    // -------------------------------------------------------------------------
    // 3. Train Random Forest Model
    // -------------------------------------------------------------------------
    if "`task'" == "classification" {
        randomforest `target' `predictors', ///
            trees(`trees') ///
            mtry(`mtry') ///
            classification
    }
    else if "`task'" == "regression" {
        randomforest `target' `predictors', ///
            trees(`trees') ///
            mtry(`mtry') ///
            regression
    }
    else {
        display as error "Unsupported task type for Random Forest: `task'"
        exit 198
    }

    // -------------------------------------------------------------------------
    // 4. Save Model Estimates
    // -------------------------------------------------------------------------
    local model_name "random_forest_`task'"
    estimates store `model_name'
    display "Random Forest (`task') Model trained and estimates stored as `model_name'."

end
