# Script Description:
# This script analyzes changes in ADAS-Cog13 scores over time for different treatment groups
#It calculates mean differences, standard errors, and generates
# bar plots and box plots to visualize the results. The script also saves the generated plots
# as EPS files for publication purposes.

# Load required packages
library(dplyr)
library(ggplot2)
library(patchwork)

# Ensure consistent plot size
options(repr.plot.width = 18, repr.plot.height = 7)

# Load Data
new_table_ad_filtered <- read.csv("data/new_table_adas_withCov.csv")

# Calculate changes over time: week 104 - week 1
adas_1 <- subset(new_table_ad_filtered, time_point == 1)
adas_104 <- subset(new_table_ad_filtered, time_point == 104)

# Merge subsets and calculate ADAS change
adas_change <- merge(adas_1, adas_104, by = "EID", suffixes = c("_1", "_104"))
adas_change$ADAS_change <- adas_change$ADAS_104 - adas_change$ADAS_1

# Subset data with selected columns
selected_columns <- c("EID", "Treatment_Information_1", "ad_category_1", "ADAS_change")
adas_change_subset <- adas_change[, selected_columns]
head(adas_change_subset)

# Prepare data for change plots
new_data <- new_table_ad_filtered %>%
  mutate(ad_category = factor(ad_category, levels = c("Slow", "Rapid")))

# Function to calculate mean values, differences, and standard errors
calculate_means_differences <- function(data, treatment_name) {
  data_treatment <- subset(new_data, Treatment_Information == treatment_name)
  mean_data_treatment <- aggregate(ADAS ~ ad_category + time_point, data = data_treatment, FUN = mean)
  
  mean_rapid <- subset(mean_data_treatment, ad_category == "Rapid")
  mean_slow <- subset(mean_data_treatment, ad_category == "Slow")
  mean_entire <- aggregate(ADAS ~ time_point, data = mean_data_treatment, FUN = mean)
  
  diff_data <- data.frame(
    Ad_Category = c("Slow", "Rapid", "Entire"),
    Difference = c(
      mean_slow[mean_slow$time_point == 104, "ADAS"] - mean_slow[mean_slow$time_point == 1, "ADAS"],
      mean_rapid[mean_rapid$time_point == 104, "ADAS"] - mean_rapid[mean_rapid$time_point == 1, "ADAS"],
      mean_entire[mean_entire$time_point == 104, "ADAS"] - mean_entire[mean_entire$time_point == 1, "ADAS"]
    )
  )
  
  diff_data$SE <- c(
    data_treatment %>% filter(ad_category == "Slow" & time_point == 104) %>%
      summarise(SE = sd(as.numeric(ADAS), na.rm = TRUE) / sqrt(n())) %>% pull(SE),
    data_treatment %>% filter(ad_category == "Rapid" & time_point == 104) %>%
      summarise(SE = sd(as.numeric(ADAS), na.rm = TRUE) / sqrt(n())) %>% pull(SE),
    data_treatment %>% filter(time_point == 104) %>%
      summarise(SE = sd(as.numeric(ADAS), na.rm = TRUE) / sqrt(n())) %>% pull(SE)
  )
  
  return(diff_data)
}

# Perform calculations for each treatment group
diff_data_se_50mg <- calculate_means_differences(new_data, "LY3314814-50mg")
diff_data_se_20mg <- calculate_means_differences(new_data, "LY3314814-20mg")
diff_data_se_placebo <- calculate_means_differences(new_data, "Placebo")

# Combine data into a single data frame
combined_data_adas <- data.frame(
  Ad_Category = diff_data_se_50mg$Ad_Category,
  Placebo_Difference = diff_data_se_placebo$Difference,
  Placebo_SE = diff_data_se_placebo$SE,
  `20mg_Difference` = diff_data_se_20mg$Difference,
  `20mg_SE` = diff_data_se_20mg$SE,
  `50mg_Difference` = diff_data_se_50mg$Difference,
  `50mg_SE` = diff_data_se_50mg$SE
)

# Specify the output file path
output_path <- "figures/FigureS1_B_BarPlot.csv"

# Write combined_data to CSV
write.csv(combined_data_adas, file = output_path, row.names = FALSE)

cat("ADAS-Cog13\n")
print(combined_data_adas)

# Provided data for ADAS-Cog13
combined_data_adas <- data.frame(
  Ad_Category = c("Slow", "Rapid", "All Progressive"),
  Placebo_Difference = c(8.033901, 9.937983, 8.985942),
  Placebo_SE = c(2.072223, 1.511948, 1.237557),
  X20mg_Difference = c(8.616314, 11.354118, 9.985216),
  X20mg_SE = c(2.664826, 1.596143, 1.378098),
  X50mg_Difference = c(4.952632, 12.187998, 8.570315),
  X50mg_SE = c(1.694144, 1.511651, 1.214135)
)

