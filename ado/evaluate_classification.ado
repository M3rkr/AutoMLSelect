*! version 1.0
program define evaluate_classification
    // =========================================================================
    // evaluate_classification.ado
    // =========================================================================
    //
    // Description:
    // Evaluates the performance of a classification model by calculating Accuracy,
    // Precision, Recall, F1-Score, and AUC.
    //
    // Syntax:
    // evaluate_classification target(varname) prediction(varname) [probability(varname)] [options]
    //
    // Options:
    //   save_metrics(filename) - Save the calculated metrics to a CSV file
    //
    // Example:
    // . evaluate_classification target(Purchase) prediction(Purchase_pred) probability(Purchase_prob) save_metrics(class_metrics.csv)
    //
    // =========================================================================

    version 16.0
    syntax , ///
        target(string) ///
        prediction(string) ///
        [ probability(string) ] ///
        [ save_metrics(string) ]

    // -------------------------------------------------------------------------
    // 1. Validate Inputs
    // -------------------------------------------------------------------------
    if "`target'" == "" {
        display as error "Error: Target variable is not specified."
        exit 198
    }

    if "`prediction'" == "" {
        display as error "Error: Prediction variable is not specified."
        exit 198
    }

    // Check if target variable exists and is binary
    cap confirm variable `target'
    if _rc != 0 {
        display as error "Error: Target variable `target' does not exist in the dataset."
        exit 198
    }

    qui tabulate `target', missing
    if r(r) != 2 {
        display as error "Error: Target variable `target' must be binary (contain exactly two unique values) for classification evaluation."
        exit 198
    }

    // Check if prediction variable exists and is numeric or string
    cap confirm variable `prediction'
    if _rc != 0 {
        display as error "Error: Prediction variable `prediction' does not exist in the dataset."
        exit 198
    }

    qui describe `prediction'
    // Allow prediction variable to be string or numeric
    if r(type) != "float" & r(type) != "double" & r(type) != "long" & r(type) != "int" & r(type) != "byte" & r(type) != "string" {
        display as error "Error: Prediction variable `prediction' must be numeric or string for classification evaluation."
        exit 198
    }

    // Check for missing values in target or prediction
    qui count if missing(`target') | missing(`prediction')
    if r(N) > 0 {
        display as error "Error: There are missing values in the target or prediction variables. Please handle them before evaluation."
        exit 198
    }

    // If probability variable is specified, check if it exists and is numeric
    if "`probability'" != "" {
        cap confirm variable `probability'
        if _rc != 0 {
            display as error "Error: Probability variable `probability' does not exist in the dataset."
            exit 198
        }

        qui describe `probability'
        if r(type) != "float" & r(type) != "double" & r(type) != "long" & r(type) != "int" & r(type) != "byte" {
            display as error "Error: Probability variable `probability' must be numeric."
            exit 198
        }

        // Check that probability values are between 0 and 1
        qui su `probability', meanonly
        if r(min) < 0 | r(max) > 1 {
            display as error "Error: Probability variable `probability' must contain values between 0 and 1."
            exit 198
        }
    }

    // -------------------------------------------------------------------------
    // 2. Prepare Data for Evaluation
    // -------------------------------------------------------------------------
    display "Preparing data for classification performance evaluation..."

    // Create a binary indicator for actual positive class
    // Assuming the first level is the positive class
    qui levelsof `target', local(target_levels)
    local pos_class = "`: word 1 of `target_levels''"
    generate byte actual_positive = (`target' == "`pos_class'")

    // Create a binary indicator for predicted positive class
    // Assuming the first level is the positive class
    qui levelsof `prediction', local(pred_levels)
    local pred_pos_class = "`: word 1 of `pred_levels''"
    generate byte predicted_positive = (`prediction' == "`pred_pos_class'")

    // -------------------------------------------------------------------------
    // 3. Calculate Confusion Matrix Components
    // -------------------------------------------------------------------------
    display "Calculating confusion matrix components..."

    qui count if actual_positive == 1 & predicted_positive == 1
    local TP = r(N)

    qui count if actual_positive == 0 & predicted_positive == 1
    local FP = r(N)

    qui count if actual_positive == 1 & predicted_positive == 0
    local FN = r(N)

    qui count if actual_positive == 0 & predicted_positive == 0
    local TN = r(N)

    // -------------------------------------------------------------------------
    // 4. Calculate Performance Metrics
    // -------------------------------------------------------------------------
    display "Calculating performance metrics..."

    // Accuracy
    local accuracy = (`TP' + `TN') / (`TP' + `TN' + `FP' + `FN')

    // Precision
    if (`TP' + `FP') == 0 {
        local precision = .
    }
    else {
        local precision = `TP' / (`TP' + `FP')
    }

    // Recall
    if (`TP' + `FN') == 0 {
        local recall = .
    }
    else {
        local recall = `TP' / (`TP' + `FN')
    }

    // F1-Score
    if (`precision' == . | `recall' == . | (`precision' + `recall') == 0) {
        local f1 = .
    }
    else {
        local f1 = 2 * (`precision' * `recall') / (`precision' + `recall')
    }

    // AUC (if probability variable is provided)
    if "`probability'" != "" {
        // Ensure that `roctab` uses the positive class correctly
        // Assuming actual_positive is 1 for positive class
        qui roctab `probability' actual_positive, saving(roc_curve, replace)
        // Extract AUC from the ROC curve
        use roc_curve, clear
        qui summarize area, meanonly
        local auc = r(mean)
        // Reload the original dataset
        qui restore
    }

    // -------------------------------------------------------------------------
    // 5. Display Metrics
    // -------------------------------------------------------------------------
    display as text "----------------------------------------"
    display as text "Classification Performance Metrics:"
    display as text "----------------------------------------"
    display as result "Accuracy: " %9.4f `accuracy'
    display as result "Precision: " %9.4f `precision'
    display as result "Recall: " %9.4f `recall'
    display as result "F1-Score: " %9.4f `f1'

    if "`probability'" != "" {
        display as result "AUC: " %9.4f `auc'
    }

    display as text "----------------------------------------"

    // -------------------------------------------------------------------------
    // 6. Save Metrics to CSV if Specified
    // -------------------------------------------------------------------------
    if "`save_metrics'" != "" {
        // Create a temporary dataset to store metrics
        tempname metrics
        qui {
            postfile `metrics' str20 metric_name double metric_value using temp_metrics.dta, replace
            post `metrics' "Accuracy" (`accuracy')
            post `metrics' "Precision" (`precision')
            post `metrics' "Recall" (`recall')
            post `metrics' "F1-Score" (`f1')
            if "`probability'" != "" {
                post `metrics' "AUC" (`auc')
            }
            postclose `metrics'
        }

        // Export the metrics to CSV
        qui {
            use temp_metrics.dta, clear
            export delimited using "`save_metrics'", replace
            drop _all
        }

        display "Performance metrics saved to '`save_metrics''."
    }

    // -------------------------------------------------------------------------
    // 7. Clean Up Temporary Variables
    // -------------------------------------------------------------------------
    drop actual_positive predicted_positive

    // -------------------------------------------------------------------------
    // 8. End of Program
    // -------------------------------------------------------------------------
    display "Classification evaluation completed successfully."

end
