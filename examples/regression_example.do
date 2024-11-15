* regression_example.do
* ======================
* Example of using AutoMLSelect for Regression Task
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.3

clear all
set more off

* Load Sample Regression Data
use "data/sample_regression_data.dta", clear

* Run AutoMLSelect for Regression
automlselect regression, ///
    target(Price) ///
    predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    num_trees(200) ///
    mtry(3) ///
    max_depth(10) ///
    save_model("models/regression_model") ///
    save_metrics("metrics/regression_metrics.csv")
