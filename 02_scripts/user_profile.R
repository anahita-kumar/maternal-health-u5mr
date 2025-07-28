# user_profile.R

# List of required packages
required_packages <- c(
  "readxl", "dplyr", "tidyr", "janitor", "countrycode",
  "stringr", "ggplot2", "rmarkdown", "knitr", "kableExtra"
)

# Install any missing packages
installed_packages <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg)
  }
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))

# Set working directory to the script's parent directory
# (only works when run via Rscript or in RStudio)
this_file <- parent.frame(2)$ofile
if (!is.null(this_file)) {
  setwd(dirname(this_file))
}
