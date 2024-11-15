* test_classification.do
* ========================
* Unit Tests for Classification Functions in AutoMLSelect Package
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.3

clear all
set more off

*-----------------------------
* Test Case 1: Successful Training and Evaluation of Logistic Regression Model
*-----------------------------
display as text "Running Test Case 1: Successful Training and Evaluation of Logistic Regression Model"

* Setup
use "data/sample_classification_data.dta", clear

* Verify Data Cleanliness
* Ensure there are no missing values in critical variables
foreach var in Purchase Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west {
    quietly count if missing(`var')
    if r(N) > 0 {
        display as error "Test Case 1 Failed: Missing values detected in variable `var'."
        exit 198
    }
}

* Train Logistic Regression
train_logistic_regression, ///
    target(Purchase) ///
    predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    robust ///
    save("models/logistic_regression_test_model.dta")

* Predict
use "data/sample_classification_data.dta", clear
predict double Purchase_prob_logistic_regression, pr
predict byte Purchase_pred_logistic_regression

* Evaluate
evaluate_classification, ///
    target(Purchase) ///
    prediction(Purchase_pred_logistic_regression) ///
    probability(Purchase_prob_logistic_regression) ///
    save_metrics("metrics/logistic_regression_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 1 Failed: Logistic regression model training failed."

assert !missing(Purchase_prob_logistic_regression[1]), ///
    "Test Case 1 Failed: Predicted probabilities not generated."

assert !missing(Purchase_pred_logistic_regression[1]), ///
    "Test Case 1 Failed: Predicted class labels not generated."

assert fileexists("metrics/logistic_regression_test_metrics.csv"), ///
    "Test Case 1 Failed: Metrics file not found."

import delimited using "metrics/logistic_regression_test_metrics.csv", clear
assert inlist("Accuracy", metric) & inlist("Precision", metric) & ///
       inlist("Recall", metric) & inlist("F1-Score", metric) & ///
       inlist("AUC", metric), ///
       "Test Case 1 Failed: Expected classification metrics are missing."

display as text "Test Case 1 Passed."

*-----------------------------
* Test Case 2: Successful Training and Evaluation of Random Forest Classification Model
*-----------------------------
display as text "Running Test Case 2: Successful Training and Evaluation of Random Forest Classification Model"

* Train Random Forest Classification
train_random_forest_classification, ///
    target(Purchase) ///
    predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    num_trees(200) ///
    mtry(4) ///
    max_depth(10) ///
    save("models/random_forest_classification_test_model.dta")

* Predict
use "data/sample_classification_data.dta", clear
predict double Purchase_prob_random_forest_classification, pr
predict byte Purchase_pred_random_forest_classification

* Evaluate
evaluate_classification, ///
    target(Purchase) ///
    prediction(Purchase_pred_random_forest_classification) ///
    probability(Purchase_prob_random_forest_classification) ///
    save_metrics("metrics/random_forest_classification_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 2 Failed: Random Forest classification model training failed."

assert !missing(Purchase_prob_random_forest_classification[1]), ///
    "Test Case 2 Failed: Predicted probabilities not generated."

assert !missing(Purchase_pred_random_forest_classification[1]), ///
    "Test Case 2 Failed: Predicted class labels not generated."

assert fileexists("metrics/random_forest_classification_test_metrics.csv"), ///
    "Test Case 2 Failed: Metrics file not found."

import delimited using "metrics/random_forest_classification_test_metrics.csv", clear
assert inlist("Accuracy", metric) & inlist("Precision", metric) & ///
       inlist("Recall", metric) & inlist("F1-Score", metric) & ///
       inlist("AUC", metric), ///
       "Test Case 2 Failed: Expected classification metrics are missing."

display as text "Test Case 2 Passed."

*-----------------------------
* Test Case 3: Model Selection Based on Invalid Metric in Classification Task
*-----------------------------
display as text "Running Test Case 3: Model Selection Based on Invalid Metric in Classification Task"

* Setup
* Create a metrics CSV with valid classification metrics
clear
input str25 model double(Accuracy Precision Recall F1_Score AUC)
"Logistic Regression" 0.85 0.80 0.90 0.8462 0.92
"Random Forest Classification" 0.88 0.85 0.93 0.89 0.95
end
rename F1_Score "F1-Score"
export delimited using "metrics/combined_classification_metrics.csv", replace

* Execution
capture {
    select_best_model using "metrics/combined_classification_metrics.csv", ///
        task(classification) ///
        metric("MAPE") ///
        direction(maximize) ///
        save_results("metrics/best_classification_invalid_metric.csv")
}

* Assertions
assert _rc != 0, "Test Case 3 Failed: select_best_model did not fail with invalid metric."

assert !fileexists("metrics/best_classification_invalid_metric.csv"), ///
    "Test Case 3 Failed: Best model file should not be created with invalid metric."

display as text "Test Case 3 Passed."

*-----------------------------
* Summary of Classification Tests
*-----------------------------
display as text "==========================================="
display as text "    Classification Unit Tests Completed    "
display as text "==========================================="
