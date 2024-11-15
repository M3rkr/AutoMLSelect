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
    //     save_metrics(metrics_filename)
    //
    // Options:
    //   target(string)        - The target variable.
    //   save_metrics(string)  - Filename to save the evaluation metrics (.csv).
    //
    // Example:
    // evaluate_models, ///
    //     target(Price) ///
    //     save_metrics("metrics/evaluation_metrics.csv")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        save_metrics(string)

    // Validate options
    if ("`target'" == "") {
        display as error "evaluate_models: 'target' must be specified."
        exit 198
    }
    
    if ("`save_metrics'" == "") {
        display as error "evaluate_models: 'save_metrics' must be specified."
        exit 198
    }

    // Initialize metrics storage
    tempfile metrics_file
    postfile handle str25 model double RMSE R_squared MAE MAPE Accuracy Precision Recall F1_Score AUC using `metrics_file', replace

    // List all trained model estimate files (*.ster)
    local model_files : dir models/ files "*.ster"

    if ("`model_files'" == "") {
        display as error "evaluate_models: No model estimate files (*.ster) found in 'models/' directory."
        exit 198
    }

    foreach model_file of local model_files {
        display "Evaluating `model_file'..."
        
        // Determine model type based on filename
        if (strpos("`model_file'", "linear_regression") > 0) {
            // Linear Regression Evaluation
            use "data/sample_regression_data.dta", clear
            estimates use "models/`model_file'", restore
            predict double prediction_var, xb
            local metrics_path = "metrics/temp_lr_metrics.csv"
            evaluate_regression, ///
                target("`target'") ///
                prediction("prediction_var") ///
                save_metrics("`metrics_path'")
            
            // Load regression metrics
            import delimited using "`metrics_path'", clear
            local RMSE = value[1]
            local R_squared = value[2]
            local MAE = value[3]
            local MAPE = value[4]
            
            // Post regression metrics
            post handle ("`model_file'") (`RMSE') (`R_squared') (`MAE') (`MAPE') (.) (.) (.) (.) (.)
        }
        else if (strpos("`model_file'", "logistic_regression") > 0) {
            // Logistic Regression Evaluation
            use "data/sample_classification_data.dta", clear
            estimates use "models/`model_file'", restore
            predict double probability_var, pr
            generate byte prediction_var = (probability_var >= 0.5)
            local metrics_path = "metrics/temp_class_metrics.csv"
            evaluate_classification, ///
                target("`target'") ///
                prediction("prediction_var") ///
                probability("probability_var") ///
                save_metrics("`metrics_path'")
            
            // Load classification metrics
            import delimited using "`metrics_path'", clear
            local Accuracy = value[1]
            local Precision = value[2]
            local Recall = value[3]
            local F1_Score = value[4]
            local AUC = value[5]
            
            // Post classification metrics
            post handle ("`model_file'") (.) (.) (.) (.) (`Accuracy') (`Precision') (`Recall') (`F1_Score') (`AUC')
        }
        else {
            display as warning "evaluate_models: Unknown model type for '`model_file''. Skipping evaluation."
        }
    }

    // Close postfile
    postclose handle

    // Export metrics
    use `metrics_file', clear
    export delimited using "`save_metrics'", replace

    display "All models evaluated. Metrics saved to '`save_metrics'."
end
