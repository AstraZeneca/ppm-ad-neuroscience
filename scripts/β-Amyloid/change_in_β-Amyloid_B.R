# This script calculates and visualizes the differences in β-Amyloid levels between time points for various treatment groups 
# and PPM-stratified groups.
# It includes functions for calculating mean differences, standard errors, and generating bar and box plots.
# The script also saves the results as plots and tables for further analysis.
# Libraries used: dplyr, ggplot2, patchwork

# Load required packages
library(dplyr)
library(ggplot2)
library(patchwork)

# Ensure consistent plot size
options(repr.plot.width = 18, repr.plot.height = 7)

# Load Data
new_table_amyloid <- read.csv("data/new_table_withCov.csv") #Amyloid

# Amyloid CHANGE
# Filter rows with time_point=1 and time_point=104
new_table_1 <- subset(new_table_amyloid, time_point == 1)
new_table_104 <- subset(new_table_amyloid, time_point == 104)

# Merge the two subsets based on the EID column
amyloid_change <- merge(new_table_1, new_table_104, by = "EID", suffixes = c("_1", "_104"))

# Calculate the change in Amyloid_Beta
amyloid_change$Amyloid_change <- amyloid_change$Amyloid_Beta_104 - amyloid_change$Amyloid_Beta_1

# Selecting specific columns
selected_columns <- c("EID", "Treatment_Information_1", "ad_category_1", "Amyloid_change")

# Subset the data with selected columns
amyloid_change_subset <- amyloid_change[, selected_columns]

# Data for change plots (no need to run, just for your information)


new_data <- new_table_amyloid %>%
  mutate(ad_category = factor(ad_category, levels = c("Slow", "Rapid")))

# Function to calculate mean values and differences
calculate_means_differences <- function(data, treatment_name) {
  data_treatment <- subset(new_data, Treatment_Information == treatment_name)
  
  mean_data_treatment <- aggregate(Amyloid_Beta ~ ad_category + time_point, data = data_treatment, FUN = mean)
  
  mean_rapid <- subset(mean_data_treatment, ad_category == "Rapid")
  mean_slow <- subset(mean_data_treatment, ad_category == "Slow")
  mean_entire <- aggregate(Amyloid_Beta ~ time_point, data = mean_data_treatment, FUN = mean)

  diff_slow_104_1 <- mean_slow[mean_slow$time_point == 104, "Amyloid_Beta"] - mean_slow[mean_slow$time_point == 1, "Amyloid_Beta"]
  diff_rapid_104_1 <- mean_rapid[mean_rapid$time_point == 104, "Amyloid_Beta"] - mean_rapid[mean_rapid$time_point == 1, "Amyloid_Beta"]
  diff_entire_104_1 <- mean_entire[mean_entire$time_point == 104, "Amyloid_Beta"] - mean_entire[mean_entire$time_point == 1, "Amyloid_Beta"]
  
  diff_data <- data.frame(Ad_Category = c("Slow", "Rapid", "All Progressive"),
                          Difference = c(diff_slow_104_1, diff_rapid_104_1, diff_entire_104_1))
  
  se_slow_104_1 <- data_treatment %>%
    filter(ad_category == "Slow" & time_point == 104) %>%
    summarise(SE = sd(as.numeric(Amyloid_Beta), na.rm = TRUE) / sqrt(n())) %>%
    pull(SE)
  
  se_rapid_104_1 <- data_treatment %>%
    filter(ad_category == "Rapid" & time_point == 104) %>%
    summarise(SE = sd(as.numeric(Amyloid_Beta), na.rm = TRUE) / sqrt(n())) %>%
    pull(SE)
  
  se_entire_104_1 <- data_treatment %>%
    filter(time_point == 104) %>%
    summarise(SE = sd(as.numeric(Amyloid_Beta), na.rm = TRUE) / sqrt(n())) %>%
    pull(SE)
  
  diff_data_se <- data.frame(Ad_Category = c("Slow", "Rapid", "All Progressive"),
                             Difference = c(diff_slow_104_1, diff_rapid_104_1, diff_entire_104_1),
                             SE = c(se_slow_104_1, se_rapid_104_1, se_entire_104_1))
  
  return(diff_data_se)
}

