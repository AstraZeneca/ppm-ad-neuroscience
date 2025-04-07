# Load required packages
library(lme4)
library(pbkrtest)
library(ggplot2)
library(sjPlot)
library(dplyr)
library(patchwork)
library(pwr)
library(emmeans)
library(lmerTest)

# Define constants for file paths (parameterized for reusability)
data_path <- "data/"
output_path <- "figures/"
adas_file <- paste0(data_path, "new_table_adas_withCov.csv")
cdr_file <- paste0(data_path, "new_table_cdr_withCov.csv")
amyloid_file <- paste0(data_path, "new_table_withCov.csv")

# Define constants for plot dimensions
plot_width <- 12
plot_height <- 6

# Load data
load_data <- function() {
  list(
    adas = read.csv(adas_file),
    cdr = read.csv(cdr_file),
    amyloid = read.csv(amyloid_file)
  )
}

# Calculate changes over time for CDR
calculate_cdr_change <- function(cdr_data) {
  # Filter rows for time_point = 1 and time_point = 104
  cdr_1 <- subset(cdr_data, time_point == 1)
  cdr_104 <- subset(cdr_data, time_point == 104)
  
  # Merge subsets and calculate change
  cdr_change <- merge(cdr_1, cdr_104, by = "EID", suffixes = c("_1", "_104"))
  cdr_change$CDR_SOB_change <- cdr_change$CDR_SOB_104 - cdr_change$CDR_SOB_1
  
  # Select relevant columns
  selected_columns <- c("EID", "Treatment_Information_1", "ad_category_1", "CDR_SOB_change")
  cdr_change_subset <- cdr_change[, selected_columns]
  
  # Return subsets for slow and rapid progression
  list(
    slow = subset(cdr_change_subset, ad_category_1 == "Slow"),
    rapid = subset(cdr_change_subset, ad_category_1 == "Rapid"),
    placebo = subset(cdr_change_subset, Treatment_Information_1 == "Placebo"),
    mg_50 = subset(cdr_change_subset, Treatment_Information_1 == "LY3314814-50mg")
  )
}

# Calculate Cohen's d as effect size
calculate_effect_size <- function(group1, group2) {
  mean_group1 <- mean(group1)
  mean_group2 <- mean(group2)
  sd_group1 <- sd(group1)
  sd_group2 <- sd(group2)
  pooled_sd <- sqrt(((length(group1) - 1) * sd_group1^2 + (length(group2) - 1) * sd_group2^2) / (length(group1) + length(group2) - 2))
  return(abs(mean_group1 - mean_group2) / pooled_sd)
}

# Calculate power curve
calculate_power_curve <- function(effect_size, sample_sizes, alpha) {
  sapply(sample_sizes, function(n) {
    pwr.t.test(d = effect_size, sig.level = alpha, power = NULL, n = n)$power
  })
}

# Plot power curves
plot_power_curves <- function(sample_sizes, cdr_data, alpha, color1 = "blue", color2 = "green") {
  plot(NULL, xlim = c(0, max(sample_sizes)), ylim = c(0, 1), xlab = "Sample Size (n)", ylab = "Power",
       main = paste("Power Curves for Different Treatment Groups (alpha =", alpha, ")"),
       xaxt = "n", bty = "l")
  axis(1, at = seq(0, max(sample_sizes), by = 50))
  
  # Slow progression group
  effect_size_slow <- calculate_effect_size(cdr_data$slow$CDR_SOB_change[cdr_data$slow$Treatment_Information_1 == "Placebo"],
                                            cdr_data$slow$CDR_SOB_change[cdr_data$slow$Treatment_Information_1 == "LY3314814-50mg"])
  power_curve_slow <- calculate_power_curve(effect_size_slow, sample_sizes, alpha)
  lines(sample_sizes, power_curve_slow, type = "l", col = color1, lty = 1, lwd = 2)
  
  # Entire group
  effect_size_entire <- calculate_effect_size(cdr_data$placebo$CDR_SOB_change, cdr_data$mg_50$CDR_SOB_change)
  power_curve_entire <- calculate_power_curve(effect_size_entire, sample_sizes, alpha)
  lines(sample_sizes, power_curve_entire, type = "l", col = color2, lty = 1, lwd = 2)
  
  # Add legend
  legend("bottomright", legend = c("Slow", "All Progressive"), col = c(color1, color2), lty = 1, lwd = 2, bty = "n")
}

# Save plot data to CSV
save_plot_data <- function(sample_sizes, cdr_data, alpha, filename) {
  effect_size_slow <- calculate_effect_size(cdr_data$slow$CDR_SOB_change[cdr_data$slow$Treatment_Information_1 == "Placebo"],
                                            cdr_data$slow$CDR_SOB_change[cdr_data$slow$Treatment_Information_1 == "LY3314814-50mg"])
  power_curve_slow <- calculate_power_curve(effect_size_slow, sample_sizes, alpha)
  
  effect_size_entire <- calculate_effect_size(cdr_data$placebo$CDR_SOB_change, cdr_data$mg_50$CDR_SOB_change)
  power_curve_entire <- calculate_power_curve(effect_size_entire, sample_sizes, alpha)
  
  plot_data <- data.frame(
    sample_size = rep(sample_sizes, 2),
    power = c(power_curve_slow, power_curve_entire),
    group = rep(c("Slow", "All Progressive"), each = length(sample_sizes))
  )
  
  write.csv(plot_data, filename, row.names = FALSE)
}

# Main script
main <- function() {
  # Load data
  data <- load_data()
  
  # Calculate CDR changes
  cdr_data <- calculate_cdr_change(data$cdr)
  
  # Define parameters
  sample_sizes <- seq(10, 1500, by = 10)
  alpha <- 0.05
  
  # Plot and save power curves
  setEPS()
  postscript(paste0(output_path, "Figure6.eps"))
  plot_power_curves(sample_sizes, cdr_data, alpha, color1 = '#880808', color2 = "blue")
  dev.off()
  
  # Save data for the plot
  save_plot_data(sample_sizes, cdr_data, alpha, paste0(output_path, "Figure6.csv"))
}

# Run the script
main()