# maternal-health-u5mr
Population-weighted maternal health coverage analysis by U5MR status

# Health Service Coverage Analysis

This repository contains an end-to-end analysis of maternal health service coverage and its relationship to under-five mortality (U5MR) targets. The project was completed as part of an exam task and is fully reproducible.

---

## 📁 Repository Structure

```
└── population_demographics.xlsx
└── fusion_file_1.csv
└── country_tracking.xlsx
└── final_u5mr.R
└── final_report.html     <- this will be generated
└── README.md               <- describes how to run this project
```

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
3. Run final_u5mr.R
4. The final output will be saved as:

  final_report.html


## Data Sources

    UN World Population Prospects (2022): Demographic indicators

    UNICEF Global Data Repository: Health service coverage (ANC4, SBA)

    UNICEF Country Classification: U5MR target tracking

## Dependencies

The user_profile.R script automatically installs and loads the required R packages:

    readxl, dplyr, tidyr, janitor, stringr, countrycode, ggplot2, rmarkdown, kableExtra, knitr