# Perform calculations for each treatment group
diff_data_se_50mg <- calculate_means_differences(new_data, "LY3314814-50mg")
diff_data_se_20mg <- calculate_means_differences(new_data, "LY3314814-20mg")
diff_data_se_placebo <- calculate_means_differences(new_data, "Placebo")

# Combine the data into a single data frame
combined_data <- data.frame(
  Ad_Category = diff_data_se_50mg$Ad_Category,
  Placebo_Difference = diff_data_se_placebo$Difference,
  Placebo_SE = diff_data_se_placebo$SE,
  `20mg_Difference` = diff_data_se_20mg$Difference,
  `20mg_SE` = diff_data_se_20mg$SE,
  `50mg_Difference` = diff_data_se_50mg$Difference,
  `50mg_SE` = diff_data_se_50mg$SE
)

cat("Amyloid_Beta\n")

# Print the combined data table
print(combined_data)

# Plot B-Amyloid change (main figure) and save figure and related table

options(repr.plot.width = 18, repr.plot.height = 7)

# Provided data
combined_data <- data.frame(
  Ad_Category = c("Slow", "Rapid", "All Progressive"),
  Placebo_Difference = c(3.3189086, -3.7684220, -0.2247567),
  Placebo_SE = c(4.190017, 3.970093, 3.171685),
  X20mg_Difference = c(-8.521253, -21.666951, -15.094102),
  X20mg_SE = c(4.914002, 3.453145, 2.942220),
  X50mg_Difference = c(-12.75434, -25.54914, -19.15174),
  X50mg_SE = c(3.785883, 3.446617, 2.838849)
)

# Function to create a plot for a specific Ad_Category
plot_category <- function(category) {
  data_to_plot <- combined_data[combined_data$Ad_Category == category,]
  plot_data <- data.frame(
    Treatment = factor(c("Placebo", "20mg", "50mg"), levels = c("Placebo", "20mg", "50mg")),
    Difference = c(data_to_plot$Placebo_Difference, data_to_plot$X20mg_Difference, data_to_plot$X50mg_Difference),
    SE = c(data_to_plot$Placebo_SE, data_to_plot$X20mg_SE, data_to_plot$X50mg_SE)
  )
  
  p <- ggplot(plot_data, aes(x = Treatment, y = Difference, fill = Treatment)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.4) +  # Adjust bar width here
    geom_errorbar(aes(ymin = Difference - SE, ymax = Difference + SE),
                  position = position_dodge(width = 0.9), width = 0.25) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +  # Add dashed horizontal line at y=0
    labs(title = category, x = "Treatment", y = "Change in β-Amyloid") +
    theme_minimal(base_size = 12) +
    coord_cartesian(ylim = c(-30, 10)) +
    scale_fill_manual(values = c("Placebo" = "#7a7a7aff",  # Medium dark gray for Placebo
                                 "20mg" = "#3d6dd1ff",  # Different blue shades for Slow progression
                                 "50mg" = "#9b2de1ff")) +  # Rapid progression colors
    theme(panel.grid.major = element_blank(),  # Remove major grid lines
          panel.grid.minor = element_blank(),  # Remove minor grid lines
          axis.title.x = element_text(size = 12),  # Adjust x-axis title size
          axis.title.y = element_text(size = 12),  # Adjust y-axis title size
          axis.text.x = element_text(size = 10, angle = 45, hjust = 1),  # Adjust x-axis tick label size and rotation
          axis.text.y = element_text(size = 10),  # Adjust y-axis tick label size
          axis.line = element_line(color = "black"),
          legend.position = "none")  # Add axis lines
  
  return(p)
}


# Generate plots for each category with modified colors and narrower bars
plot_slow <- plot_category("Slow")
plot_rapid <- plot_category("Rapid")
plot_entire <- plot_category("All Progressive")

