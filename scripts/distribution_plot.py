"""
Script for generating a black-and-white horizontal box plot of normalized PPM-derived prognostic index
for different treatment groups using Matplotlib.

Usage:
- Ensure the input CSV file ('data/df_adscore_all.csv') exists and contains the required columns:
  '3' (for  PPM-derived prognostic index) and 'Treatment Information' (categorical data for grouping).
- The output plot will be saved as an EPS file in the 'figures' directory.

Dependencies:
- pandas
- matplotlib
"""

import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file into a DataFrame
df = pd.read_csv("data/df_adscore_all.csv")

# Normalize the column named '3' by subtracting 0.4
df['normalized_PPM'] = df["3"] - 0.4

# Create a black-and-white horizontal box plot using Matplotlib
plt.figure(figsize=(10, 8))  # Set the figure size

# Generate the box plot for each treatment group
boxplot = plt.boxplot(
    [
        df[df['Treatment Information'] == 'Placebo']['normalized_PPM'],  # Data for Placebo group
        df[df['Treatment Information'] == 'LY3314814-20mg']['normalized_PPM'],  # Data for 20mg group
        df[df['Treatment Information'] == 'LY3314814-50mg']['normalized_PPM']  # Data for 50mg group
    ],
    labels=['Placebo', '20mg', '50mg'],  # Labels for the groups
    notch=True,  # Enable notched box plots
    patch_artist=True,  # Enable custom box styles
    flierprops=dict(marker='o', color='black', markersize=8),  # Customize outlier markers
    vert=False,  # Horizontal orientation
    boxprops=dict(facecolor='white', color='black'),  # Box style
    whiskerprops=dict(color='black'),  # Whisker style
    capprops=dict(color='black'),  # Cap style
    medianprops=dict(color='black'),  # Median line style
    showfliers=True  # Show outliers (set to False to hide them)
)

# Customize the plot appearance
plt.xlabel('PPM-derived Prognostic Index', fontsize=14)  # X-axis label
plt.ylabel('Treatment', fontsize=14)  # Y-axis label
plt.tick_params(labelsize=12)  # Adjust tick label size
plt.grid(False)  # Disable grid lines
plt.gca().spines['top'].set_visible(False)  # Hide the top spine
plt.gca().spines['right'].set_visible(False)  # Hide the right spine

# Save the figure as an EPS file
plt.tight_layout()  # Adjust layout to prevent clipping
plt.savefig('figures/boxplot_ppm_prognostic_index_bw_matplotlib.eps', format='eps', dpi=300)

# Display the plot
plt.show()
