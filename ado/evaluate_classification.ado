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
    //     target("Purchase") ///
    //     prediction("Purchase_pred_logistic_regression") ///
    //     probability("Purchase_prob_logistic_regression") ///
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
    confirm variable `target'
    confirm variable `prediction'
    confirm variable `probability'
    
    if _rc {
        display as error "One or more specified variables do not exist."
        exit 198
    }
    
    // Calculate confusion matrix components
    quietly tabulate `target' `prediction', matcell(cm)
    matrix list cm
    local TN = cm[1,1]
    local TP = cm[2,2]
    local FP = cm[1,2]
    local FN = cm[2,1]
    
    // Calculate metrics
    local Accuracy = (`TP' + `TN') / (`TP' + `TN' + `FP' + `FN')
    local Precision = (`TP' + `FP') > 0 ? (`TP' / (`TP' + `FP')) : 0
    local Recall = (`TP' + `FN') > 0 ? (`TP' / (`TP' + `FN')) : 0
    local F1_Score = (`Precision' + `Recall') > 0 ? (2 * `Precision' * `Recall') / (`Precision' + `Recall') : 0
    
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
    replace value = `Precis
