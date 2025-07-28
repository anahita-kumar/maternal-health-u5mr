# run_project.R

# Load packages and environment
source("user_profile.R")

# Run main analysis
source("02_scripts/main_analysis.R")

# Move the final HTML report to the outputs folder
file.rename("final_report.html", "03_outputs/final_report.html")
