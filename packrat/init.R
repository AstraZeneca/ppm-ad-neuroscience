# Initialize packrat for dependency management
if (!requireNamespace("packrat", quietly = TRUE)) {
  install.packages("packrat")
}
packrat::init()

# Install required packages
required_packages <- c(
  "lme4", "aws.s3", "mmrm", "sjPlot", "lmerTest", "pbkrtest", "nlme",
  "patchwork", "pwr", "ggplot2", "dplyr", "emmeans", "lsmeans"
)

# Install missing packages
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Snapshot the environment
packrat::snapshot()
