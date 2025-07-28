# maternal-health-u5mr
Population-weighted maternal health coverage analysis by U5MR status

# Health Service Coverage Analysis

This repository contains an end-to-end analysis of maternal health service coverage and its relationship to under-five mortality (U5MR) targets. The project was completed as part of an exam task and is fully reproducible.

---

## 📁 Repository Structure

├── 01_rawdata/ # Raw input data files (UN and UNICEF sources)
├── 02_scripts/ # Analysis scripts
├── 03_outputs/ # Final outputs (plot + report)
├── run_project.R # Main runner script for end-to-end workflow
├── user_profile.R # Setup script to load/install required packages
├── README.md # Project documentation


---

## 📊 Project Overview

I examine population-weighted coverage of two maternal health indicators:
- **ANC4**: % of women with ≥4 antenatal care visits
- **SBA**: % of births attended by skilled personnel

Countries are grouped based on their progress toward U5MR targets as defined by UNICEF:
- **Achieved**
- **On Track**
- **Acceleration Needed**

---

## ⚙️ How to Reproduce

1. Clone or download this repository.
2. Open R (or RStudio) and set the working directory to the root of the project.
3. Run the two setup scripts in order:
   ```r
   source("user_profile.R")    # Installs and loads required packages
   source("run_project.R")     # Executes full analysis and generates report

4. The final output will be saved as:

    03_outputs/final_report.html


Data Sources

    UN World Population Prospects (2022): Demographic indicators

    UNICEF Global Data Repository: Health service coverage (ANC4, SBA)

    UNICEF Country Classification: U5MR target tracking

See the 01_rawdata/ folder for raw input files.

Dependencies

The user_profile.R script automatically installs and loads the required R packages:

    readxl, dplyr, tidyr, janitor, stringr, countrycode, ggplot2, rmarkdown, kableExtra, knitr

