*! version 1.0.0 15 Nov 2024
program define automlselect
    version 16.0
    syntax ///
        , Filepath(string) ///
          NumCols(string) ///
          CatCols(string) ///
          Target(string) ///
          Task(string) ///
          OutputPaths(string)

    // Validate Task Type
    if "`Task'" != "regression" & "`Task'" != "classification" {
        error 198
        di as error "Invalid Task Type: '`Task''. Must be 'regression' or 'classification'."
        exit 198
    }

    // Load Dataset
    capture use "`Filepath'", clear
    if _rc {
        error 198
        di as error "Failed to load dataset from '`Filepath''."
        exit 198
    }

    // Check Target Variable
    if "`Task'" == "regression" {
        // Ensure target is numeric
        capture confirm numeric variable `Target'
        if _rc {
            error 198
            di as error "For regression, the target variable '`Target'' must be numeric."
            exit 198
        }
    }
    else if "`Task'" == "classification" {
        // Ensure target is binary or categorical
        capture confirm variable `Target'
        if _rc {
            error 198
            di as error "Target variable '`Target'' does not exist in the dataset."
            exit 198
        }
        // Optionally, check if target is binary or categorical
    }

    // Parse Numerical Columns
    tokenize "`NumCols'"
    local num_list `0'
    foreach var of local num_list {
        capture confirm numeric variable `var'
        if _rc {
            error 198
            di as error "Numerical column '`var'' does not exist or is not numeric."
            exit 198
        }
    }

    // Parse Categorical Columns
    tokenize "`CatCols'"
    local cat_list `0'
    foreach var of local cat_list {
        capture confirm variable `var'
        if _rc {
            error 198
            di as error "Categorical column '`var'' does not exist."
            exit 198
        }
        // Ensure categorical variables are encoded
        capture encode `var', gen(_tmp_encoded_)
        if !_rc {
            // Replace original variable with encoded version
            drop `var'
            rename _tmp_encoded_ `var'
        }
    }

    // Model Selection and Evaluation
    // Split data into training and testing sets (e.g., 70-30 split)
    set seed 12345
    gen double _train = runiform() < 0.7
    preserve
    keep if _train
    tempfile train
    save "`train'", replace
    restore
    keep if _train
    drop _train
    tempfile test
    save "`test'", replace

    // Initialize variables to store best model info
    local best_model ""
    local best_metric = .

    if "`Task'" == "regression" {
        // 1. Linear Regression
        use "`train'", clear
        regress `Target' `num_list' `cat_list'
        // Get R-squared
        scalar r2_lr = e(r2)
        
        // Predict on test set
        use "`test'", clear
        predict double yhat_lr, xb
        // Calculate R-squared on test set
        sum `Target', meanonly
        scalar mean_y = r(mean)
        gen double ss_tot = (`Target' - mean_y)^2
        gen double ss_res_lr = (`Target' - yhat_lr)^2
        sum ss_tot ss_res_lr
        scalar r2_test_lr = 1 - (r(sum_ss_res_lr)/r(sum_ss_tot))
        
        // Store results
        local r2_lr = r2_test_lr

        // 2. Box-Cox Regression (if applicable)
        // Box-Cox requires positive target variable
        qui su `Target'
        if r(min) > 0 {
            boxcox `Target' `num_list' `cat_list', lags(0.1) iterate(100)
            // Note: Stata's boxcox command estimates the lambda parameter and fits the model
            // Get R-squared
            scalar r2_bc = e(r2)
            
            // Predict on test set
            use "`test'", clear
            boxcox `Target' `num_list' `cat_list', lags(0.1) iterate(100) predict(yhat_bc)
            // Calculate R-squared on test set
            sum `Target', meanonly
            scalar mean_y = r(mean)
            gen double ss_tot = (`Target' - mean_y)^2
            gen double ss_res_bc = (`Target' - yhat_bc)^2
            sum ss_tot ss_res_bc
            scalar r2_test_bc = 1 - (r(sum_ss_res_bc)/r(sum_ss_tot))
            
            // Compare R-squared
            if (r2_test_bc > r2_lr) {
                local best_model "Box-Cox Regression"
                local best_metric = r2_test_bc
            }
            else {
                local best_model "Linear Regression"
                local best_metric = r2_lr
            }
        }
        else {
            // Box-Cox not applicable
            local best_model "Linear Regression"
            local best_metric = r2_lr
        }

        // Fit the best model on the entire dataset
        use "`train'", clear
        if "`best_model'" == "Box-Cox Regression" {
            boxcox `Target' `num_list' `cat_list', lags(0.1) iterate(100)
            predict double yhat_final, xb
            // Note: Additional steps may be needed to inverse transform predictions
        }
        else {
            regress `Target' `num_list' `cat_list'
            predict double yhat_final, xb
        }

        // Evaluate on test set
        use "`test'", clear
        // Assuming predictions are already made
        // Save predictions and metrics
        gen double ss_tot = (`Target' - mean_y)^2
        gen double ss_res_final = (`Target' - yhat_final)^2
        sum ss_tot ss_res_final
        scalar r2_final = 1 - (r(sum_ss_res_final)/r(sum_ss_tot))

        // Prepare output
        // Save predictions
        export excel using "`word(OutputPaths)', sheet("Predictions") replace, firstrow(variables)
        // Save model coefficients
        estimates store final_model
        estimates table final_model, b(%9.3f) se(%9.3f) stars
        outsheet using "`word(OutputPaths)', replace
        // Save evaluation metrics
        di "Best Model: `best_model'"
        di "R-squared on Test Set: `best_metric'"
    }
    else if "`Task'" == "classification" {
        // Classification Task
        // Ensure target is binary
        qui tabulate `Target'
        if r(r) != 2 {
            error 198
            di as error "For classification, the target variable '`Target'' must be binary."
            exit 198
        }

        // 1. Logistic Regression
        use "`train'", clear
        logistic `Target' `num_list' `cat_list'
        // Predict probabilities
        predict double p_logistic, pr
        // Choose threshold 0.5
        gen byte yhat_logistic = p_logistic >= 0.5
        // Calculate accuracy
        use "`test'", clear
        merge 1:1 _n using "`train'"
        // Re-load test set
        use "`test'", clear
        predict double p_logistic_test, pr
        gen byte yhat_logistic_test = p_logistic_test >= 0.5
        qui tabulate `Target' yhat_logistic_test, matcell(freq_lr)
        matrix freq_lr = r(freq)
        scalar accuracy_lr = (freq_lr[1,1] + freq_lr[2,2]) / sum(freq_lr)

        // 2. Linear Regression Approach
        use "`train'", clear
        regress `Target' `num_list' `cat_list'
        predict double yhat_linear, xb
        gen byte yhat_linear_class = yhat_linear >= 0.5
        // Evaluate on test set
        use "`test'", clear
        predict double yhat_linear_test, xb
        gen byte yhat_linear_class_test = yhat_linear_test >= 0.5
        qui tabulate `Target' yhat_linear_class_test, matcell(freq_cls)
        matrix freq_cls = r(freq)
        scalar accuracy_linear = (freq_cls[1,1] + freq_cls[2,2]) / sum(freq_cls)

        // Compare accuracies
        if (accuracy_logistic > accuracy_linear) {
            local best_model "Logistic Regression"
            local best_metric = accuracy_logistic
        }
        else {
            local best_model "Linear Regression Approach"
            local best_metric = accuracy_linear
        }

        // Fit the best model on the entire dataset
        use "`train'", clear
        if "`best_model'" == "Logistic Regression" {
            logistic `Target' `num_list' `cat_list'
            predict double yhat_final, pr
            gen byte yhat_final_class = yhat_final >= 0.5
        }
        else {
            regress `Target' `num_list' `cat_list'
            predict double yhat_final, xb
            gen byte yhat_final_class = yhat_final >= 0.5
        }

        // Evaluate on test set
        use "`test'", clear
        if "`best_model'" == "Logistic Regression" {
            predict double yhat_final_test, pr
            gen byte yhat_final_class_test = yhat_final_test >= 0.5
        }
        else {
            predict double yhat_final_test, xb
            gen byte yhat_final_class_test = yhat_final_test >= 0.5
        }
        qui tabulate `Target' yhat_final_class_test, matcell(freq_final)
        matrix freq_final = r(freq)
        scalar accuracy_final = (freq_final[1,1] + freq_final[2,2]) / sum(freq_final)

        // Prepare output
        // Save predictions
        export excel using "`word(OutputPaths)', sheet("Predictions") replace, firstrow(variables)
        // Save model coefficients
        estimates store final_model
        estimates table final_model, b(%9.3f) se(%9.3f) stars
        outsheet using "`word(OutputPaths)', replace
        // Save evaluation metrics
        di "Best Model: `best_model'"
        di "Accuracy on Test Set: `best_metric'"
    }

    // Save outputs to specified paths
    // This section should be expanded based on the exact output requirements
    // For simplicity, using export excel as placeholder
    // Users can specify multiple output paths separated by spaces
    tokenize "`OutputPaths'"
    foreach path of local 0 {
        // Save predictions, coefficients, metrics as needed
        // Placeholder: already saved above
    }

    di as text "Model selection and evaluation completed successfully."
end
