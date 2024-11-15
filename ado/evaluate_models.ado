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
    //   target(string)      - The target variable.
    //   save_metrics(string) - Filename to save the evaluation metrics.
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
        
        // Load the model
        use "data/sample_regression_data.dta", clear // Adjust based on task type
        
        // Determine model type based on filename
        if strpos("`model_file'", "linear_regression") {
            // Predict using Linear Regression
            predict double pred_lr, xb
            // Calculate regression metrics
            generate double residual = Price - pred_lr
            summarize residual, meanonly
            local RMSE = sqrt(r(mean)^2)
            quietly summarize residual, meanonly
            generate double MAE = mean(abs(residual))
            generate double MAPE = mean(abs(residual / Price)) * 100
            regress Price pred_lr
            local R_squared = e(r2)
            // Post metrics
            post handle ("`model_file'") (`RMSE') (`R_squared') (`MAE') (`MAPE') (.) (.) (.) (.) (.)
        }
        else if strpos("`model_file'", "random_forest_regression") {
            // Predict using Random Forest Regression
            predict double pred_rf_lr, xb
            // Calculate regression metrics
            generate double residual = Price - pred_rf_lr
            summarize residual, meanonly
            local RMSE = sqrt(r(mean)^2)
            quietly summarize residual, meanonly
            generate double MAE = mean(abs(residual))
            generate double MAPE = mean(abs(residual / Price)) * 100
            regress Price pred_rf_lr
            local R_squared = e(r2)
            // Post metrics
            post handle ("`model_file'") (`RMSE') (`R_squared') (`MAE') (`MAPE') (.) (.) (.) (.) (.)
        }
        else if strpos("`model_file'", "logistic_regression") {
            // Predict using Logistic Regression
            predict double prob_lr, pr
            predict byte pred_class_lr
            // Calculate classification metrics
            quietly tabulate Purchase pred_class_lr, matcell(cm)
            matrix list cm
            local TN = cm[1,1]
            local TP = cm[2,2]
            local FP = cm[1,2]
            local FN = cm[2,1]
            local Accuracy = (`TP' + `TN') / (`TP' + `TN' + `FP' + `FN')
            local Precision = `TP' / (`TP' + `FP')
            local Recall = `TP' / (`TP' + `FN')
            local F1_Score = 2 * (`Precision' * `Recall') / (`Precision' + `Recall')
            roc Purchase prob_lr
            local AUC = r(area)
            // Post metrics
            post handle ("`model_file'") (.) (.) (.) (.) (`Accuracy') (`Precision') (`Recall') (`F1_Score') (`AUC')
        }
        else if strpos("`model_file'", "random_forest_classification") {
            // Predict using Random Forest Classification
            predict double prob_rf_class, pr
            predict byte pred_class_rf_class
            // Calculate classification metrics
            quietly tabulate Purchase pred_class_rf_class, matcell(cm)
            matrix list cm
            local TN = cm[1,1]
            local TP = cm[2,2]
            local FP = cm[1,2]
            local FN = cm[2,1]
            local Accuracy = (`TP' + `TN') / (`TP' + `TN' + `FP' + `FN')
            local Precision = `TP' / (`TP' + `FP')
            local Recall = `TP' / (`TP' + `FN')
            local F1_Score = 2 * (`Precision' * `Recall') / (`Precision' + `Recall')
            roc Purchase prob_rf_class
            local AUC = r(area)
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
