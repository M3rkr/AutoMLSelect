*! version 2.3
program define automlselect
    // =========================================================================
    // automlselect.ado
    // =========================================================================
    //
    // Description:
    // Main entry point for the AutoMLSelect package. Facilitates training and evaluation
    // of various machine learning models for regression and classification tasks.
    //
    // Syntax:
    // automlselect [regression|classification], ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ num_trees(integer) ///
    //       mtry(integer) ///
    //       max_depth(integer) ///
    //       save_model(string) ///
    //       save_metrics(string) ]
    //
    // Options:
    //   regression|classification - Specifies the type of task.
    //   target(string)             - The target variable.
    //   predictors(varlist)        - Predictor variables.
    //   num_trees(integer)         - (Random Forest) Number of trees. Default is 100.
    //   mtry(integer)              - (Random Forest) Number of variables sampled at each split.
    //                               Default is ceil(sqrt(number of predictors)).
    //   max_depth(integer)         - (Random Forest) Maximum depth of each tree. Default is unlimited.
    //   save_model(string)         - Filename to save the trained model.
    //   save_metrics(string)       - Filename to save the evaluation metrics.
    //
    // Example:
    // automlselect regression, ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    //     num_trees(200) ///
    //     mtry(3) ///
    //     max_depth(10) ///
    //     save_model("models/regression_model") ///
    //     save_metrics("metrics/regression_metrics.csv")
    //
    // automlselect classification, ///
    //     target(Purchase) ///
    //     predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    //     num_trees(200) ///
    //     mtry(4) ///
    //     max_depth(10) ///
    //     save_model("models/classification_model") ///
    //     save_metrics("metrics/classification_metrics.csv")
    //
    // =========================================================================
    
    version 16.0
    syntax [, ///
        regression | classification ///
        target(string) ///
        predictors(string) ///
        [ num_trees(integer) ///
          mtry(integer) ///
          max_depth(integer) ///
          save_model(string) ///
          save_metrics(string) ]]
    
    if "`regression'" != "" & "`classification'" != "" {
        display as error "Please specify either 'regression' or 'classification', not both."
        exit 198
    }
    
    if "`regression'" == "" & "`classification'" == "" {
        display as error "Please specify the task type: 'regression' or 'classification'."
        exit 198
    }
    
    if "`target'" == "" {
        display as error "Please specify the target variable using the 'target()' option."
        exit 198
    }
    
    if "`predictors'" == "" {
        display as error "Please specify predictor variables using the 'predictors()' option."
        exit 198
    }
    
    // Determine task type
    if "`regression'" != "" {
        local task = "regression"
    }
    else {
        local task = "classification"
    }
    
    // Determine which model to train
    // For Regression: Linear Regression and Random Forest Regression
    // For Classification: Logistic Regression and Random Forest Classification
    
    // Train Linear or Logistic Regression
    if "`task'" == "regression" {
        display "Training Linear Regression Model..."
        train_linear_regression, ///
            target(`target') ///
            predictors(`predictors') ///
            robust ///
            save("`save_model'")
    }
    else if "`task'" == "classification" {
        display "Training Logistic Regression Model..."
        train_logistic_regression, ///
            target(`target') ///
            predictors(`predictors') ///
            robust ///
            save("`save_model'")
    }
    
    // Train Random Forest if options are provided
    if "`num_trees'" != "" | "`mtry'" != "" | "`max_depth'" != "" {
        if "`task'" == "regression" {
            display "Training Random Forest Regression Model..."
            train_random_forest_regression, ///
                target(`target') ///
                predictors(`predictors') ///
                num_trees(`num_trees') ///
                mtry(`mtry') ///
                max_depth(`max_depth') ///
                save("`save_model'_rf.dta")
        }
        else if "`task'" == "classification" {
            display "Training Random Forest Classification Model..."
            train_random_forest_classification, ///
                target(`target') ///
                predictors(`predictors') ///
                num_trees(`num_trees') ///
                mtry(`mtry') ///
                max_depth(`max_depth') ///
                save("`save_model'_rf.dta")
        }
    }
    
    // Evaluate Models
    display "Evaluating Trained Models..."
    evaluate_models, ///
        target(`target') ///
        save_metrics(`save_metrics')
    
    display "AutoMLSelect process completed successfully."
end
