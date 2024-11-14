* test_classification.do
* ========================
* Unit Tests for Classification Functions in AutoMLSelect Package
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.0

clear all
set more off

*-----------------------------
* Test Case 1: Successful Training and Evaluation of Logistic Regression Model
*-----------------------------
display as text "Running Test Case 1: Successful Training and Evaluation of Logistic Regression Model"

* Setup
use "data/sample_classification_data.dta", clear

* Preprocess
preprocess_data using "data/sample_classification_data.dta", ///
    target(Purchase) ///
    predictors(Age Gender Income Region) ///
    handle_missing(mean mode) ///
    encode_onehot

* Train
train_logistic_regression, ///
    target(Purchase) ///
    predictors(Age Gender_Female Gender_Male Income Region_east Region_north Region_south Region_west) ///
    robust ///
    save("logistic_regression_test_model")

* Predict
predict double Purchase_prob_logistic_regression, pr
predict byte Purchase_pred_logistic_regression

* Evaluate
evaluate_classification, ///
    target(Purchase) ///
    prediction(Purchase_pred_logistic_regression) ///
    probability(Purchase_prob_logistic_regression) ///
    save_metrics("logistic_regression_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 1 Failed: Logistic regression model training failed."

assert !missing(Purchase_prob_logistic_regression[1]), ///
    "Test Case 1 Failed: Predicted probabilities not generated."

assert !missing(Purchase_pred_logistic_regression[1]), ///
    "Test Case 1 Failed: Predicted class labels not generated."

assert fileexists("logistic_regression_test_metrics.csv"), ///
    "Test Case 1 Failed: Metrics file not found."

import delimited using "logistic_regression_test_metrics.csv", clear
assert inlist("Accuracy", metric) & inlist("Precision", metric) & ///
       inlist("Recall", metric) & inlist("F1-Score", metric) & ///
       inlist("AUC", metric), ///
       "Test Case 1 Failed: Expected classification metrics are missing."

display as text "Test Case 1 Passed."

*-----------------------------
* Test Case 2: Handling Missing Values in Classification Data
*-----------------------------
display as text "Running Test Case 2: Handling Missing Values in Classification Data"

* Setup
use "data/sample_classification_data.dta", clear

* Introduce additional missing values for testing (optional)
* Uncomment the following lines if you want to introduce new missing values
* replace Age = . in 60
* replace Gender = "" in 70
* replace Income = . in 80
* replace Region = "" in 90
* replace Purchase = . in 100

* Preprocess
preprocess_data using "data/sample_classification_data.dta", ///
    target(Purchase) ///
    predictors(Age Gender Income Region) ///
    handle_missing(mean mode) ///
    encode_onehot

* Train
train_logistic_regression, ///
    target(Purchase) ///
    predictors(Age Gender_Female Gender_Male Income Region_east Region_north Region_south Region_west) ///
    robust ///
    save("logistic_regression_missing_test_model")

* Predict
predict double Purchase_prob_logistic_regression_missing, pr
predict byte Purchase_pred_logistic_regression_missing

* Evaluate
evaluate_classification, ///
    target(Purchase) ///
    prediction(Purchase_pred_logistic_regression_missing) ///
    probability(Purchase_prob_logistic_regression_missing) ///
    save_metrics("logistic_regression_missing_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 2 Failed: Logistic regression model training failed with missing data."

assert !missing(Purchase_prob_logistic_regression_missing[1]), ///
    "Test Case 2 Failed: Predicted probabilities not generated with missing data."

assert !missing(Purchase_pred_logistic_regression_missing[1]), ///
    "Test Case 2 Failed: Predicted class labels not generated with missing data."

assert fileexists("logistic_regression_missing_test_metrics.csv"), ///
    "Test Case 2 Failed: Metrics file not found with missing data."

import delimited using "logistic_regression_missing_test_metrics.csv", clear
assert inlist("Accuracy", metric) & inlist("Precision", metric) & ///
       inlist("Recall", metric) & inlist("F1-Score", metric) & ///
       inlist("AUC", metric), ///
       "Test Case 2 Failed: Expected classification metrics are missing with missing data."

* Verify that missing values have been handled
* Reload and preprocess to check imputation
preprocess_data using "data/sample_classification_data.dta", ///
    target(Purchase) ///
    predictors(Age Gender Income Region) ///
    handle_missing(mean mode) ///
    encode_onehot

assert !missing(Age) & !missing(Gender_Female) & !missing(Gender_Male) & ///
       !missing(Income) & !missing(Region_east) & !missing(Region_north) & ///
       !missing(Region_south) & !missing(Region_west), ///
       "Test Case 2 Failed: Missing values were not handled properly."

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
export delimited using "combined_classification_metrics.csv", replace

* Execution
capture {
    select_best_model using "combined_classification_metrics.csv", ///
        task(classification) ///
        metric("MAPE") ///
        direction(maximize) ///
        save_results("best_classification_invalid_metric.csv")
}

* Assertions
assert _rc != 0, "Test Case 3 Failed: select_best_model did not fail with invalid metric."

assert !fileexists("best_classification_invalid_metric.csv"), ///
    "Test Case 3 Failed: Best model file should not be created with invalid metric."

display as text "Test Case 3 Passed."

*-----------------------------
* Summary of Classification Tests
*-----------------------------
display as text "==========================================="
display as text "    Classification Unit Tests Completed    "
display as text "==========================================="
