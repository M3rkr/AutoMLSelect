*! version 1.0
program define automlselect_utils_check_dependencies
    // =========================================================================
    // automlselect_utils_check_dependencies.ado
    // =========================================================================
    //
    // Description:
    // Checks if the required user-contributed packages are installed. If not, it
    // attempts to install them automatically. Currently, it checks for the 'randomforest' package.
    //
    // Syntax:
    // automlselect_utils_check_dependencies
    //
    // Example:
    // . automlselect_utils_check_dependencies
    //
    // =========================================================================

    version 16.0
    // List of required packages
    local required_packages "randomforest"

    foreach pkg of local required_packages {
        capture which `pkg'
        if _rc != 0 {
            display as warning "The '`pkg'' package is not installed. Attempting to install..."
            ssc install `pkg', replace
            if _rc != 0 {
                display as error "Error: Failed to install the '`pkg'' package. Please install it manually."
                exit 198
            }
            else {
                display as result "Successfully installed the '`pkg'' package."
            }
        }
        else {
            display as result "The '`pkg'' package is already installed."
        }
    }

    display as result "All required dependencies are satisfied."

end

program define automlselect_utils_log
    // =========================================================================
    // automlselect_utils_log.ado
    // =========================================================================
    //
    // Description:
    // Logs messages to a specified log file. Useful for tracking the workflow and
    // debugging purposes within the AutoMLSelect package.
    //
    // Syntax:
    // automlselect_utils_log "message", [level(info|warning|error)]
    //
    // Options:
    //   level(info|warning|error)
    //       Specifies the severity level of the log message. Defaults to 'info'.
    //
    // Example:
    // . automlselect_utils_log "Starting model training" , level(info)
    //
    // =========================================================================

    version 16.0
    syntax varname(min=1 max=1) [ , level(string) ]

    // Retrieve the message
    local message "`1'"

    // Retrieve the level, default to 'info'
    if "`level'" == "" {
        local level "info"
    }
    else {
        local level "`level'"
    }

    // Define the log file path
    // You can customize the log file location as needed
    local log_file "automlselect.log"

    // Open the log file in append mode
    capture file open log_handle using "`log_file'", write append
    if _rc != 0 {
        display as error "Error: Unable to open log file '`log_file''."
        exit 198
    }

    // Get the current timestamp
    local timestamp = c(current_date) + " " + c(current_time)

    // Write the log entry
    file write log_handle "`timestamp' [`level'] " + `"`message'"' + _n

    // Close the log file
    file close log_handle

    // Optionally, display the log message in Stata's Results window
    if "`level'" == "error" {
        display as error "`message'"
    }
    else if "`level'" == "warning" {
        display as warning "`message'"
    }
    else {
        display as text "`message'"
    }

end

program define automlselect_utils_save_model
    // =========================================================================
    // automlselect_utils_save_model.ado
    // =========================================================================
    //
    // Description:
    // Saves the estimates of a trained model to a specified file. This is useful
    // for persisting model results for later evaluation or deployment.
    //
    // Syntax:
    // automlselect_utils_save_model, ///
    //     model_name(string) ///
    //     save_path(string)
    //
    // Options:
    //   model_name(string)
    //       The name of the stored estimates to save (as stored using 'estimates store').
    //
    //   save_path(string)
    //       The file path where the model estimates will be saved. The file extension
    //       should be '.ster'.
    //
    // Example:
    // . automlselect_utils_save_model, ///
    //       model_name(linear_regression_model) ///
    //       save_path("models/lm_income.ster")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        model_name(string) ///
        save_path(string)

    // Check if the model exists in stored estimates
    capture estimates dir
    local stored_models `r(estimates)'

    if strpos("`stored_models'", "`model_name'") == 0 {
        display as error "Error: Model '`model_name'' does not exist in stored estimates."
        exit 198
    }

    // Save the estimates
    estimates save "`save_path'", replace
    if _rc == 0 {
        display as result "Model '`model_name'' saved successfully to '`save_path''."
    }
    else {
        display as error "Error: Failed to save model '`model_name'' to '`save_path''."
    }

end

program define automlselect_utils_load_model
    // =========================================================================
    // automlselect_utils_load_model.ado
    // =========================================================================
    //
    // Description:
    // Loads previously saved model estimates from a specified file. This allows
    // for reusing models without retraining.
    //
    // Syntax:
    // automlselect_utils_load_model, ///
    //     load_path(string)
    //
    // Options:
    //   load_path(string)
    //       The file path from which the model estimates will be loaded. The file
    //       extension should be '.ster'.
    //
    // Example:
    // . automlselect_utils_load_model, ///
    //       load_path("models/lm_income.ster")
    //
    // =========================================================================

    version 16.0
    syntax , ///
        load_path(string)

    // Check if the file exists
    if !fileexists("`load_path'") {
        display as error "Error: The file '`load_path'' does not exist."
        exit 198
    }

    // Load the estimates
    estimates use "`load_path'", clear
    if _rc == 0 {
        display as result "Model estimates loaded successfully from '`load_path''."
    }
    else {
        display as error "Error: Failed to load model estimates from '`load_path''."
    }