# Function to create a bar plot for a specific Ad_Category
plot_category <- function(category) {
  data_to_plot <- combined_data_adas[combined_data_adas$Ad_Category == category, ]
  plot_data <- data.frame(
    Treatment = factor(c("Placebo", "20mg", "50mg"), levels = c("Placebo", "20mg", "50mg")),
    Difference = c(data_to_plot$Placebo_Difference, data_to_plot$X20mg_Difference, data_to_plot$X50mg_Difference),
    SE = c(data_to_plot$Placebo_SE, data_to_plot$X20mg_SE, data_to_plot$X50mg_SE)
  )
  
  ggplot(plot_data, aes(x = Treatment, y = Difference, fill = Treatment)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.4) +
    geom_errorbar(aes(ymin = Difference - SE, ymax = Difference + SE),
                  position = position_dodge(width = 0.9), width = 0.25) +
    labs(title = category, x = "Treatment", y = "Change in ADAS-Cog13") +
    theme_minimal(base_size = 12) +
    coord_cartesian(ylim = c(0, 15)) +
    scale_fill_manual(values = c("Placebo" = "#7a7a7aff", "20mg" = "#3d6dd1ff", "50mg" = "#9b2de1ff")) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title.x = element_text(size = 12),
          axis.title.y = element_text(size = 12),
          axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
          axis.text.y = element_text(size = 10),
          axis.line = element_line(color = "black"),
          legend.position = "none")
}

# Generate and save plots
plot_slow <- plot_category("Slow")
plot_rapid <- plot_category("Rapid")
plot_entire <- plot_category("All Progressive")
combined_plot <- plot_slow + plot_rapid + plot_entire + plot_layout(ncol = 3)

ggsave("figures/FigureS1_B_BarPlot.eps", plot = combined_plot, device = "eps", width = 14, height = 7, family = "serif")
print(combined_plot)

# Function to create box plots
plot_category_boxplot <- function(data, ad_category) {
  data_to_plot <- na.omit(unique(data[data$ad_category_1 == ad_category, ]))
  data_to_plot$Treatment_Information_1 <- factor(
    data_to_plot$Treatment_Information_1,
    levels = c("Placebo", "LY3314814-20mg", "LY3314814-50mg")
  )
  
  ggplot(data_to_plot, aes(x = Treatment_Information_1, y = ADAS_change, fill = Treatment_Information_1)) +
    geom_boxplot(outlier.shape = 16, outlier.size = 2.5) +
    labs(title = ad_category, x = "Treatment", y = "Change in ADAS-Cog13") +
    theme_minimal(base_size = 12) +
    scale_fill_manual(values = c("Placebo" = "#7a7a7aff", "LY3314814-20mg" = "#3d6dd1ff", "LY3314814-50mg" = "#9b2de1ff")) +
    scale_y_continuous(name = "Change in ADAS-Cog13", breaks = seq(-10, 40, by = 5), limits = c(-10, 40)) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title.x = element_text(size = 12),
          axis.title.y = element_text(size = 12),
          axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
          axis.text.y = element_text(size = 10),
          axis.line = element_line(color = "black"),
          legend.position = "none")
}

# Generate and save box plots
df_dup <- adas_change_subset[adas_change_subset$ad_category_1 %in% c("Slow", "Rapid"), ]
df_dup$ad_category_1 <- "All Progressive"
df_combined <- rbind(adas_change_subset, df_dup)

plot_slow_box <- plot_category_boxplot(df_combined, "Slow")
plot_rapid_box <- plot_category_boxplot(df_combined, "Rapid")
plot_entire_box <- plot_category_boxplot(df_combined, "All Progressive")
combined_plot_box <- plot_slow_box + plot_rapid_box + plot_entire_box + plot_layout(ncol = 3)

ggsave("figures/FigureS1_B.eps", plot = combined_plot_box, device = "eps", width = 14, height = 7, family = "serif")
print(combined_plot_box)

# Function to calculate box plot metadata
calculate_boxplot_metadata <- function(data, ad_category) {
  # Filter data for the specific category
  data_to_plot <- na.omit(data[data$ad_category_1 == ad_category, ])
  
  # Calculate statistics for each treatment group
  metadata <- data_to_plot %>%
    group_by(Treatment_Information_1) %>%
    summarise(
      Median = median(ADAS_change),
      Q1 = quantile(ADAS_change, 0.25),
      Q3 = quantile(ADAS_change, 0.75),
      Lower_Whisker = max(min(ADAS_change), Q1 - 1.5 * IQR(ADAS_change)),
      Upper_Whisker = min(max(ADAS_change), Q3 + 1.5 * IQR(ADAS_change)),
      Outliers = paste(ADAS_change[ADAS_change < Q1 - 1.5 * IQR(ADAS_change) | ADAS_change > Q3 + 1.5 * IQR(ADAS_change)], collapse = ";")
    )
  
  # Add the category to the metadata
  metadata$Ad_Category <- ad_category
  return(metadata)
}

# Calculate metadata for each category
metadata_slow <- calculate_boxplot_metadata(df_combined, "Slow")
metadata_rapid <- calculate_boxplot_metadata(df_combined, "Rapid")
metadata_all <- calculate_boxplot_metadata(df_combined, "All Progressive")

# Combine metadata for all categories
combined_metadata <- bind_rows(metadata_slow, metadata_rapid, metadata_all)

# Save metadata to a CSV file
write.csv(combined_metadata, "figures/FigureS1_B.csv", row.names = FALSE)

# Print the metadata to the console
print(combined_metadata)