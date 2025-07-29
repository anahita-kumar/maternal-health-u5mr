---
title: "Learning and Skills Data Analyst Consultant – Req. #581598"
output: html_document
---

# actual data starts on row 17
start_row <- 17

library(readxl)
library(dplyr)
library(tidyr)
library(janitor)
library(countrycode)
library(stringr)
library(tinytex)
library(ggplot2)
library(rmarkdown)
library(knitr)
library(kableExtra)

# Read in the data, skipping metadata rows
df <- read_excel("population_demographics.xlsx", 
                 sheet = "Projections",
                 skip = start_row - 1)

pop_clean <- df %>%
  clean_names() %>%
  filter(year == 2022) %>%
  mutate(
    births = suppressWarnings(as.numeric(births_thousands)) * 1000,
    iso3 = countrycode(region_subregion_country_or_area, "country.name", "iso3c")
  ) %>%
  filter(!is.na(iso3), !is.na(births)) %>%
  select(
    country = region_subregion_country_or_area,
    iso3,
    births,
    total_population = total_population_as_of_1_july_thousands,
    total_fertility = total_fertility_rate_live_births_per_woman,
    under5_mortality = under_five_mortality_deaths_under_age_5_per_1_000_live_births
  )

anc_clean <- read.csv("fusion_file_1.csv") %>%
  clean_names() %>%
  filter(grepl("(antenatal.*(4|four))|(skilled.*(birth|delivery|personnel))", 
               indicator_indicator, ignore.case = TRUE)) %>%
  mutate(year = as.numeric(time_period_time_period)) %>%
  filter(between(year, 2018, 2022)) %>%
  group_by(ref_area_geographic_area, indicator_indicator) %>%
  slice_max(year, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(
    country = ref_area_geographic_area,
    indicator = indicator_indicator,
    year,
    value = obs_value_observation_value
  ) %>%
  pivot_wider(names_from = indicator, values_from = value) %>%
  clean_names() %>%
  rename(
    anc4 = matches("antenatal.*four|antenatal.*4"),
    sba = matches("skilled.*birth|skilled.*personnel")
  ) %>%
  mutate(
    country_clean = str_extract(country, "(?<=: ).+") %>% str_trim(),
    is_country = !grepl("region|union|africa$|america$|asia$|europe$", country_clean, ignore.case = TRUE)
  ) %>%
  filter(is_country) %>%
  select(-is_country)

u5mr_clean <- read_xlsx("country_tracking.xlsx") %>%
  select(
    iso3 = ISO3Code,
    u5mr_status = Status.U5MR
  ) %>%
  mutate(iso3 = as.character(iso3))

country_fixes <- tibble(
  old_name = c(
    "Côte d'Ivoire", "Türkiye", "Democratic Republic of the Congo",
    "Iran (Islamic Republic of)", "Viet Nam", "Bolivia (Plurinational State of)",
    "Lao People's Democratic Republic", "Republic of Moldova"
  ),
  new_name = c(
    "Cote d'Ivoire", "Turkey", "Congo DR",
    "Iran", "Vietnam", "Bolivia",
    "Laos", "Moldova"
  ),
  iso3 = c("CIV", "TUR", "COD", "IRN", "VNM", "BOL", "LAO", "MDA")
)

anc_clean <- anc_clean %>%
  left_join(country_fixes, by = c("country_clean" = "old_name")) %>%
  mutate(
    country_clean = coalesce(new_name, country_clean),
    iso3 = coalesce(iso3, countrycode(country_clean, "country.name", "iso3c"))
  ) %>%
  filter(!is.na(iso3)) %>%
  select(-new_name)

final_data <- anc_clean %>%
  left_join(u5mr_clean, by = "iso3") %>%
  left_join(pop_clean %>% select(iso3, births), by = "iso3")

results <- final_data %>%
  filter(!is.na(u5mr_status)) %>%
  group_by(u5mr_status) %>%
  summarize(
    anc4_weighted = weighted.mean(anc4, births, na.rm = TRUE),
    sba_weighted = weighted.mean(sba, births, na.rm = TRUE),
    n_countries = sum(!is.na(births)),
    n_total = n(),
    coverage = paste0(round(n_countries / n_total * 100, 1), "%"),
    .groups = "drop"
  )


# Write results to HTML table 
html_table <- results %>%
  select(-coverage) %>%  # 👈 Omit the coverage column
  kable(
    format = "html",
    digits = 2,
    col.names = c("U5MR Status", "ANC4 Coverage", "SBA Coverage", 
                  "Countries with Data", "Total Countries"),
    caption = "Table 1. Population-Weighted Coverage by U5MR Status Group"
  ) %>%
  kable_styling(full_width = FALSE)


results_grouped <- results %>%
  mutate(
    u5mr_group = case_when(
      u5mr_status == "Achieved" ~ "Achieved",
      u5mr_status == "On Track" ~ "On Track",
      u5mr_status == "Acceleration Needed" ~ "Acceleration Needed",
      TRUE ~ NA_character_
    )
  ) %>%
  group_by(u5mr_group) %>%
  summarize(
    anc4 = weighted.mean(anc4_weighted, n_countries),
    sba = weighted.mean(sba_weighted, n_countries),
    .groups = "drop"
  )

# Create custom x-axis labels with number of countries
group_sizes <- results %>%
  mutate(group_label = paste0(u5mr_status, "\n(n = ", n_countries, ")")) %>%
  select(u5mr_status, group_label)

# Prepare data for plotting
results_annotated <- results %>%
  rename(coverage_percent = coverage) %>%
  left_join(group_sizes, by = "u5mr_status") %>%
  pivot_longer(cols = c(anc4_weighted, sba_weighted),
               names_to = "indicator", values_to = "coverage") %>%
  mutate(indicator = recode(indicator, anc4_weighted = "ANC4", sba_weighted = "SBA"))

# Generate and save the annotated plot
ggplot_obj <- ggplot(results_annotated, aes(x = group_label, y = coverage, fill = indicator)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(values = c("#1f77b4", "#ff7f0e")) +
  labs(
    title = "Population-Weighted Health Service Coverage",
    x = "Under-5 Mortality Status Group",
    y = "Coverage (%)",
    fill = "Indicator"
  ) +
  theme_minimal(base_size = 14)

ggsave("coverage_plot.png", ggplot_obj, width = 8, height = 5)


# Write interpretation text for HTML report
writeLines(
  "### Interpretation\n\nThis analysis combines three publicly available data sources to examine maternal health service coverage in relation to progress toward under-five mortality (U5MR) targets. We calculate population-weighted averages for two indicators—antenatal care (ANC4) and skilled birth attendance (SBA)—using 2022 birth estimates from the UN World Population Prospects. Countries are grouped based on their U5MR classification: **Achieved**, **On Track**, or **Acceleration Needed**, per UNICEF’s tracking framework.\n\nAs shown in the figure, **countries that have achieved** the U5MR target demonstrate the highest population-weighted coverage: **over 90% for both ANC4 and SBA**. **Countries on track** show **mixed performance**, with high SBA coverage (~87%) but considerably lower ANC4 coverage (~57%). In contrast, **off-track countries** (acceleration needed) display the **lowest coverage**, averaging ~55% for ANC4 and ~69% for SBA.\n\nThese descriptive results underscore disparities in maternal health service access that correspond with progress toward child mortality goals. However, these patterns are not causal; they may reflect broader structural factors such as health system capacity, governance, or conflict. \n\n  Note: The “On Track” group includes only 4 countries. While the SBA coverage is relatively high (~87%), the small group size may limit generalizability. Interpret these results with caution. \n\n**Examples** of countries in each group:\n\n- **Achieved**: Australia, Paraguay, Malaysia  \n- **On Track**: Egypt, Mongolia, Algeria  \n- **Acceleration Needed**: Mauritania, Zimbabwe, Chad\n",
  "interpretation.md"
)

# Write RMarkdown report
report_lines <- c(
  "---",
  "title: 'Health Service Coverage Report'",
  "output: html_document",
  "---",
  "",
  "```{r, echo=FALSE, fig.align='center'}",
  "knitr::include_graphics('coverage_plot.png')",
  "```",
  "",
  "```{r, results='asis', echo=FALSE}" ,
  "cat(readLines('interpretation.md'), sep = '\n')",
  "```",
  "",
  "```{r, echo=FALSE, results='asis'}",
  "html_table",
  "```"
)

writeLines(report_lines, "report.Rmd")
rmarkdown::render("report.Rmd", output_file = "final_report.html")
