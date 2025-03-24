
# Load necessary libraries
library(ggplot2)
library(dplyr)
library(patchwork)

# Ensure consistent plot size
options(repr.plot.width = 18, repr.plot.height = 7)

# Load Data
new_table_ad_filtered <- read.csv("data/new_table_adas_withCov.csv") 

# Calculate changes over time: week 104 - week 1

# ADAS CHANGE
# Filter rows with time_point=1 and time_point=104
adas_1 <- subset(new_table_ad_filtered, time_point == 1)
adas_104 <- subset(new_table_ad_filtered, time_point == 104)

# Merge the two subsets based on the EID column
adas_change <- merge(adas_1, adas_104, by = "EID", suffixes = c("_1", "_104"))

# Calculate the change in ADAS
adas_change$ADAS_change <- adas_change$ADAS_104 - adas_change$ADAS_1

# Selecting specific columns
selected_columns <- c("EID", "Treatment_Information_1", "ad_category_1", "ADAS_change")

# Subset the data with selected columns
adas_change_subset <- adas_change[, selected_columns]

# Plot ADAS-Cog13 (main figure) and save figure and related table

# Combine "Slow" and "Rapid" into "All Progressive" and filter out "Stable" category
new_table_ad_filtered_all <- new_table_ad_filtered %>%
  filter(ad_category != "Stable") %>%
  mutate(ad_category = factor(ad_category, levels = c("Slow", "Rapid"))) %>%
  bind_rows(new_table_ad_filtered %>%
              filter(ad_category != "Stable") %>%
              mutate(ad_category = "All Progressive")) %>%
  mutate(ad_category = factor(ad_category, levels = c("Slow", "Rapid", "All Progressive")))

# Plot for Study with three subplots for AD categories using facet_wrap
p <- ggplot(new_table_ad_filtered_all, aes(x = time_point, y = ADAS, group = Treatment_Information, color = Treatment_Information)) +
  stat_summary(fun = "mean", geom = "line", position = position_dodge(width = 0.2), size = 1.2) +
  stat_summary(fun.data = "mean_se", geom = "errorbar", position = position_dodge(width = 0.8), width = 8, size = 1.2) +
  facet_wrap(~ ad_category, scales = "free", nrow = 1) +  # Create separate plots for each ad_category
  labs(x = "Time (weeks)",  # Change x-axis label
       y = "Mean ADAS-Cog13") +
  theme_minimal(base_family = "serif", base_size = 14) +
  coord_cartesian(ylim = c(25, 45)) +
  scale_y_continuous(breaks = seq(25, 45, by = 5)) +  # Adding more tick marks on y-axis
  scale_color_manual(values = c("Placebo" = "#7a7a7aff",  # Medium dark gray for Placebo
                                "LY3314814-20mg" = "#3d6dd1ff", "LY3314814-50mg" = "#9b2de1ff",  # Different blue shades for Slow progression
                                "LY3314814-20mg" = "#3d6dd1ff", "LY3314814-50mg" = "#9b2de1ff")) +  # Adjust colors as needed
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.line.x = element_line(color = "black"),
        axis.line.y = element_line(color = "black"),
        legend.position = "none")

# Print the plot
print(p)

# # Save the plot as EPS file
output_path_plot <- "figures/adas_plot.eps"
ggsave(output_path_plot, plot = p, device = "eps", width = 14, height = 7, family = "serif")

# Calculate means and standard errors
summary_table <- new_table_ad_filtered_all %>%
  group_by(time_point, ad_category, Treatment_Information) %>%
  summarise(
    mean_ADAS = mean(ADAS, na.rm = TRUE),
    se_ADAS = sd(ADAS, na.rm = TRUE) / sqrt(n())
  ) %>%
  arrange(ad_category, Treatment_Information, time_point)

# Save summary table as CSV
output_path_table <- "figures/ADAS_summary_table.csv"
write.csv(summary_table, file = output_path_table, row.names = FALSE)

# Print the summary table
print(summary_table)
