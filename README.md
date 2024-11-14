# AutoMLSelect

**AutoMLSelect** is a comprehensive Stata package designed to automate the machine learning workflow, including data preprocessing, model training, performance evaluation, and model selection for both regression and classification tasks. This package streamlines the process of building and selecting the best-performing models, making advanced machine learning techniques accessible directly within the Stata environment.

## Features

- **Data Preprocessing:** Handles missing values, encodes categorical variables, and scales numeric features.
- **Model Training:** Supports Linear Regression, Logistic Regression, and Random Forest models.
  - **Performance Evaluation:** Calculates metrics like RMSE, R-squared for regression; Accuracy, Precision, Recall, F1-Score, AUC for classification.
  - **Model Selection:** Automatically selects the best-performing model based on user-defined criteria.
  - **Ease of Use:** Simple syntax and comprehensive documentation facilitate quick adoption.
  - **Unit Testing:** Includes robust unit tests to ensure reliability and correctness of functionalities.

## Table of Contents

-[Installation](#installation)
-[Usage](#usage)
-[Generating Sample Datasets](#generating-sample-datasets)
-[Running AutoMLSelect](#running-automlselect)
-[Documentation](#documentation)
-[Examples](#examples)
-[Contributing](#contributing)
-[License](#license)

## Installation

### Prerequisites

Before installing **AutoMLSelect**, ensure that your system meets the following requirements:

- **Stata Version:** 16.0 or later.- **Operating System:** Compatible with Windows, macOS, and Linux versions supported by Stata.

  - **Dependencies:**
  - [`roctab`](https://ideas.repec.org/s/boc/bocode.html#roctab)
  - [`randomforest`](https://ideas.repec.org/s/boc/bocode.html#randomforest)
  - [`pca`](https://ideas.repec.org/s/boc/bocode.html#pca) *(Optional)*
  - [`csvtools`](https://ideas.repec.org/s/boc/bocode.html#csvtools) *(Optional)*

  ### Steps to Install


  1. **Clone the Repository:**

     Open your terminal or command prompt and execute the following commands:

     ```bash
     git clone https://github.com/M3rkr/AutoMLSelect.git  
     cd AutoMLSelect
     ```
  2. **Add the Ado-directory to Stata's Ado-path:**

     Launch Stata and execute:

     ```stata
     adopath + "path_to_AutoMLSelect/ado/"
     ```

     Replace `path_to_AutoMLSelect` with the actual path to the cloned repository on your system.
  3. **Install Required Dependencies:**

     In Stata, run the following commands to install necessary dependencies:

     ```stata
     ssc install roctab, replace 
     ssc install randomforest, replace 
     ssc install pca, replace
     ssc install csvtools, replace
     ```

     **Note:** The `pca` and `csvtools` packages are optional and should be installed only if you plan to use PCA-based preprocessing or advanced CSV      manipulation features, respectively.
  4. **Verify Installation:**

In Stata, check if the main command is recognized:

```stata
which automlselect
```

**Expected Output:**
```c:\path_to_AutoMLSelect\ado\automlselect.ado```

## Usage

### Generating Sample Datasets

Before utilizing the **AutoMLSelect** package, it's recommended to generate sample datasets for both regression and classification tasks. This helps in understanding the package's functionalities and ensures that everything is set up correctly.

1. **Navigate to the `tests/` Directory:**

In your terminal or command prompt:

```bash
cd AutoMLSelect/tests
```

2. **Run the Sample Data Generation Do-file:**
   Launch Stata and execute:

```stata
do generate_sample_datasets.do
```

**Outcome:**

- **Regression Dataset:** `data/sample_regression_data.dta`
- **Classification Dataset:** `data/sample_classification_data.dta`

### Running AutoMLSelect

With the sample datasets in place, you can now run the **AutoMLSelect** workflow.

1. **Navigate to the `examples/` Directory:**

   ```bash
   cd AutoMLSelect/examples
   ```
2. **Run an Example Do-file:**

```
For instance, to run the regression example:

```stata
do regression_example.do
```

**OR**
For the classification example:

```stata
do classification_example.do
```

**Note:** These example scripts demonstrate how to use the **AutoMLSelect** package for different machine learning tasks. They utilize the sample datasets generated earlier.

## Documentation

Comprehensive documentation is available to guide you through the installation, usage, and advanced functionalities of the **AutoMLSelect** package.

- **User Manual:** Detailed instructions and explanations can be found in `doc/UserManual.md`.
- **Help Files:** Each ado-file has an associated help file accessible via Stata's help system. For example:

  ```stata
  help automlselect
  ```

## Examples

The `examples/` directory contains do-files that demonstrate how to use the **AutoMLSelect** package for both regression and classification tasks.

- **Regression Example:**

  ```stata
  do regression_example.do
  ```
- **Classification Example:**

  ```stata
  do classification_example.do
  ```

These scripts showcase the end-to-end workflow, from data preprocessing to model selection.

## Contributing

Contributions are welcome! If you'd like to contribute to the **AutoMLSelect** package, please follow these guidelines:

1. **Fork the Repository:**

   Click the "Fork" button at the top-right corner of the repository page on GitHub.
2. **Create a New Branch:**

   ```bash
   git checkout -b feature/YourFeatureName
   ```
3. **Make Your Changes:**

   Implement your feature or bug fix.
4. **Commit Your Changes:**

   ```bash
   git commit -m "Add feature: YourFeatureName"
   ```
5. **Push to the Branch:**

   ```bash
   git push origin feature/YourFeatureName
   ```
6. **Create a Pull Request:**

Navigate to the original repository and create a pull request from your forked branch.

**Please ensure that your contributions adhere to the project's coding standards and include relevant tests and documentation.**

## License

This project is licensed under the [MIT License](LICENSE).
