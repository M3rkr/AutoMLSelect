*! version 2.3
program define evaluate_classification
    // =========================================================================
    // evaluate_classification.ado
    // =========================================================================
    //
    // Description:
    // Evaluates classification model predictions by calculating performance metrics.
    //
    // Syntax:
    // evaluate_classification, ///
    //     target(target_variable) ///
    //     prediction(prediction_variable) ///
    //     probability(probability_variable) ///
    //     save_metrics(metrics_filename)
    //
    // Options:
    //   target(string)         - The true target variable.
    //   prediction(string)     - The predicted class labels from the model.
    //   probability(string)    - The predicted probabilities from the model.
    //   save_metrics(string)   - Path to save the evaluation metrics (.csv).
    //
    // Example:
    // evaluate_classification, ///
    //     target(Purchase) ///
    //     prediction(Purchase_pred) ///
    //     probability(Purchase_prob) ///
    //     save_metrics("metrics/classification_metrics.csv")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        probability(string) ///
        save_metrics(string)

    // Validate options
    if ("`target'" == "" | "`prediction'" == "" | "`probability'" == "") {
        display as error "evaluate_classification: 'target', 'prediction', and 'probability' must be specified."
        exit 198
    }
    
    if ("`save_metrics'" == "") {
        display as error "evaluate_classification: 'save_metrics' must be specified."
        exit 198
    }

    // Confirm variables exist
    confirm variable `target'
    confirm variable `prediction'
    confirm variable `probability'

    // Calculate Metrics
    quietly {
        // Accuracy
        qui count if `prediction' == `target'
        scalar Accuracy = r(N) / _N

        // Precision
        qui count if `prediction' == 1 & `target' == 1
        scalar TP = r(N)
        qui count if `prediction' == 1
        scalar Pred_Pos = r(N)
        scalar Precision = (Pred_Pos > 0) ? TP / Pred_Pos : 0

        // Recall
        qui count if `target' == 1
        scalar Actual_Pos = r(N)
        scalar Recall = (Actual_Pos > 0) ? TP / Actual_Pos : 0

        // F1 Score
        scalar F1_Score = (Precision + Recall > 0) ? 2 * (Precision * Recall) / (Precision + Recall) : 0

        // AUC
        quietly {
            // Check if the 'roc' command is available
            which roc
            if (_rc == 0) {
                roc `target' `probability', graph(auc) silent
                scalar AUC = r(roc)
            }
            else {
                display as warning "ROC analysis not available. Setting AUC to missing."
                scalar AUC = .
            }
        }
    }

    // Prepare to save metrics
    tempfile metrics_temp
    postfile handle str32 metric double value using `metrics_temp', replace
    post handle ("Accuracy") (Accuracy)
    post handle ("Precision") (Precision)
    post handle ("Recall") (Recall)
    post handle ("F1_Score") (F1_Score)
    if (!missing(AUC)) {
        post handle ("AUC") (AUC)
    }
    postclose handle

    // Save metrics to specified path
    use `metrics_temp', clear
    export delimited using "`save_metrics'", replace

    display "Classification metrics saved to `save_metrics'."
end
