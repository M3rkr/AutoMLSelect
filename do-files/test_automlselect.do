*! version 2.3
* test_automlselect.do
* ======================
* Unit Tests for AutoMLSelect Package
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.3

clear all
set more off

*-----------------------------------------------------------
* Define Base Directory
*-----------------------------------------------------------
* Replace the path below with your actual package directory
local base_path "D:/AutoMLSelect"  // Adjust as needed

*-----------------------------------------------------------
* Create Necessary Directories if They Don't Exist
*-----------------------------------------------------------
display as text "Creating necessary directories..."
cap mkdir "`base_path'/models"
cap mkdir "`base_path'/metrics"
cap mkdir "`base_path'/ado"
cap mkdir "`base_path'/do-files"
display as text "Directories are set up."

*-----------------------------------------------------------
* Test Case 1: Train Linear Regression Model for Regression Task
*-----------------------------------------------------------
display as text "Running Test Case 1: Train Linear Regression Model for Regression Task"

* Load Regression Dataset
use "`base_path'/data/sample_regression_data.dta", clear
if (_rc != 0) {
    display as error "Test Case 1 Failed: Could not load sample_regression_data.dta."
    exit 198
}

cd "`base_path'/ado"

* Train Linear Regression Model
train_linear_regression, ///
    target("Price") ///
    predictors("Size Bedrooms Age Location_east Location_north Location_south Location_west") ///
    robust ///
    save("`base_path'/models/linear_regression_model_regression.ster")

* Check if Linear Regression Model for Regression Task is saved
capture confirm file "`base_path'/models/linear_regression_model_regression.ster"
if (_rc != 0) {
    display as error "Test Case 1 Failed: Linear Regression model for Regression Task not saved."
    exit 198
}

display as text "Test Case 1 Passed: Linear Regression model for Regression Task trained and saved."

*-----------------------------------------------------------
* Test Case 2: Train Logistic Regression Model for Regression Task
*-----------------------------------------------------------
display as text "Running Test Case 2: Train Logistic Regression Model for Regression Task"

* Ensure Regression Dataset is Loaded
if "`c(filename)'" != "`base_path'/data/sample_regression_data.dta'" {
    use "`base_path'/data/sample_regression_data.dta", clear
    if (_rc != 0) {
        display as error "Test Case 2 Failed: Could not load sample_regression_data.dta."
        exit 198
    }
}

* Train Logistic Regression Model for Regression Task
train_logistic_regression, ///
    target("Price") ///
    predictors("Size Bedrooms Age Location_east Location_north Location_south Location_west") ///
    robust ///
    save("`base_path'/models/logistic_regression_model_regression.ster")

* Check if Logistic Regression Model for Regression Task is saved
capture confirm file "`base_path'/models/logistic_regression_model_regression.ster"
if (_rc != 0) {
    display as error "Test Case 2 Failed: Logistic Regression model for Regression Task not saved."
    exit 198
}

display as text "Test Case 2 Passed: Logistic Regression model for Regression Task trained and saved."

*-----------------------------------------------------------
* Test Case 3: Train Logistic Regression Model for Classification Task
*-----------------------------------------------------------
display as text "Running Test Case 3: Train Logistic Regression Model for Classification Task"

* Load Classification Dataset
use "`base_path'/data/sample_classification_data.dta", clear
if (_rc != 0) {
    display as error "Test Case 3 Failed: Could not load sample_classification_data.dta."
    exit 198
}

* Train Logistic Regression Model for Classification Task
train_logistic_regression, ///
    target("Purchase") ///
    predictors("Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west") ///
    robust ///
    save("`base_path'/models/logistic_regression_model_classification.ster")

* Check if Logistic Regression Model for Classification Task is saved
capture confirm file "`base_path'/models/logistic_regression_model_classification.ster"
if (_rc != 0) {
    display as error "Test Case 3 Failed: Logistic Regression model for Classification Task not saved."
    exit 198
}

