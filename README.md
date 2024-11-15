# AutoMLSelect

## Description

AutoMLSelect is a Stata package designed to automate the selection and execution of regression and classification models based on user-defined parameters. It streamlines the modeling process by handling data import, preprocessing, model training, evaluation, and output generation, making it easier for users to identify the best-performing models without extensive manual intervention.

## Features

- Automated data import from CSV, Excel, or Stata (.dta) formats.
- Handles missing values by imputing numerical variables with their mean and categorical variables with their mode.
- Supports both regression (Linear Regression, Box-Cox Regression) and classification (Logistic Regression, Linear Regression for Classification) tasks.
- Automatically selects the best-performing model based on relevant performance metrics (e.g., R² for regression, Accuracy for classification).
- Generates comprehensive outputs, including predictions, model coefficients, and evaluation metrics.
- Provides a user-friendly help file with detailed documentation and example usage.

## Installation

Follow these steps to install the AutoMLSelect package in Stata:

1. **Download the Package Files**
   
   - Ensure you have the following directory structure:
     
     ```
     AutoMLSelect/
     ├── ado/
     │   └── automlselect.ado
     ├── help/
     │   └── automlselect.sthlp
     └── examples/
         └── example_usage.do
     ```
2. **Place Files Appropriately**
   
   - Move `automlselect.ado` to the `ado/` folder.
   - Move `automlselect.sthlp` to the `help/` folder.
   - (Optional) Place `example_usage.do` in the `examples/` folder for reference.
3. **Update Stata’s ADO Path**
   
   If the package directory is not already in Stata's ADO path, add it using the following commands:
   
   ```stata
   sysdir set PLUS "path_to_AutoMLSelect/ado" 
   sysdir set HELP "path_to_AutoMLSelect/help"
   ```
   
   *Replace `path_to_AutoMLSelect` with the actual path to your AutoMLSelect directory.*
4. **Verify Installation**
   
   Open Stata and type `help automlselect` to ensure the help file is accessible.

## Usage

Use the `automlselect` command to perform automated model selection and evaluation. Below are the syntax and examples tailored to your sample datasets.

### Syntax

```stata
automlselect using(filepath), ///
    numcols("numerical_columns") ///
    catcols("categorical_columns") ///
    target("target_variable") ///
    task("regression" | "classification") ///
    outpath("output_directory")
```

### Parameters

- **using(filepath)**: Path to the dataset file. Supported formats include CSV, Excel (.xlsx, .xls), and Stata (.dta).
- **numcols(string)**: Comma-separated list of numerical columns to include in the model.
- **catcols(string)**: Comma-separated list of categorical columns to include in the model.
- **target(string)**: The dependent variable to predict.
- **task(string)**: Type of analysis to perform. Options are `"regression"` or `"classification"`.
- **outpath(string)**: Directory path where output files will be saved. The directory will be created if it does not exist.

**Command:**

```stata
automlselect using("data/sample_classification_data.dta"), ///
    numcols("Age,Income") ///
    catcols("Gender,Region") ///
    target("Purchase") ///
    task("classification") ///
    outpath("results/classification")
```

**Expected Outputs in `results/classification/`:

- `predictions.dta`: Contains actual and predicted `Purchase` values.
- `model_coefficients.txt`: Lists coefficients and standard errors of the selected classification model.
- `evaluation_metrics.dta`: Contains Accuracy, Precision, Recall, and F1-Score of the selected model.

## Outputs

The `automlselect` command generates the following outputs in the specified `outpath` directory:

### For Regression Tasks

- **predictions.dta**:
  
  - Contains two variables: the actual target (`Price`) and the predicted target (`prediction`).
- **model_coefficients.txt**:
  
  - A text file listing the coefficients and standard errors of the selected regression model.
- **evaluation_metrics.dta**:
  
  - Contains evaluation metrics such as R² (R-squared) and RMSE (Root Mean Squared Error) for the selected model.

### For Classification Tasks

- **predictions.dta**:
  
  - Contains two variables: the actual target (`Purchase`) and the predicted target (`final_prediction`).
- **model_coefficients.txt**:
  
  - A text file listing the coefficients and standard errors of the selected classification model.
- **evaluation_metrics.dta**:
  
  - Contains evaluation metrics such as Accuracy, Precision, Recall, and F1-Score for the selected model.

## Troubleshooting

If you encounter issues while using the AutoMLSelect package, consider the following tips:

### 1. Unsupported File Format

**Issue:** `Unsupported file format '.xyz'. Please provide CSV, Excel, or Stata (.dta) files.`

**Solution:** Ensure your data files are in one of the supported formats (`.dta`, `.csv`, `.xlsx`, etc.).

### 2. Missing Target Variable

**Issue:** `Variable 'Price' does not exist in the dataset.`

**Solution:** Verify that the target variable (`Price` or `Purchase`) is correctly named and exists in your dataset.

### 3. Invalid Task Type

**Issue:** `Invalid task type 'analysis'. Use 'regression' or 'classification'.`

**Solution:** Ensure that the `task` parameter is either `"regression"` or `"classification"`.

### 4. Non-Numeric Numerical Columns

**Issue:** `Variable 'Age' is not numeric.`

**Solution:** Confirm that all columns specified in `numcols` are numeric. Convert them if necessary using `encode` or appropriate data transformation commands.

### 5. Missing Columns

**Issue:** `Numerical variable 'Size' does not exist in the dataset.`

**Solution:** Check that all specified numerical and categorical columns are present in your dataset and correctly spelled.

## Extensibility

The AutoMLSelect package is designed to be easily extendable. Here’s how you can enhance its functionality:

### Adding New Models

1. **Implement the New Model:** Add the code for the new model within the `automlselect.ado` file as a separate program.
2. **Update Model Selection Logic:** Modify the model selection section to include performance metrics from the new model.
3. **Adjust Output Saving:** Update the `save_outputs` program if additional outputs are necessary for the new model.

### Enhancing Performance Metrics

- Incorporate more advanced metrics such as AUC for classification or Adjusted R² for regression.
- Allow users to specify which metrics to prioritize during model selection.

### Incorporating Cross-Validation

- Implement cross-validation techniques to provide more robust evaluation metrics.
- Allow users to specify the number of folds or the type of cross-validation.

## Contribution

Contributions to the AutoMLSelect package are welcome! If you have suggestions, bug reports, or enhancements, please open an issue or submit a pull request on the repository.

## License

AutoMLSelect is released under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Author

Your Name

Your Contact Information

## Acknowledgements

Special thanks to all contributors and users who help improve the AutoMLSelect package.

