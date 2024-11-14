* test_regression.do
* ===================
* Unit Tests for Regression Functions in AutoMLSelect Package
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.0

clear all
set more off

*-----------------------------
* Test Case 1: Successful Training and Evaluation of Linear Regression Model
*-----------------------------
display as text "Running Test Case 1: Successful Training and Evaluation of Linear Regression Model"

* Setup
use "data/sample_regression_data.dta", clear

* Preprocess
preprocess_data using "data/sample_regression_data.dta", ///
    target(Price) ///
    predictors(Size Bedrooms Age Location) ///
    handle_missing(mean mode) ///
    encode_onehot

* Train
train_linear_regression, ///
    target(Price) ///
    predictors(Size Bedrooms Age Location_north Location_south) ///
    robust ///
    save("linear_regression_test_model")

* Predict
predict double Price_pred_linear_regression

* Evaluate
evaluate_regression, ///
    target(Price) ///
    prediction(Price_pred_linear_regression) ///
    save_metrics("linear_regression_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 1 Failed: Linear regression model training failed."

assert !missing(Price_pred_linear_regression[1]), ///
    "Test Case 1 Failed: Predicted values not generated."

assert fileexists("linear_regression_test_metrics.csv"), ///
    "Test Case 1 Failed: Metrics file not found."

import delimited using "linear_regression_test_metrics.csv", clear
assert inlist("RMSE", metric) & inlist("R-squared", metric) & ///
       inlist("MAE", metric) & inlist("MAPE", metric), ///
       "Test Case 1 Failed: Expected regression metrics are missing."

display as text "Test Case 1 Passed."

*-----------------------------
* Test Case 2: Handling Missing Values in Regression Data
*-----------------------------
display as text "Running Test Case 2: Handling Missing Values in Regression Data"

* Setup
use "data/sample_regression_data.dta", clear

* Introduce additional missing values for testing (optional)
* Uncomment the following lines if you want to introduce new missing values
* replace Size = . in 60
* replace Bedrooms = . in 70
* replace Age = . in 80
* replace Location = "" in 90
* replace Price = . in 100

* Preprocess
preprocess_data using "data/sample_regression_data.dta", ///
    target(Price) ///
    predictors(Size Bedrooms Age Location) ///
    handle_missing(mean mode) ///
    encode_onehot

* Train
train_linear_regression, ///
    target(Price) ///
    predictors(Size Bedrooms Age Location_north Location_south) ///
    robust ///
    save("linear_regression_missing_test_model")

* Predict
predict double Price_pred_linear_regression_missing

* Evaluate
evaluate_regression, ///
    target(Price) ///
    prediction(Price_pred_linear_regression_missing) ///
    save_metrics("linear_regression_missing_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 2 Failed: Linear regression model training failed with missing data."

assert !missing(Price_pred_linear_regression_missing[1]), ///
    "Test Case 2 Failed: Predicted values not generated with missing data."

assert fileexists("linear_regression_missing_test_metrics.csv"), ///
    "Test Case 2 Failed: Metrics file not found with missing data."

import delimited using "linear_regression_missing_test_metrics.csv", clear
assert inlist("RMSE", metric) & inlist("R-squared", metric) & ///
       inlist("MAE", metric) & inlist("MAPE", metric), ///
       "Test Case 2 Failed: Expected regression metrics are missing with missing data."

* Verify that missing values have been handled
* Reload and preprocess to check imputation
preprocess_data using "data/sample_regression_data.dta", ///
    target(Price) ///
    predictors(Size Bedrooms Age Location) ///
    handle_missing(mean mode) ///
    encode_onehot

assert !missing(Size) & !missing(Bedrooms) & !missing(Age) & ///
       !missing(Location_north) & !missing(Location_south), ///
       "Test Case 2 Failed: Missing values were not handled properly."

display as text "Test Case 2 Passed."

*-----------------------------
* Test Case 3: Model Selection Based on Incorrect Metric
*-----------------------------
display as text "Running Test Case 3: Model Selection Based on Incorrect Metric"

* Setup
* Create a metrics CSV with valid regression metrics
clear
input str25 model double(RMSE R_squared MAE MAPE)
"Linear Regression" 5234.5678 0.8765 4123.4567 5.6789
"Random Forest Regression" 4000.1234 0.9100 3500.7890 4.3210
end
export delimited using "combined_regression_metrics.csv", replace

* Execution
capture {
    select_best_model using "combined_regression_metrics.csv", ///
        task(regression) ///
        metric("AUC") ///
        direction(maximize) ///
        save_results("best_regression_invalid_metric.csv")
}

* Assertions
assert _rc != 0, "Test Case 3 Failed: select_best_model did not fail with invalid metric."

assert !fileexists("best_regression_invalid_metric.csv"), ///
    "Test Case 3 Failed: Best model file should not be created with invalid metric."

display as text "Test Case 3 Passed."

*-----------------------------
* Summary of Regression Tests
*-----------------------------
display as text "==========================================="
display as text "       Regression Unit Tests Completed     "
display as text "==========================================="
