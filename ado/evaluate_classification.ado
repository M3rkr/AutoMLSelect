*! version 1.0
program define evaluate_classification
    // =========================================================================
    // evaluate_classification.ado
    // =========================================================================
    //
    // Description:
    // Evaluates a classification model by calculating performance metrics.
    //
    // Syntax:
    // evaluate_classification, ///
    //     target(target_variable) ///
    //     prediction(predicted_variable) ///
    //     probability(probability_variable) ///
    //     [ metrics(metric_list) ///
    //       save_metrics(string) ]
    //
    // Options:
    //   target(varname)          - Actual target variable (binary).
    //   prediction(varname)      - Predicted target variable (binary).
    //   probability(varname)     - Predicted probability for the positive class.
    //   metrics(metric_list)     - List of metrics to calculate (Accuracy, Precision, Recall, F1-Score, AUC).
    //   save_metrics(string)      - File path to save the calculated metrics as CSV.
    //
    // Example:
    // evaluate_classification, ///
    //     target(Purchase) ///
    //     prediction(Purchase_pred_logistic_regression) ///
    //     probability(Purchase_prob_logistic_regression) ///
    //     metrics(Accuracy Precision Recall F1-Score AUC) ///
    //     save_metrics("logistic_regression_metrics.csv")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        probability(string) ///
        [ metrics(string) ///
          save_metrics(string) ]

    // -------------------------------------------------------------------------
    // 1. Calculate Metrics
    // -------------------------------------------------------------------------
    display "Calculating Classification Metrics..."
    // Confusion Matrix Components
    qui count if `target' == 1
    local total_pos = r(N)
    qui count if `target' == 0
    local total_neg = r(N)
    qui count if `target' == 1 & `prediction' == 1
    local true_pos = r(N)
    qui count if `target' == 0 & `prediction' == 1
    local false_pos = r(N)
    qui count if `target' == 1 & `prediction' == 0
    local false_neg = r(N)
    qui count if `target' == 0 & `prediction' == 0
    local true_neg = r(N)

    // Calculate Accuracy
    local accuracy = (`true_pos' + `true_neg') / (`total_pos' + `total_neg')

    // Calculate Precision
    if (`true_pos' + `false_pos') != 0 {
        local precision = `true_pos' / (`true_pos' + `false_pos')
    }
    else {
        local precision = .
    }

    // Calculate Recall
    if (`true_pos' + `false_neg') != 0 {
        local recall = `true_pos' / (`true_pos' + `false_neg')
    }
    else {
        local recall = .
    }

    // Calculate F1-Score
    if (`precision' != . & `recall' != . & (`precision' + `recall') != 0) {
        local f1_score = 2 * (`precision' * `recall') / (`precision' + `recall')
    }
    else {
        local f1_score = .
    }

    // Calculate AUC
    // Requires the roctab package
    qui roctab `target' `probability', gen(roc_pred roc_prob)
    qui su roc_pred, meanonly
    local auc = r(mean)

    // Create a dataset of metrics
    clear
    input str15 metric double value
    "Accuracy"     `accuracy'
    "Precision"    `precision'
    "Recall"       `recall'
    "F1-Score"     `f1_score'
    "AUC"          `auc'
    end

    // -------------------------------------------------------------------------
    // 2. Display Metrics
    // -------------------------------------------------------------------------
    display as text "----------------------------------------"
    display as text "Classification Model Performance Metrics:"
    display as text "----------------------------------------"
    list, clean noobs
    display as text "----------------------------------------"

    // -------------------------------------------------------------------------
    // 3. Save Metrics to CSV
    // -------------------------------------------------------------------------
    if "`save_metrics'" != "" {
        export delimited using "`save_metrics'", replace
        if _rc == 0 {
            display "Classification metrics saved to '`save_metrics''."
        }
        else {
            display as error "Error: Failed to save classification metrics to '`save_metrics''."
        }
    }

    // -------------------------------------------------------------------------
    // 4. Cleanup
    // -------------------------------------------------------------------------
    drop roc_pred roc_prob

end
