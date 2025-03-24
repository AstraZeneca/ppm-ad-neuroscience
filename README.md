# AI-Guided Patient Stratification for Alzheimer’s Disease Clinical Trials

This repository contains R and Python scripts for generating figures and performing analyses related to the manuscript titled **"AI-guided patient stratification improves outcomes and efficiency of Alzheimer’s Disease clinical trials"**.

## Abstract

Alzheimer’s Disease (AD) drug discovery has been hampered by patient heterogeneity, and the lack of sensitive tools for precise stratification at early dementia stages. Here, we demonstrate that a robust and interpretable AI-guided tool (predictive prognostic model, PPM) improves outcomes and decreases trial sample size by enhancing patient stratification precision for the AMARANTH trial of lanabecestat . Despite the fact that the trial was deemed futile, using the PPM— pre-trained on research data— to re-stratify patients based on baseline trial data showed significant treatment effects: reduction in β-amyloid and 46% slowing of cognitive decline for slow progressive individuals at earlier stages of neurodegeneration compared to rapid progressive individuals that did not show significant change in cognitive outcomes. Our results provide evidence for AI-guided patient stratification that is more precise than standard patient selection approaches (e.g. β-amyloid positivity) and has strong potential to enhance efficiency and efficacy of future AD trials. 

## Overview
The code base is designed to support the findings and visualizations presented in the manuscript.

## Software Requirements

To run the code in this repository, you will need the following software and libraries:

- **Python**: Version 3.8 or higher
  - Required libraries: `numpy`, `pandas`, `scikit-learn`, `matplotlib`, `seaborn`, `tensorflow` (if applicable)
- **R**: Version 4.0 or higher
  - Required packages: `ggplot2`, `dplyr`, `tidyr`, `caret`, `survival`

Ensure all dependencies are installed before running the scripts.

## Repository Structure

The repository is organized as follows:

- **/data/**: Placeholder for input datasets (not included in the repository due to privacy concerns).
- **/figures/**: Directory for storing output files, including figures and model results.
- **/notebooks/**: Jupyter notebooks for statistical analysis and figure generation.
- **/scripts/ADAS-COG13: scripts for generating change in ADAS-COG13 across PPM-stratified group, treatment and timepoint
- **/scripts/CDR-SOB: scripts for generating change in CDR-SOB across PPM-stratified group, treatment and timepoint
- **/scripts/β-Amyloid: scripts for generating change in β-Amyloid across PPM-stratified group, treatment and timepoint
- **/scripts/alluvial_plot.py: generating Sankey diagrams to visualize the transitions between PPM-stratified group 
(Slow and Rapid) from baseline to follow-up for different treatment groups
- **/scripts/distribution_plot.py: generating a black-and-white horizontal box plot of normalized PPM-derived prognostic index
for different treatment groups 
- **/scripts/scatter_plot.py: generating a scatter plot to visualize the relationship between 
β-Amyloid levels and GM Density for different PPM-stratified groups
- **README.md**: Documentation for the repository.

## How to Use the Code

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/ppm-ad-neuroscience.git
   cd ppm-ad-neuroscience
   ```

2. **Prepare the Environment**:
   - Install the required Python libraries using `pip`:
     ```bash
     pip install -r requirements.txt
     ```
   - Install the required R packages using your preferred R package manager.

3. **Add Data**:
   - Place the input datasets in the `/data/` directory. Ensure the data format matches the expected input for the scripts.

4. **Run the Scripts**:
   - For Python scripts:
     ```bash
     python /Python/<script_name>.py
     ```
   - For R scripts:
     ```R
     source("/R/<script_name>.R")
     ```

5. **View Results**:
   - Output files will be saved in the `/figures/` directory. Check this directory for figures, tables, and other results.

6. **Reproduce Manuscript Figures**:
   - Follow the instructions in the respective R or Python scripts to generate the figures presented in the manuscript.

For further details, refer to the comments within each script or contact the project maintainers.