end

program define automlselect_utils_generate_predictions
    // =========================================================================
    // automlselect_utils_generate_predictions.ado
    // =========================================================================
    //
    // Description:
    // Generates predictions from a trained model and adds them as a new variable
    // in the dataset. Supports both regression and classification models.
    //
    // Syntax:
    // automlselect_utils_generate_predictions, ///
    //     model_name(string) ///
    //     prediction_var(string)
    //
    // Options:
    //   model_name(string)
    //       The name of the stored estimates to use for generating predictions.
    //
    //   prediction_var(string)
    //       The name of the new variable that will store the predictions.
    //
    // Example:
    // . automlselect_utils_generate_predictions, ///
    //       model_name(linear_regression_model) ///
    //       prediction_var(predicted_income)
    //
    // =========================================================================

    version 16.0
    syntax , ///
        model_name(string) ///
        prediction_var(string)

    // Check if the model exists in stored estimates
    capture estimates dir
    local stored_models `r(estimates)'

    if strpos("`stored_models'", "`model_name'") == 0 {
        display as error "Error: Model '`model_name'' does not exist in stored estimates."
        exit 198
    }

    // Retrieve the model type
    estimates describe `model_name'
    local model_type = r(command)

    // Check if the model is regression or logistic
    if inlist("`model_type'", "regress", "logit") {
        // Generate predictions
        predict double `prediction_var' if e(sample), xb
        if _rc == 0 {
            display as result "Predictions generated and stored in variable '`prediction_var''."
        }
        else {
            display as error "Error: Failed to generate predictions."
        }
    }
    else if "`model_type'" == "randomforest" {
        // Assuming Random Forest models have a predict command or similar
        // Adjust based on the actual implementation of the Random Forest package
        predict double `prediction_var' if e(sample), pr
        if _rc == 0 {
            display as result "Predictions generated and stored in variable '`prediction_var''."
        }
        else {
            display as error "Error: Failed to generate predictions for Random Forest model."
        }
    }
    else {
        display as error "Error: Unsupported model type '`model_type'' for prediction generation."
        exit 198
    }

end

program define automlselect_utils_validate_metrics_file
    // =========================================================================
    // automlselect_utils_validate_metrics_file.ado
    // =========================================================================
    //
    // Description:
    // Validates the structure of the metrics CSV file to ensure it contains the
    // necessary columns for model selection.
    //
    // Syntax:
    // automlselect_utils_validate_metrics_file, ///
    //     file_path(string) ///
    //     task(string)
    //
    // Options:
    //   file_path(string)
    //       The path to the metrics CSV file to validate.
    //
    //   task(string)
    //       The type of task: "regression" or "classification". This determines
    //       which metrics are expected in the file.
    //
    // Example:
    // . automlselect_utils_validate_metrics_file, ///
    //       file_path("model_metrics.csv") ///
    //       task(regression)
    //
    // =========================================================================

    version 16.0
    syntax , ///
        file_path(string) ///
        task(string)

    // Check if the file exists
    if !fileexists("`file_path'") {
        display as error "Error: The file '`file_path'' does not exist."
        exit 198
    }

    // Import the first row to get variable names
    import delimited using "`file_path'", clear varnames(1) encoding(UTF8) nrows(1)
    local varlist "`r(varlist)'"

    // Check for 'model' column
    if strpos("`varlist'", "model") == 0 {
        display as error "Error: The metrics file must contain a 'model' column identifying each model."
        exit 198
    }

    // Define expected metrics based on task
    if "`task'" == "regression" {
        local expected_metrics "RMSE R-squared MAE MAPE"
    }
    else if "`task'" == "classification" {
        local expected_metrics "Accuracy Precision Recall F1-Score AUC"
    }
    else {
        display as error "Error: Task must be either 'regression' or 'classification'."
        exit 198
    }

    // Check for presence of at least one expected metric
    local valid_metrics 0
    foreach metric of local expected_metrics {
        if strpos("`varlist'", "`metric'") {
            local valid_metrics = `valid_metrics' + 1
        }
    }

    if `valid_metrics' == 0 {
        display as error "Error: The metrics file does not contain any of the expected metrics for `task' task: `expected_metrics'"
        exit 198
    }
    else {
        display as result "Metrics file '`file_path'' validated successfully for `task' task."
    }

    // Clear the dataset
    clear

end