display as text "Test Case 3 Passed: Logistic Regression model for Classification Task trained and saved."

*-----------------------------------------------------------
* Test Case 4: Train Linear Regression Model for Classification Task
*-----------------------------------------------------------
display as text "Running Test Case 4: Train Linear Regression Model for Classification Task"

* Ensure Classification Dataset is Loaded
if "`c(filename)'" != "`base_path'/data/sample_classification_data.dta'" {
    use "`base_path'/data/sample_classification_data.dta", clear
    if (_rc != 0) {
        display as error "Test Case 4 Failed: Could not load sample_classification_data.dta."
        exit 198
    }
}

* Train Linear Regression Model for Classification Task
train_linear_regression, ///
    target("Purchase") ///
    predictors("Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west") ///
    robust ///
    save("`base_path'/models/linear_regression_model_classification.ster")

* Check if Linear Regression Model for Classification Task is saved
capture confirm file "`base_path'/models/linear_regression_model_classification.ster"
if (_rc != 0) {
    display as error "Test Case 4 Failed: Linear Regression model for Classification Task not saved."
    exit 198
}

display as text "Test Case 4 Passed: Linear Regression model for Classification Task trained and saved."

*-----------------------------------------------------------
* Test Case 5: Evaluate All Trained Models
*-----------------------------------------------------------
display as text "Running Test Case 5: Evaluate All Trained Models"

* Evaluate Regression Models
evaluate_regression, ///
    target("Price") ///
    prediction("Price_pred") ///
    save_metrics("`base_path'/metrics/regression_metrics.csv")

* Evaluate Classification Models
evaluate_classification, ///
    target("Purchase") ///
    prediction("Purchase_pred") ///
    probability("Purchase_prob") ///
    save_metrics("`base_path'/metrics/classification_metrics.csv")

* Check if Metrics Files are Saved
capture confirm file "`base_path'/metrics/regression_metrics.csv"
if (_rc != 0) {
    display as error "Test Case 5 Failed: Regression metrics not saved."
    exit 198
}

capture confirm file "`base_path'/metrics/classification_metrics.csv"
if (_rc != 0) {
    display as error "Test Case 5 Failed: Classification metrics not saved."
    exit 198
}

display as text "Test Case 5 Passed: All models evaluated and metrics saved."

*-----------------------------------------------------------
* Test Case 6: Select Best Regression Model
*-----------------------------------------------------------
display as text "Running Test Case 6: Select Best Regression Model"

select_best_model, ///
    using("`base_path'/metrics/regression_metrics.csv") ///
    task(regression) ///
    metric("RMSE") ///
    direction(minimize) ///
    save_results("`base_path'/metrics/best_regression_model.csv")

* Check if Best Regression Model is Saved
capture confirm file "`base_path'/metrics/best_regression_model.csv"
if (_rc != 0) {
    display as error "Test Case 6 Failed: Best Regression Model not saved."
    exit 198
}

display as text "Test Case 6 Passed: Best Regression Model selected and saved."

*-----------------------------------------------------------
* Test Case 7: Select Best Classification Model
*-----------------------------------------------------------
display as text "Running Test Case 7: Select Best Classification Model"

select_best_model, ///
    using("`base_path'/metrics/classification_metrics.csv") ///
    task(classification) ///
    metric("AUC") ///
    direction(maximize) ///
    save_results("`base_path'/metrics/best_classification_model.csv")

* Check if Best Classification Model is Saved
capture confirm file "`base_path'/metrics/best_classification_model.csv"
if (_rc != 0) {
    display as error "Test Case 7 Failed: Best Classification Model not saved."
    exit 198
}

display as text "Test Case 7 Passed: Best Classification Model selected and saved."

*-----------------------------------------------------------
* Summary of Tests
*-----------------------------------------------------------
display as text "==========================================="
display as text "       AutoMLSelect Unit Tests Completed    "
display as text "==========================================="
