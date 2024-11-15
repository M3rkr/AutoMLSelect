*! version 2.3
program define evaluate_classification
    // =========================================================================
    // evaluate_classification.ado
    // =========================================================================
    //
    // Description:
    // Evaluates classification models by calculating evaluation metrics.
    //
    // Syntax:
    // evaluate_classification, ///
    //     target(target_variable) ///
    //     prediction(predicted_variable) ///
    //     probability(probability_variable) ///
    //     save_metrics(filename)
    //
    // Options:
    //   target(string)         - The true target variable.
    //   prediction(string)     - The predicted class labels from the model.
    //   probability(string)    - The predicted probabilities from the model.
    //   save_metrics(string)   - Filename to save the evaluation metrics.
    //
    // Example:
    // evaluate_classification, ///
    //     target(Purchase) ///
    //     prediction(Purchase_pred_logistic_regression) ///
    //     probability(Purchase_prob_logistic_regression) ///
    //     save_metrics("metrics/classification_metrics.csv")
    //
    // =========================================================================
    
    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        probability(string) ///
        save_metrics(string)
    
    // Check if variables exist
    if "`target'" == "" | "`prediction'" == "" | "`probability'" == "" {
        display as error "Target, prediction, and probability variables must be specified."
        exit 198
    }
    
    // Calculate evaluation metrics
    display "Calculating Classification Metrics..."
    
    // Confusion Matrix Components
    quietly tabulate `target' `prediction', matcell(cm)
    matrix list cm
    local TN = cm[1,1]
    local TP = cm[2,2]
    local FP = cm[1,2]
    local FN = cm[2,1]
    
    // Calculate Metrics
    local Accuracy = (`TP' + `TN') / (`TP' + `TN' + `FP' + `FN')
    local Precision = `TP' / (`TP' + `FP')
    local Recall = `TP' / (`TP' + `FN')
    local F1_Score = 2 * (`Precision' * `Recall') / (`Precision' + `Recall')
    
    // Calculate AUC
    roc `target' `probability'
    local AUC = r(area)
    
    // Create metrics dataset
    clear
    input str25 metric double value
    "Accuracy" .
    "Precision" .
    "Recall" .
    "F1-Score" .
    "AUC" .
    end
    replace value = `Accuracy' in 1
    replace value = `Precision' in 2
    replace value = `Recall' in 3
    replace value = `F1_Score' in 4
    replace value = `AUC' in 5
    
    // Save metrics
    export delimited using "`save_metrics'", replace
    display "Classification metrics saved to `save_metrics'."
end
