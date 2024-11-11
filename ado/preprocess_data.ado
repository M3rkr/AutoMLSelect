*! version 1.0
program define preprocess_data
    // =========================================================================
    // preprocess_data.ado
    // =========================================================================
    //
    // Description:
    // This function imports a CSV file, handles missing values by imputing
    // with the mean for numeric variables and the mode for categorical variables,
    // and encodes categorical variables using one-hot encoding (dummy variables).
    //
    // Syntax:
    // preprocess_data using "data.csv"
    //
    // Example:
    // . preprocess_data using "sample_data.csv"
    //
    // =========================================================================

    version 16.0
    syntax using/ [if] [in], ///
        // No additional options for simplicity; can be extended as needed

    // -------------------------------------------------------------------------
    // 1. Check if the input file exists
    // -------------------------------------------------------------------------
    local filepath "`using'"

    if "`filepath'" == "" {
        display as error "Error: No input file specified."
        exit 198
    }

    if !fileexists("`filepath'") {
        display as error "Error: The file `filepath' does not exist."
        exit 198
    }

    // -------------------------------------------------------------------------
    // 2. Import the CSV file
    // -------------------------------------------------------------------------
    display "Importing data from `filepath'..."
    import delimited using "`filepath'", clear varnames(1) encoding(UTF8)
    
    // -------------------------------------------------------------------------
    // 3. Identify Variable Types
    //    - Categorical Variables: String variables
    //    - Numeric Variables: Numeric variables
    // -------------------------------------------------------------------------
    display "Identifying variable types..."

    // Identify string variables (categorical)
    ds, has(type string)
    local categorical_vars `r(varlist)'

    // Identify numeric variables
    ds, has(type numeric)
    local numeric_vars `r(varlist)'

    // Display identified variables
    display "Categorical Variables: `categorical_vars'"
    display "Numeric Variables: `numeric_vars'"

    // -------------------------------------------------------------------------
    // 4. Handle Missing Values for Numeric Variables
    // -------------------------------------------------------------------------
    if "`numeric_vars'" != "" {
        display "Handling missing values for numeric variables by imputing with mean..."

        foreach var of varlist `numeric_vars' {
            // Calculate mean excluding missing values
            quietly summarize `var', meanonly
            local mean = r(mean)

            // Check if the variable has any missing values
            qui count if missing(`var')
            if r(N) > 0 {
                // Replace missing values with mean
                replace `var' = `mean' if missing(`var')
                display "Imputed missing values in numeric variable `var' with mean (`mean')."
            }
            else {
                display "No missing values found in numeric variable `var'."
            }
        }
    }
    else {
        display "No numeric variables found to impute."
    }

    // -------------------------------------------------------------------------
    // 5. Handle Missing Values for Categorical Variables
    // -------------------------------------------------------------------------
    if "`categorical_vars'" != "" {
        display "Handling missing values for categorical variables by imputing with mode..."

        foreach var of varlist `categorical_vars' {
            // Check if the variable has any missing values
            qui count if missing(`var')
            if r(N) > 0 {
                // Calculate mode (most frequent category)
                qui tabulate `var', missing nofreq
                // Extract the mode using r(max)
                qui egen mode_`var' = mode(`var')

                // Retrieve the mode value
                local mode = mode_`var'[1]

                // Replace missing values with mode
                replace `var' = "`mode'" if missing(`var')
                drop mode_`var'

                display "Imputed missing values in categorical variable `var' with mode (`mode')."
            }
            else {
                display "No missing values found in categorical variable `var'."
            }
        }
    }
    else {
        display "No categorical variables found to impute."
    }

    // -------------------------------------------------------------------------
    // 6. One-Hot Encode Categorical Variables
    // -------------------------------------------------------------------------
    if "`categorical_vars'" != "" {
        display "Encoding categorical variables using one-hot encoding..."

        foreach var of varlist `categorical_vars' {
            display "Encoding variable `var'..."

            // Get the unique levels of the categorical variable
            qui levelsof `var', local(levels)

            // Loop through each level to create dummy variables
            foreach lvl of local levels {
                // Clean the level name to create a valid variable name
                local lvl_clean = subinstr("`lvl'", " ", "_", .)  // Replace spaces with underscores
                local lvl_clean = subinstr("`lvl_clean'", "-", "_", .) // Replace hyphens with underscores
                local lvl_clean = lower("`lvl_clean'") // Convert to lowercase

                // Define the dummy variable name
                local dummy = "`var'_`lvl_clean'"

                // Check if the dummy variable already exists to avoid duplication
                cap confirm variable `dummy'
                if _rc == 0 {
                    display "Dummy variable `dummy' already exists. Skipping creation."
                }
                else {
                    // Generate the dummy variable
                    generate byte `dummy' = (`var' == "`lvl'") if !missing(`var')
                    replace `dummy' = 0 if missing(`dummy')
                    label variable `dummy' "Dummy for `var' == `lvl'"
                    display "Created dummy variable `dummy'."
                }
            }

            // Optionally, drop the original categorical variable after encoding
            // Uncomment the following line if you wish to drop the original variable
            // drop `var'
        }
    }
    else {
        display "No categorical variables found to encode."
    }

    display "Preprocessing completed successfully."

end
