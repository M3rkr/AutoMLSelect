*! version 2.1
program define preprocess_data
    // =========================================================================
    // preprocess_data.ado
    // =========================================================================
    //
    // Description:
    // Preprocesses the dataset by handling missing values, encoding categorical
    // variables, and performing other preprocessing steps as specified by the user.
    //
    // Syntax:
    // preprocess_data using "data.dta", ///
    //     target(target_variable) ///
    //     predictors(varlist) ///
    //     [ handle_missing(mean|median|mode) ///
    //       encode_onehot ///
    //       scale_variables ]
    //
    // Options:
    //   handle_missing(method) - Method to handle missing values: mean, median, or mode.
    //   encode_onehot          - Perform one-hot encoding on categorical variables.
    //   scale_variables        - Standardize or normalize numeric variables.
    //
    // Example:
    // preprocess_data using "data.dta", ///
    //     target(Price) ///
    //     predictors(Size Bedrooms Age Location) ///
    //     handle_missing(mean mode) ///
    //     encode_onehot
    //
    // =========================================================================

    version 16.0
    syntax using/ , ///
        target(string) ///
        predictors(string) ///
        [ handle_missing(string) ///
          encode_onehot ///
          scale_variables ]

    // -------------------------------------------------------------------------
    // 1. Load Data
    // -------------------------------------------------------------------------
    display "Loading data from `using'..."
    use "`using'", clear

    // -------------------------------------------------------------------------
    // 2. Handle Missing Values
    // -------------------------------------------------------------------------
    if "`handle_missing'" != "" {
        display "Handling missing values using `handle_missing' method(s)..."
        tokenize "`handle_missing'"
        local methods_list
        while "`1'" != "" {
            local methods_list `methods_list' `1'
            macro shift
        }

        foreach method of local methods_list {
            if "`method'" == "mean" {
                foreach var of varlist `predictors' {
                    // Check if variable is numeric
                    quietly describe `var'
                    if inlist(r(type), "float", "double", "byte", "int", "long") {
                        quietly summarize `var', meanonly
                        replace `var' = r(mean) if missing(`var')
                    }
                    else {
                        display as warning "Variable `var' is not numeric. Skipping 'mean' imputation."
                    }
                }
            }
            else if "`method'" == "median" {
                foreach var of varlist `predictors' {
                    // Check if variable is numeric
                    quietly describe `var'
                    if inlist(r(type), "float", "double", "byte", "int", "long") {
                        quietly centile `var', centile(50) nodrop
                        replace `var' = r(c_1) if missing(`var')
                    }
                    else {
                        display as warning "Variable `var' is not numeric. Skipping 'median' imputation."
                    }
                }
            }
            else if "`method'" == "mode" {
                foreach var of varlist `predictors' {
                    // Mode can be applied to both numeric and string variables
                    quietly tabulate `var', missing
                    if r(N) > 0 {
                        local mode_val = r(max)
                        replace `var' = "`mode_val'" if missing(`var')
                    }
                    else {
                        display as warning "Cannot determine mode for variable `var'."
                    }
                }
            }
            else {
                display as error "Invalid missing value handling method: `method'"
                exit 198
            }
        }
    }

    // -------------------------------------------------------------------------
    // 3. Encode Categorical Variables
    // -------------------------------------------------------------------------
    if "`encode_onehot'" != "" {
        display "Performing one-hot encoding on categorical variables..."
        foreach var of varlist `predictors' {
            // Check if the variable is string (categorical)
            quietly describe `var'
            if inlist(r(type), "str1", "str2", "str3", "str4", "str5", "str6", "str7", "str8", "str9", "str10", ///
                      "str11", "str12", "str13", "str14", "str15", "str16", "str17", "str18", "str19", "str20") {
                encode `var', gen(`var'_encoded) replace
                quietly tabulate `var'_encoded, generate(`var'_dummy)
                drop `var'_encoded
                drop `var'
                // Rename dummy variables appropriately
                foreach dummy_var of varlist `var'_dummy* {
                    local new_name = "`var'_`=substr("`dummy_var'", strpos("`dummy_var'", "_dummy") + 6, .)"
                    rename `dummy_var' `new_name'
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. Scale Variables
    // -------------------------------------------------------------------------
    if "`scale_variables'" != "" {
        display "Scaling numeric variables..."
        foreach var of varlist `predictors' {
            // Check if variable is numeric
            quietly describe `var'
            if inlist(r(type), "float", "double", "byte", "int", "long") {
                quietly summarize `var', meanonly
                generate double `var'_scaled = (`var' - r(mean)) / r(sd)
                drop `var'
                rename `var'_scaled `var'
            }
            else {
                display as warning "Variable `var' is not numeric. Skipping scaling."
            }
        }
    }

    // -------------------------------------------------------------------------
    // 5. Save Preprocessed Data
    // -------------------------------------------------------------------------
    tempfile preprocessed_data
    save "`preprocessed_data'", replace
    display "Data preprocessing completed. Preprocessed data saved."
end
