* classification_example.do
* ==========================
* Example of using AutoMLSelect for Classification Task
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.3

clear all
set more off

* Load Sample Classification Data
use "data/sample_classification_data.dta", clear

* Run AutoMLSelect for Classification
automlselect classification, ///
    target("Purchase") ///
    predictors("Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west") ///
    num_trees(200) ///
    mtry(4) ///
    max_depth(10) ///
    save_model("models/classification_model") ///
    save_metrics("metrics/classification_metrics.csv")
