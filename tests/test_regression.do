* test_regression.do
* ===================
* Unit Tests for Regression Functions in AutoMLSelect Package
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.3

clear all
set more off

*-----------------------------
* Test Case 1: Successful Training and Evaluation of Linear Regression Model
*-----------------------------
display as text "Running Test Case 1: Successful Training and Evaluation of Linear Regression Model"

* Setup
use "data/sample_regression_data.dta", clear

* Verify Data Cleanliness
* Ensure there are no missing values in critical variables
foreach var in Price Size Bedrooms Age Location_east Location_north Location_south Location_west {
    quietly count if missing(`var')
    if r(N) > 0 {
        display as error "Test Case 1 Failed: Missing values detected in variable `var'."
        exit 198
    }
}

* Train Linear Regression
train_linear_regression, ///
    target(Price) ///
    predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    robust ///
    save("models/linear_regression_test_model.dta")

* Predict
use "data/sample_regression_data.dta", clear
predict double Price_pred_linear_regression

* Evaluate
evaluate_regression, ///
    target(Price) ///
    prediction(Price_pred_linear_regression) ///
    save_metrics("metrics/linear_regression_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 1 Failed: Linear regression model training failed."

assert !missing(Price_pred_linear_regression[1]), ///
    "Test Case 1 Failed: Predicted values not generated."

assert fileexists("metrics/linear_regression_test_metrics.csv"), ///
    "Test Case 1 Failed: Metrics file not found."

import delimited using "metrics/linear_regression_test_metrics.csv", clear
assert inlist("RMSE", metric) & inlist("R-squared", metric) & ///
       inlist("MAE", metric) & inlist("MAPE", metric), ///
       "Test Case 1 Failed: Expected regression metrics are missing."

display as text "Test Case 1 Passed."

*-----------------------------
* Test Case 2: Successful Training and Evaluation of Random Forest Regression Model
*-----------------------------
display as text "Running Test Case 2: Successful Training and Evaluation of Random Forest Regression Model"

* Train Random Forest Regression
train_random_forest_regression, ///
    target(Price) ///
    predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    num_trees(200) ///
    mtry(3) ///
    max_depth(10) ///
    save("models/random_forest_regression_test_model.dta")

* Predict
use "data/sample_regression_data.dta", clear
predict double Price_pred_random_forest_regression

* Evaluate
evaluate_regression, ///
    target(Price) ///
    prediction(Price_pred_random_forest_regression) ///
    save_metrics("metrics/random_forest_regression_test_metrics.csv")

* Assertions
assert _rc == 0, "Test Case 2 Failed: Random Forest regression model training failed."

assert !missing(Price_pred_random_forest_regression[1]), ///
    "Test Case 2 Failed: Predicted values not generated."

assert fileexists("metrics/random_forest_regression_test_metrics.csv"), ///
    "Test Case 2 Failed: Metrics file not found."

import delimited using "metrics/random_forest_regression_test_metrics.csv", clear
assert inlist("RMSE", metric) & inlist("R-squared", metric) & ///
       inlist("MAE", metric) & inlist("MAPE", metric), ///
       "Test Case 2 Failed: Expected regression metrics are missing."

display as text "Test Case 2 Passed."

*-----------------------------
* Test Case 3: Model Selection Based on Invalid Metric in Regression Task
*-----------------------------
display as text "Running Test Case 3: Model Selection Based on Invalid Metric in Regression Task"

* Setup
* Create a metrics CSV with valid regression metrics
clear
input str25 model double(RMSE R_squared MAE MAPE)
"Linear Regression" 5234.5678 0.8765 4123.4567 5.6789
"Random Forest Regression" 4000.1234 0.9100 3500.7890 4.3210
end
export delimited using "metrics/combined_regression_metrics.csv", replace

* Execution
capture {
    select_best_model using "metrics/combined_regression_metrics.csv", ///
        task(regression) ///
        metric("AUC") ///
        direction(maximize) ///
        save_results("metrics/best_regression_invalid_metric.csv")
}

* Assertions
assert _rc != 0, "Test Case 3 Failed: select_best_model did not fail with invalid metric."

assert !fileexists("metrics/best_regression_invalid_metric.csv"), ///
    "Test Case 3 Failed: Best model file should not be created with invalid metric."

display as text "Test Case 3 Passed."

*-----------------------------
* Summary of Regression Tests
*-----------------------------
display as text "==========================================="
display as text "       Regression Unit Tests Completed     "
display as text "==========================================="
