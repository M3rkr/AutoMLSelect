*! Version 1.0.0 15 Nov 2024
title: "AutoMLSelect Help"
author: "Your Name"
version: "1.0.0"
category: "Machine Learning"

description:
    "AutoMLSelect automates the selection and execution of regression or classification models based on user input. It handles data input, model selection, evaluation, and output generation, providing a streamlined workflow for data analysis."

syntax:
    automlselect, ///
        Filepath(string) ///
        NumCols(string) ///
        CatCols(string) ///
        Target(string) ///
        Task(string) ///
        OutputPaths(string)

options:
    Filepath(string)
        - Description: Path to the dataset file in Stata `.dta` format.
        - Example: `"data/sample_regression_data.dta"`

    NumCols(string)
        - Description: List of columns containing numerical variables to be used in the model. Separate multiple columns with spaces.
        - Example: `"Size Bedrooms Age Price"`

    CatCols(string)
        - Description: List of columns containing categorical variables to be included in the model. Separate multiple columns with spaces.
        - Example: `"Location"`

    Target(string)
        - Description: The column representing the dependent variable (i.e., the variable to be predicted).
        - Example: `"Price"`

    Task(string)
        - Description: The type of analysis to be performed.
            - `"regression"` for predicting a continuous variable (Linear Regression or Box-Cox Regression).
            - `"classification"` for predicting a categorical variable (Logistic Regression or Linear Regression Approach).
        - Example: `"regression"`

    OutputPaths(string)
        - Description: Locations where the results of the best-performing model should be saved. Multiple paths can be specified separated by spaces.
        - Example: `"results/predictions.xlsx results/model_coefficients.xlsx"`

examples:
    // Regression Example
    . automlselect ///
        , Filepath("data/sample_regression_data.dta") ///
          NumCols("Size Bedrooms Age") ///
          CatCols("Location") ///
          Target("Price") ///
          Task("regression") ///
          OutputPaths("results/regression_predictions.xlsx results/regression_coefficients.xlsx")

    // Classification Example
    . automlselect ///
        , Filepath("data/sample_classification_data.dta") ///
          NumCols("Age Income") ///
          CatCols("Gender Region") ///
          Target("Purchase") ///
          Task("classification") ///
          OutputPaths("results/classification_predictions.xlsx results/classification_metrics.xlsx")

notes:
    - Ensure that the dataset is pre-cleaned by the user, i.e., no missing values and correct data types.
    - Categorical variables will be automatically encoded within the package.
    - For classification tasks, the target variable must be binary.

output:
    - Predictions made by the best model saved to the specified output paths.
    - Model coefficients and evaluation metrics saved to the specified output paths.
    - Best model and its performance metric displayed in the Stata output window.

troubleshooting:
    - **Error: Invalid Task Type**
        - Ensure that the `Task` parameter is either `"regression"` or `"classification"`.

    - **Error: Failed to load dataset**
        - Verify that the `Filepath` is correct and the file exists.

    - **Error: Numerical/Categorical column does not exist**
        - Check that the specified columns exist in the dataset and are of the correct type.

    - **Error: Target variable must be binary (for classification)**
        - Ensure that the target variable for classification has exactly two categories.

contact:
    "For further assistance, contact [your.email@example.com]."

