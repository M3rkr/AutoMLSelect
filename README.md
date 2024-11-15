# AutoMLSelect

**AutoMLSelect** is a comprehensive Stata package designed to simplify the process of training, evaluating, and selecting machine learning models for both regression and classification tasks. By providing streamlined commands and functions, AutoMLSelect enables users to efficiently perform automated machine learning without delving deep into the intricacies of model tuning and evaluation.

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Usage](#usage)
   - [1. Preparing Your Data](#1-preparing-your-data)
   - [2. Running AutoMLSelect](#2-running-automlselect)
   - [3. Model Training and Evaluation](#3-model-training-and-evaluation)
4. [Examples](#examples)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)
7. [Contributing](#contributing)
8. [License](#license)

---

## Features

- **Model Training:** Train various regression and classification models with ease.
- **Random Forest Integration:** Incorporate Random Forest models alongside traditional regression and classification models.
- **Evaluation Metrics:** Automatically calculate and save relevant evaluation metrics.
- **Model Selection:** Select the best-performing model based on user-specified metrics.
- **Robust Error Handling:** Provides informative error messages to guide users.
- **Comprehensive Testing:** Includes unit tests to ensure package reliability.

## Installation

1. **Clone the Repository:**
   
   ```bash
   git clone https://github.com/yourusername/AutoMLSelect.git
   ```
2. **Set Up Ado-Files:**
   
   - Place all ado-files within the `ado/AutoMLSelect/` directory in Stata's personal ado-path.
   
   **Example Directory Structure:**
   
   ```
   C:\Users\YourName\ado\personal\AutoMLSelect\
   ```
3. **Install Dependencies:**
   
   **Random Forest Functionality:**
   
   AutoMLSelect now utilizes the [`rforest`](https://www.stata-journal.com/software/sj20-1/rforest/) package for Random Forest models. Install it using:
   
   ```stata
   ssc install rforest
   ```
   
   **Manual Installation (if needed):**
   
   If `ssc install rforest` does not work, follow these steps:
   
   1. **Download the Package:**
      
      - Visit the [Stata Journal](http://www.stata-journal.com/software/sj20-1/rforest/) to download the `rforest` package files.
   2. **Extract the Files:**
      
      - Extract the contents of the ZIP file to a temporary directory on your computer.
   3. **Locate Your Personal Ado-Path:**
      
      - In Stata, run:
        
        ```stata
        adopath
        ```
      - Identify your personal ado-directory (usually something like `C:\Users\YourName\ado\personal\`).
   4. **Move the Files:**
      
      - Copy the extracted `.ado` and `.hlp` files into the `personal` ado-directory identified earlier.
   5. **Verify Installation:**
      
      - In Stata, run:
        
        ```stata
        which rforest
        ```
      - Stata should display the path to the `rforest.ado` file, confirming a successful installation.
4. **Verify Installation:**
   
   Open Stata and run:
   
   ```stata
   which automlselect
   ```
   
   If installed correctly, Stata will display the path to the `automlselect.ado` file.

## Usage

### 1. Preparing Your Data

**Important:** Before utilizing **AutoMLSelect**, ensure that your dataset is **clean** and **properly formatted**. This includes:

- **Handling Missing Values:** Remove or impute missing data as appropriate.
- **Encoding Categorical Variables:** Convert categorical variables to a suitable format (e.g., one-hot encoding).
- **Scaling Numerical Variables:** Standardize or normalize numerical features if necessary.

**Note:** AutoMLSelect **assumes that the data provided is already clean**. Preprocessing steps must be performed manually or using your preferred methods.

### 2. Running AutoMLSelect

Once your data is prepared, you can proceed to train and evaluate models.

#### **Regression Example: Linear and Random Forest Regression**

```stata
use "data/sample_regression_data.dta", clear

automlselect regression, ///
    target(Price) ///
    predictors(Size Bedrooms Age Location_east Location_north Location_south Location_west) ///
    num_trees(200) ///
    mtry(3) ///
    max_depth(10) ///
    save_model("models/regression_model") ///
    save_metrics("metrics/regression_metrics.csv")
```

**Explanation:**

- **Task Type:** `regression`
- **Target Variable:** `Price`
- **Predictors:** `Size Bedrooms Age Location_east Location_north Location_south Location_west`
- **Random Forest Parameters:**
  - **`num_trees`**: 200 trees
  - **`mtry`**: 3 variables sampled at each split
  - **`max_depth`**: Maximum tree depth of 10
- **Outputs:**
  - **Trained Models:** Saved in `models/` directory with appropriate filenames.
  - **Evaluation Metrics:** Saved in `metrics/regression_metrics.csv`

#### **Classification Example: Logistic and Random Forest Classification**

```stata
use "data/sample_classification_data.dta", clear

automlselect classification, ///
    target(Purchase) ///
    predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    num_trees(200) ///
    mtry(4) ///
    max_depth(10) ///
    save_model("models/classification_model") ///
    save_metrics("metrics/classification_metrics.csv")
```

**Explanation:**

- **Task Type:** `classification`
- **Target Variable:** `Purchase`
- **Predictors:** `Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west`
- **Random Forest Parameters:**
  - **`num_trees`**: 200 trees
  - **`mtry`**: 4 variables sampled at each split
  - **`max_depth`**: Maximum tree depth of 10
- **Outputs:**
  - **Trained Models:** Saved in `models/` directory with appropriate filenames.
  - **Evaluation Metrics:** Saved in `metrics/classification_metrics.csv`

### 3. Model Training and Evaluation

**AutoMLSelect** handles the entire workflow of model training, prediction, and evaluation. After running the commands, you can find the trained models and evaluation metrics in the specified directories.

---

## Examples

### 1. `regression_example.do`

**File Path:**

```
AutoMLSelect/examples/regression_example.do
```

**Content:**

```stata
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
```

### 2. `classification_example.do`

**File Path:**

```
AutoMLSelect/examples/classification_example.do
```

**Content:**

```stata
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
    target(Purchase) ///
    predictors(Age Gender_female Gender_male Income Region_east Region_north Region_south Region_west) ///
    num_trees(200) ///
    mtry(4) ///
    max_depth(10) ///
    save_model("models/classification_model") ///
    save_metrics("metrics/classification_metrics.csv")
```

---

## Testing

The **`AutoMLSelect`** package includes comprehensive test scripts to ensure all functionalities work as expected.

### 1. Regression Tests

**File Path:**

```
AutoMLSelect/tests/test_regression.do
```

**Usage:**

```stata
do tests/test_regression.do
```

### 2. Classification Tests

**File Path:**

```
AutoMLSelect/tests/test_classification.do
```

**Usage:**

```stata
do tests/test_classification.do
```

---

## Troubleshooting

### **1. Installing `randomforest` Package Not Found**

If you encounter the error:

```
ssc install randomforest
ssc install: "randomforest" not found at SSC, type search randomforest
(To find all packages at SSC that start with r, type ssc describe r)
r(601);
```

**Solution:**

1. **Install the `rforest` Package Instead:**
   
   ```stata
   ssc install rforest
   ```
2. **Manual Installation Steps:**
   
   - **Download `rforest`:** Visit the [Stata Journal](http://www.stata-journal.com/software/sj20-1/rforest/) to download the `rforest` package.
   - **Extract and Move Files:** Extract the downloaded files and place them in your personal ado-directory (e.g., `C:\Users\YourName\ado\personal\`).
   - **Verify Installation:**
     
     ```stata
     which rforest
     ```
     
     Stata should display the path to the `rforest.ado` file.
3. **Update `AutoMLSelect` Ado-Files to Use `rforest`:**
   
   Ensure that in the `train_random_forest_regression.ado` and `train_random_forest_classification.ado` files, the `randomforest` command is replaced with `rforest`.

---

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. **Fork the Repository**
2. **Create a New Branch**
3. **Make Your Changes**
4. **Submit a Pull Request**

Ensure that all tests pass and documentation is updated accordingly.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

**Happy Modeling with AutoMLSelect!** If you encounter any further issues or have additional questions, feel free to reach out. I'm here to help!


