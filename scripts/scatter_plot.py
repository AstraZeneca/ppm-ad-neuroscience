"""This script generates a scatter plot to visualize the relationship between 
β-Amyloid levels and GM Density for different PPM-stratified groups.
The plot is saved as an EPS file."""

import matplotlib.pyplot as plt
import pandas as pd

def load_data(filepath):
    """Load the data from a CSV file."""
    return pd.read_csv(filepath)

def configure_plot():
    """Configure global plot settings."""
    plt.rcParams.update({
        'font.size': 12,
    })

def create_scatter_plot(df, ax, colors):
    """Create a scatter plot for the given DataFrame and axis."""
    for category in ['Slow progression', 'Rapid progression']:
        subset = df[df['ad_category'] == category]
        ax.scatter(subset['FBP Composite (SUVRCWM)'], subset['GM_SCORE'], label=category, facecolors='none', color=colors[category])

def style_plot(ax):
    """Apply styling to the plot."""
    ax.set_title('All Treatments')
    ax.set_xlabel('β-Amyloid')
    ax.set_ylabel('GM Density')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_position(('outward', 10))
    ax.spines['bottom'].set_position(('outward', 10))
    ax.legend(loc='upper right', frameon=False)

def save_plot(fig, output_path):
    """Save the plot to a file."""
    fig.savefig(output_path, format='eps', transparent=True)

def main():
    # Load the data
    df_adscore_all = load_data("data/df_adscore_all.csv")

    # Configure plot font
    configure_plot()

    # Create the figure
    fig, ax = plt.subplots(figsize=(10, 8))

    # Plot data by category
    colors = {'Slow progression': '#880808', 'Rapid progression': '#228B22'}
    create_scatter_plot(df_adscore_all, ax, colors)

    # Style the plot
    style_plot(ax)

    # Finalize plot
    plt.tight_layout()
    plt.show()

    # Save the plot
    save_plot(fig, 'figures/Figure2_A.eps')

if __name__ == "__main__":
    main()
