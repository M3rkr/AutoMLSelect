*! version 2.3
program define evaluate_models
    // =========================================================================
    // evaluate_models.ado
    // =========================================================================
    //
    // Description:
    // Evaluates all trained models in the specified directory and saves evaluation metrics.
    //
    // Syntax:
    // evaluate_models, ///
    //     target(target_variable) ///
    //     save_metrics(filename)
    //
    // Options:
    //   target(string)        - The target variable.
    //   save_metrics(string)  - Filename to save the evaluation metrics.
    //
    // Example:
    // evaluate_models, ///
    //     target(Price) ///
    //     save_metrics("metrics/regression_metrics.csv")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        save_metrics(string)
    
    // Initialize metrics storage
    tempfile metrics_file
    postfile handle str25 model double(RMSE R_squared MAE MAPE Accuracy Precision Recall F1_Score AUC) using `metrics_file', replace
    
    // List all trained models
    local model_files : dir models/ files "*.dta"
    
    foreach model_file of local model_files {
        display "Evaluating `model_file'..."
        
        // Determine model type based on filename
        if strpos("`model_file'", "linear_regression") {
            // Regression Model: Linear Regression
            use "data/sample_regression_data.dta", clear
            predict double pred_lr, xb
            // Evaluate
            evaluate_regression, ///
                target(Price) ///
                prediction(pred_lr) ///
                save_metrics("metrics/temp_lr_metrics.csv")
            
            // Load metrics
            import delimited using "metrics/temp_lr_metrics.csv", clear
            local RMSE = value[1]
            local R_squared = value[2]
            local MAE = value[3]
            local MAPE = value[4]
            
            // Post metrics
            post handle ("`model_file'") (`RMSE') (`R_squared') (`MAE') (`MAPE') (.) (.) (.) (.) (.)
        }
        else if strpos("`model_file'", "random_forest_regression") {
            // Regression Model: Random Forest Regression
            use "data/sample_regression_data.dta", clear
            predict double pred_rf_lr, xb
            // Evaluate
            evaluate_regression, ///
                target(Price) ///
                prediction(pred_rf_lr) ///
                save_metrics("metrics/temp_rf_lr_metrics.csv")
            
            // Load metrics
            import delimited using "metrics/temp_rf_lr_metrics.csv", clear
            local RMSE = value[1]
            local R_squared = value[2]
            local MAE = value[3]
            local MAPE = value[4]
            
            // Post metrics
            post handle ("`model_file'") (`RMSE') (`R_squared') (`MAE') (`MAPE') (.) (.) (.) (.) (.)
        }
        else if strpos("`model_file'", "logistic_regression") {
            // Classification Model: Logistic Regression
            use "data/sample_classification_data.dta", clear
            predict double prob_lr, pr
            predict byte pred_class_lr
            // Evaluate
            evaluate_classification, ///
                target(Purchase) ///
                prediction(pred_class_lr) ///
                probability(prob_lr) ///
                save_metrics("metrics/temp_lr_class_metrics.csv")
            
            // Load metrics
            import delimited using "metrics/temp_lr_class_metrics.csv", clear
            local Accuracy = value[1]
            local Precision = value[2]
            local Recall = value[3]
            local F1_Score = value[4]
            local AUC = value[5]
            
            // Post metrics
            post handle ("`model_file'") (.) (.) (.) (`Accuracy') (`Precision') (`Recall') (`F1_Score') (`AUC')
        }
        else if strpos("`model_file'", "random_forest_classification") {
            // Classification Model: Random Forest Classification
            use "data/sample_classification_data.dta", clear
            predict double prob_rf_class, pr
            predict byte pred_class_rf_class
            // Evaluate
            evaluate_classification, ///
                target(Purchase) ///
                prediction(pred_class_rf_class) ///
                probability(prob_rf_class) ///
                save_metrics("metrics/temp_rf_class_metrics.csv")
            
            // Load metrics
            import delimited using "metrics/temp_rf_class_metrics.csv", clear
            local Accuracy = value[1]
            local Precision = value[2]
            local Recall = value[3]
            local F1_Score = value[4]
            local AUC = value[5]
            
            // Post metrics
            post handle ("`model_file'") (.) (.) (.) (`Accuracy') (`Precision') (`Recall') (`F1_Score') (`AUC')
        }
        else {
            display as warning "Unknown model type for `model_file'. Skipping evaluation."
        }
    }
    
    // Close postfile
    postclose handle
    
    // Export metrics
    use `metrics_file', clear
    export delimited using "`save_metrics'", replace
    
    display "All models evaluated. Metrics saved to `save_metrics'."
end
