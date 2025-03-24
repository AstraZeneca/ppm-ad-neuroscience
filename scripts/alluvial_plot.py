"""
This script generates Sankey diagrams to visualize the transitions between PPM-stratified group 
(Slow and Rapid) from baseline to follow-up for different treatment groups. The data 
is sourced from CSV files containing baseline and follow-up PPM-stratified group information, as well as 
treatment details. The diagrams are saved as EPS files for each treatment group.

Key functionalities:
- Load and preprocess PPM-stratified group and treatment data.
- Combine baseline and follow-up categories into a single column for analysis.
- Generate Sankey diagrams to represent transitions between categories for each treatment group.
- Save the diagrams as high-resolution EPS files.
"""

import pandas as pd
import plotly.graph_objects as go

# Load the baseline and follow-up AD category data
df = pd.read_csv('data/baseline_followup_adcategory.csv')

# Define the order of categories for consistency
category_order = ['Slow-Slow', 'Slow-Rapid', 'Rapid-Slow', 'Rapid-Rapid']

# Create a new column to represent the combined categories
df['category'] = df['ad_category_baseline'] + '-' + df['ad_category_104']

# Merge with additional treatment information
df_all = pd.read_csv("data/combined_df.csv")
df_temp = df.set_index("EID").join(df_all.set_index("EID")["Treatment Information"], how='left')
df_copy = df_temp.reset_index()
df_treatment = df_copy[~df_copy["EID"].duplicated()]

# Define treatments and colors for the Sankey diagram
treatment = ['LY3314814-20mg', 'LY3314814-50mg', 'Placebo']
link_colors = [
    "rgba(200, 200, 200, 0.7)",  # Neutral gray
    "rgba(176, 48, 48, 0.7)",    # Dark red
    "rgba(84, 189, 84, 0.7)",    # Green
    "rgba(200, 200, 200, 0.7)"   # Neutral gray
]
node_colors = [
    "rgba(136, 8, 8, 0.7)",  # Red for 'Slow'
    "rgba(34, 139, 34, 0.7)",  # Green for 'Rapid'
    "rgba(136, 8, 8, 0.7)",  # Red for 'Slow' (follow-up)
    "rgba(34, 139, 34, 0.7)"  # Green for 'Rapid' (follow-up)
]

# Generate Sankey diagrams for each treatment group
for treat in treatment:
    # Filter data for the current treatment group
    df_treat = df_treatment[df_treatment["Treatment Information"] == treat]
    
    # Define categories and mapping for Sankey diagram
    cats = ['Slow', 'Rapid']
    dict_cat = {'Slow': 0, 'Rapid': 1}
    source = []
    target = []
    counts = []
    
    # Calculate source, target, and counts for transitions
    for cat_1 in cats:
        for cat_2 in cats:
            n_patients = sum(df_treat['ad_category_baseline'] == cat_1)
            source.append(dict_cat[cat_1])
            target.append(dict_cat[cat_2] + 2)  # Offset for follow-up categories
            count_patients = sum(df_treat['category'] == f"{cat_1}-{cat_2}")
            counts.append((count_patients / n_patients) * 100 if n_patients > 0 else 0)

    # Create the Sankey diagram
    fig = go.Figure(data=[go.Sankey(
        node=dict(
            pad=15,
            thickness=20,
            line=dict(color="black", width=0.6),
            label=['Slow', 'Rapid', 'Slow', 'Rapid'],  # Baseline and follow-up categories
            color=node_colors
        ),
        link=dict(
            source=source,
            target=target,
            value=counts,
            color=link_colors
        )
    )])

    # Update layout and save the figure
    fig.update_layout(
        title_text=f"{treat}",
        font_size=14,
        width=800  # Specify the desired width of the plot
    )
    fig.write_image(f'figures/sankey_{treat}_new_patient_transition.eps', format='eps', engine='kaleido', scale=3)
    fig.show()
