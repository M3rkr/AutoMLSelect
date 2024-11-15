*! version 2.3
program define train_random_forest_regression
    // =========================================================================
    // train_random_forest_regression.ado
    // =========================================================================
    //
    // Description:
    // Trains a Random Forest Regression model using the specified target and predictors.
    //
    // Syntax:
    // train_random_forest_regression, ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     num_trees(integer) ///
    //     mtry(integer) ///
    //     max_depth(integer) ///
    //     save(filename)
    //
    // Options:
    //   target(string)         - The target variable for regression.
    //   predictors(varlist)    - Predictor variables.
    //   num_trees(integer)     - Number of trees in the forest. Default is 100.
    //   mtry(integer)          - Number of variables randomly sampled as candidates at each split. Default is ceil(sqrt(number of predictors)).
    //   max_depth(integer)     - Maximum depth of each tree. Default is unlimited.
    //   save(string)           - Filename to save the trained model.
    //
    // Example:
    // train_random_forest_regression, ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    //     num_trees(200) ///
    //     mtry(3) ///
    //     max_depth(10) ///
    //     save("models/random_forest_regression_model.dta")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        predictors(string) ///
        [ num_trees(integer) ///
          mtry(integer) ///
          max_depth(integer) ///
          save(string) ]
    
    // Set default values
    if "`num_trees'" == "" {
        local num_trees = 100
    }
    if "`mtry'" == "" {
        // Calculate ceil of sqrt of number of predictors
        local num_predictors : word count `predictors'
        local mtry = ceil(sqrt(`num_predictors'))
    }
    if "`max_depth'" == "" {
        local max_depth = 0 // 0 indicates unlimited depth
    }
    
    // Check if 'randomforest' package is installed
    capture which randomforest
    if _rc {
        display as error "Random Forest functionality requires the 'randomforest' package. Please install it using:"
        display as text "ssc install randomforest"
        exit 198
    }
    
    // Train Random Forest Regression Model
    display "Training Random Forest Regression Model..."
    rforest `target' `predictors', ///
        ntree(`num_trees') ///
        mtry(`mtry') ///
        max_depth(`max_depth') ///
        save(`save')
    
    if _rc {
        display as error "Random Forest Regression training failed."
        exit 198
    }
    else {
        display "Random Forest Regression model trained and saved to `save'."
    }
end
