"""
This script generates a scatter plot to visualize the relationship between 
β-Amyloid levels and GM Density for different PPM-stratified groups.
The plot is saved as an EPS file.
"""

import matplotlib.pyplot as plt
import pandas as pd

# Load the data
df_adscore_all = pd.read_csv("data/df_adscore_all.csv")

# Configure plot font
plt.rcParams.update({
    'font.size': 12,
    'font.family': 'serif',
    'font.serif': ['Times New Roman']
})

# Create the figure
fig, ax = plt.subplots(figsize=(10, 8))

# Plot data by category
colors = {'Slow progression': '#880808', 'Rapid progression': '#228B22'}
for category in ['Slow progression', 'Rapid progression']:
    subset = df_adscore_all[df_adscore_all['ad_category'] == category]
    ax.scatter(subset['FBP Composite (SUVRCWM)'], subset['GM_SCORE'], label=category, facecolors='none', color=colors[category], alpha=0.6)

# Set labels and title
ax.set_title('All Treatments')
ax.set_xlabel('β-Amyloid')
ax.set_ylabel('GM Density')

# Adjust spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_position(('outward', 10))
ax.spines['bottom'].set_position(('outward', 10))

# Configure legend
ax.legend(loc='upper right', frameon=False)

# Finalize plot
plt.tight_layout()
plt.show()

# Save the plot
output_path = 'figures/all_treatments_noface_colors_alpha_0.6.eps'
fig.savefig(output_path, format='eps')
