# Load necessary libraries
library(ggplot2)
library(dplyr)
library(patchwork)

# Load Data
new_table_cdr_filtered <- read.csv("data/new_table_cdr_withCov.csv") #CDR

# CDR CHANGE
# Filter rows with time_point=1 and time_point=104
am_cdr_1 <- subset(new_table_cdr_filtered, time_point == 1)
am_cdr_104 <- subset(new_table_cdr_filtered, time_point == 104)

# Merge the two subsets based on the EID column
am_cdr_change <- merge(am_cdr_1, am_cdr_104, by = "EID", suffixes = c("_1", "_104"))

# Calculate the change in CDR_SOB
am_cdr_change$CDR_SOB_change <- am_cdr_change$CDR_SOB_104 - am_cdr_change$CDR_SOB_1

# Selecting specific columns
selected_columns <- c("EID", "Treatment_Information_1", "ad_category_1", "CDR_SOB_change")

# Subset the data with selected columns
am_cdr_change_subset <- am_cdr_change[, selected_columns]

# Plot CDR-SOB (main figure) and save figure and related table
# Assuming your CDR data is loaded into new_table_cdr_filtered
options(repr.plot.width = 18, repr.plot.height = 7)

# Combine "Slow" and "Rapid" into "All Progressive" and filter out "Stable" category
new_table_cdr_filtered_all <- new_table_cdr_filtered %>%
  filter(ad_category != "Stable") %>%
  mutate(ad_category = factor(ad_category, levels = c("Slow", "Rapid"))) %>%
  bind_rows(new_table_cdr_filtered %>%
              filter(ad_category != "Stable") %>%
              mutate(ad_category = "All Progressive")) %>%
  mutate(ad_category = factor(ad_category, levels = c("Slow", "Rapid", "All Progressive")))

# Plot for Study with three subplots for AD categories using facet_wrap
p <- ggplot(new_table_cdr_filtered_all, aes(x = time_point, y = CDR_SOB, group = Treatment_Information, color = Treatment_Information)) +
  stat_summary(fun = "mean", geom = "line", position = position_dodge(width = 0.2), size = 1.2) +
  stat_summary(fun.data = "mean_se", geom = "errorbar", position = position_dodge(width = 0.8), width = 8, size = 1.2) +
  facet_wrap(~ ad_category, scales = "free", nrow = 1) +  # Create separate plots for each ad_category
  labs(x = "Time (weeks)",  # Change x-axis label
       y = "Mean CDR-SOB") +
  theme_minimal(base_family = "serif", base_size = 14) +
  coord_cartesian(ylim = c(3, 8)) +
  scale_y_continuous(breaks = seq(3, 8, by = 1)) +  # Adding more tick marks on y-axis
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
output_path_plot <- "figures/cdr_plot.eps"
ggsave(output_path_plot, plot = p, device = "eps", width = 14, height = 7, family = "serif")

# Calculate means and standard errors
summary_table <- new_table_cdr_filtered_all %>%
  group_by(time_point, ad_category, Treatment_Information) %>%
  summarise(
    mean_CDR_SOB = mean(CDR_SOB, na.rm = TRUE),
    se_CDR_SOB = sd(CDR_SOB, na.rm = TRUE) / sqrt(n())
  ) %>%
  arrange(ad_category, Treatment_Information, time_point)

# Save summary table as CSV
output_path_table <- "figures/CDR_summary_table.csv"
write.csv(summary_table, file = output_path_table, row.names = FALSE)

# Print the summary table
print(summary_table)
