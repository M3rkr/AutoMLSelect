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
    target("Price") ///
    predictors("Size Bedrooms Age Location_east Location_north Location_south Location_west") ///
    robust ///
    save("models/linear_regression_test_model.dta")

* Predict
use "data/sample_regression_data.dta", clear

predict double Price_pred_linear_regression

* Evaluate
evaluate_regression, ///
    target("Price") ///
    prediction("Price_pred_linear_regression") ///
    save_metrics("metrics/linear_regression_test_metrics.csv")

* Assertions
if (_rc != 0) {
    display as error "Test Case 1 Failed: Regression evaluation failed."
    exit 198
}

* Verify that the metrics file exists
capture confirm file "metrics/linear_regression_test_metrics.csv"
if (_rc != 0) {
    display as error "Test Case 1 Failed: Metrics file not found."
    exit 198
}

* Verify contents of the metrics file
import delimited using "metrics/linear_regression_test_metrics.csv", clear
if (_N != 4) {
    display as error "Test Case 1 Failed: Incorrect number of metrics."
    exit 198
}

* Check for each required metric
local metrics_found = 0
foreach metric in RMSE "R-squared" MAE MAPE {
    count if metric == "`metric'"
    if (_N == 0) {
        display as error "Test Case 1 Failed: `metric' metric missing."
        exit 198
    }
    local metrics_found = `metrics_found' + 1
}

if (`metrics_found' != 4) {
    display as error "Test Case 1 Failed: Not all required metrics are present."
    exit 198
}

display as text "Test Case 1 Passed."

*-----------------------------
* Test Case 2: Successful Training and Evaluation of Random Forest Regression Model
*-----------------------------
display as text "Running Test Case 2: Successful Training and Evaluation of Random Forest Regression Model"

* Train Random Forest Regression
train_random_forest_regression, ///
    target("Price") ///
    predictors("Size Bedrooms Age Location_east Location_north Location_south Location_west") ///
    num_trees(200) ///
    mtry(3) ///
    max_depth(10) ///
    save("models/random_forest_regression_test_model.dta")

* Predict
use "data/sample_regression_data.dta", clear

predict double Price_pred_random_forest_regression

* Evaluate
evaluate_regression, ///
    target("Price") ///
    prediction("Price_pred_random_forest_regression") ///
    save_metrics("metrics/random_forest_regression_test_metrics.csv")

* Assertions
if (_rc != 0) {
    display as error "Test Case 2 Failed: Random Forest regression evaluation failed."
    exit 198
}

* Verify that the metrics file exists
capture confirm file "metrics/random_forest_regression_test_metrics.csv"
if (_rc != 0) {
    display as error "Test Case 2 Failed: Metrics file not found."
    exit 198
}

* Verify contents of the metrics file
import delimited using "metrics/random_forest_regression_test_metrics.csv", clear
if (_N != 4) {
    display as error "Test Case 2 Failed: Incorrect number of metrics."
    exit 198
}

* Check for each required metric
local metrics_found_rf = 0
foreach metric in RMSE "R-squared" MAE MAPE {
    count if metric == "`metric'"
    if (_N == 0) {
        display as error "Test Case 2 Failed: `metric' metric missing."
        exit 198
    }
    local metrics_found_rf = `metrics_found_rf' + 1
}

if (`metrics_found_rf' != 4) {
    display as error "Test Case 2 Failed: Not all required metrics are present."
    exit 198
}

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
if (_rc == 0) {
    display as error "Test Case 3 Failed: select_best_model should have failed with invalid metric."
    exit 198
}

if (fileexists("metrics/best_regression_invalid_metric.csv")) {
    display as error "Test Case 3 Failed: Best model file should not be created with invalid metric."
    exit 198
}

display as text "Test Case 3 Passed."

*-----------------------------
* Summary of Regression Tests
*-----------------------------
display as text "==========================================="
display as text "       Regression Unit Tests Completed     "
display as text "==========================================="