# Arrange plots in a single row using patchwork
combined_plot <- plot_slow + plot_rapid + plot_entire + plot_layout(ncol = 3)

# # Save the combined plot as EPS
# # Save the plot as EPS file
output_path_plot <- "figures/change_bar_amyloid_plot.eps"
ggsave(output_path_plot, plot = combined_plot, device = "eps", width = 14, height = 7, family = "serif")

print(combined_plot)

# Provided data
combined_data <- data.frame(
  Ad_Category = c("Slow", "Rapid", "All Progressive"),
  Placebo_Difference = c(3.3189086, -3.7684220, -0.2247567),
  Placebo_SE = c(4.190017, 3.970093, 3.171685),
  X20mg_Difference = c(-8.521253, -21.666951, -15.094102),
  X20mg_SE = c(4.914002, 3.453145, 2.942220),
  X50mg_Difference = c(-12.75434, -25.54914, -19.15174),
  X50mg_SE = c(3.785883, 3.446617, 2.838849)
)

# Specify the output file path
output_path <- "figures/summary_amyloid_change.csv"

# Write combined_data to CSV
write.csv(combined_data, file = output_path, row.names = FALSE)


plot_category_boxplot <- function(data, ad_category){
    # Remove duplicate rows
    df_unique <- unique(data)

    # Remove rows with NA values
    df_clean <- na.omit(df_unique)
    data_to_plot <- df_clean[df_clean$ad_category_1 == ad_category,]
    
    data_to_plot$Treatment_Information_1 <- factor(
      data_to_plot$Treatment_Information_1,
      levels = c("Placebo", "LY3314814-20mg", "LY3314814-50mg")
    )
  
    p <- ggplot(data_to_plot, aes(x = Treatment_Information_1, y = Amyloid_change, fill = Treatment_Information_1)) +
      geom_boxplot(outlier.shape = 16, outlier.size = 2.5) +
      labs(title = ad_category, x = "Treatment", y = "Change in β-Amyloid") +
      theme_minimal(base_size = 12) +
      scale_fill_manual(values = c("Placebo" = "#7a7a7aff", "LY3314814-20mg" = "#3d6dd1ff", "LY3314814-50mg" = "#9b2de1ff")) +
      
    # Add x-axis and y-axis labels
     theme_minimal(base_size = 12) +
#      coord_cartesian(ylim = c(-80, 20)) +
# Include tick marks for both axes
      scale_y_continuous(name = "Change in β-Amyloid", breaks = seq(-100, 60, by = 20), limits = c(-120, 60)) +
    
      theme(panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.title.x = element_text(size = 12),
            axis.title.y = element_text(size = 12),
            axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
            axis.text.y = element_text(size = 10),
            axis.line = element_line(color = "black"),
            legend.position = "none")
    return(p)}

# Generate box plot with category parameter
# Create a duplicate of rows where ad_category_1 is "X" or "Y" and change it to "X+Y"
df_dup <- amyloid_change_subset[amyloid_change_subset$ad_category_1 %in% c("Slow", "Rapid"), ]
df_dup$ad_category_1 <- "All Progressive"

# Combine the original data frame with the duplicates for "X+Y"
df_combined <- rbind(amyloid_change_subset, df_dup)

plot_slow_box <- plot_category_boxplot(df_combined, "Slow" )
plot_rapid_box <- plot_category_boxplot(df_combined, "Rapid")
plot_entire_box <- plot_category_boxplot(df_combined, "All Progressive")

# Arrange plots in a single row using patchwork
combined_plot_box <- plot_slow_box + plot_rapid_box + plot_entire_box + plot_layout(ncol = 3)

# # Save the plot as EPS file
output_path_plot <- "figures/change_box_amyloid_plot.eps"
ggsave(output_path_plot, plot = combined_plot_box, device = "eps", width = 14, height = 7, family = "serif")

# Print the combined box plots
print(combined_plot_box)