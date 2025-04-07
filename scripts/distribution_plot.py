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

def load_and_normalize_data(filepath):
    """Load the CSV file and normalize the PPM column."""
    df = pd.read_csv(filepath)
    df['normalized_PPM'] = df["PPM"] - 0.4
    return df

def generate_boxplot(df):
    """Generate a black-and-white horizontal box plot."""
    plt.figure(figsize=(10, 8))  # Set the figure size
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
    return boxplot

def extract_metadata(boxplot):
    """Extract metadata from the box plot."""
    metadata = {
        "Group": ['Placebo', '20mg', '50mg'],
        "Median": [line.get_xdata()[0] for line in boxplot['medians']],  # Extract median values
        "Q1 (25th Percentile)": [patch.get_path().vertices[0][0] for patch in boxplot['boxes']],  # Extract Q1
        "Q3 (75th Percentile)": [patch.get_path().vertices[2][0] for patch in boxplot['boxes']],  # Extract Q3
        "Lower Whisker": [line.get_xdata()[1] for line in boxplot['whiskers'][::2]],  # Extract lower whisker
        "Upper Whisker": [line.get_xdata()[1] for line in boxplot['whiskers'][1::2]],  # Extract upper whisker
        "Outliers": [line.get_xdata().tolist() for line in boxplot['fliers']]  # Extract outliers
    }
    return pd.DataFrame(metadata)

def save_metadata(metadata_df, filepath):
    """Save metadata to a CSV file."""
    metadata_df.to_csv(filepath, index=False)

def customize_and_save_plot(output_filepath):
    """Customize the plot appearance and save it."""
    plt.xlabel('PPM-derived Prognostic Index', fontsize=14)  # X-axis label
    plt.ylabel('Treatment', fontsize=14)  # Y-axis label
    plt.tick_params(labelsize=12)  # Adjust tick label size
    plt.grid(False)  # Disable grid lines
    plt.gca().spines['top'].set_visible(False)  # Hide the top spine
    plt.gca().spines['right'].set_visible(False)  # Hide the right spine
    plt.tight_layout()  # Adjust layout to prevent clipping
    plt.savefig(output_filepath, format='eps', dpi=300)

def main():
    """Main function to orchestrate the workflow."""
    input_csv = "data/df_adscore_all.csv"
    metadata_csv = "figures/Figure2_B.csv"
    output_eps = "figures/Figure2_B.eps"

    df = load_and_normalize_data(input_csv)
    boxplot = generate_boxplot(df)
    metadata_df = extract_metadata(boxplot)
    save_metadata(metadata_df, metadata_csv)
    customize_and_save_plot(output_eps)
    plt.show()

if __name__ == "__main__":
    main()