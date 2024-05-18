# ******************************************************************************
# ******************************************************************************
# *Authors: 
# *Coder: Edmundo Arias De Abreu
# *Project: HE2 Project
# *Data: FinalData.csv
# *Stage: Synth Loop Estimation <-  10-Day Events
# 
# *Last checked: 18.05.2024
# 
# /*
# ******************************************************************************
# *                                 Contents                                   *
# ******************************************************************************
#   
# This script aims to build the core panel to be used throughout the project.
# Specifically, it will be a day-exchange rate panel containing data on exactly
# when the Colombia central bank (BR) intervened (and through which mechanisms)
# in the Colombian exchange rate market. 
#
#
#     Inputs:
#       - FX_Intervention.xlsx
#       - Exch_Rate.xlsx
# 
#     Output:
#       - Panel.xlsx
# 
# ******************************************************************************
# Clear the Environment
# ---------------------------------------------------------------------------- #

rm(list = ls())

# ---------------------------------------------------------------------------- #
# Load Necessary Libraries
# ---------------------------------------------------------------------------- #
library(tidyverse)
library(dplyr)
library(ggplot2)
library(readxl)
library(openxlsx)

# Exercise Specific
library(VIM)  # For KNN Imputation
library(DMwR2) # For KNN Imputation
library(Synth)  # For estimating Synth Control
library(zoo)

# ---------------------------------------------------------------------------- #
# Data Import and Cleaning
# ---------------------------------------------------------------------------- #

# Import CSV file
df <- read.csv("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension Final/2._ProcessedData/Long/FinalData.csv")

# Drop rows where country is "USA"
df <- df %>%
  filter(country != "USA")

df <- df %>%
  filter(country != "URU")

# Create a numeric country ID unique identifier
df <- df %>%
  mutate(id = as.numeric(factor(country)))   # Colombia is 5 !

# Ensure the 'id' column is numeric
df$id <- as.numeric(df$id)

# Fix NA values in country
df <- df %>%
  group_by(id) %>%
  mutate(country = unique(country[!is.na(country)])) %>%
  ungroup()

# Check for unique mapping between id and country
unique_mapping <- df %>%
  select(id, country) %>%
  distinct()

if (any(duplicated(unique_mapping$id))) {
  stop("Each 'id' must correspond to a unique 'country'. Please check your data.")
}

# ---------------------------------------------------------------------------- #
# Linear Interpolation Data Imputation
# ---------------------------------------------------------------------------- #

# Convert date to Date type and then to numeric
df$Date <- as.Date(df$Date)
df$Date_numeric <- as.numeric(df$Date)

# Balance the panel data by completing missing dates for each country
full_dates <- seq(min(df$Date), max(df$Date), by = "day")
full_panel <- expand.grid(id = unique(df$id), Date = full_dates)
df <- left_join(full_panel, df, by = c("id", "Date"))

# Ensure all numeric columns are present
numeric_columns <- c("Purchases", "Sales", "imports", "exports", "night_rate", "tpm", "pi", "ExRate", "embi", "net")
missing_columns <- setdiff(numeric_columns, colnames(df))
if(length(missing_columns) > 0) {
  df[missing_columns] <- NA
}

# Interpolate numeric columns to handle any new NAs introduced by balancing
df <- df %>%
  group_by(id) %>%
  mutate(across(all_of(numeric_columns), ~ {
    if (sum(!is.na(.)) > 1) {
      na.approx(., rule = 2)
    } else {
      .
    }
  })) %>%
  ungroup()

# Fix NA values in country
df <- df %>%
  group_by(id) %>%
  mutate(country = unique(country[!is.na(country)])) %>%
  ungroup()

# Replace missing values in Type, Intervention, and Treatment with 0
df <- df %>%
  mutate(Type = ifelse(is.na(Type), 0, Type),
         Intervention = ifelse(is.na(Intervention), 0, Intervention),
         treatment = ifelse(is.na(treatment), 0, treatment),
         tipo = ifelse(is.na(tipo), 0, tipo))

# Interpolate Date_numeric
df <- df %>%
  group_by(id) %>%
  mutate(Date_numeric = zoo::na.approx(Date_numeric, rule = 2)) %>%
  ungroup()

# Calculate the number of missing values in each column
missing_values <- colSums(is.na(df))
print(missing_values)


# Ensure Date_numeric is integer (if needed)
df$Date_numeric <- as.integer(df$Date_numeric)


# Initialize the event-related columns with NA values
df <- df %>%
  mutate(event_start = 0,
         event_end = 0,
         pre_window_start = 0,
         pre_window_end = 0,
         post_window_start = 0,
         post_window_end = 0)

# Calculate the number of missing values in each column
missing_values <- colSums(is.na(df))
print(missing_values)

# ---------------------------------------------------------------------------- #
# Define Pre & Post Event Windows
# ---------------------------------------------------------------------------- #

# Convert date to Date type and then to numeric
df$Date <- as.Date(df$Date)
df$Date_numeric <- as.numeric(df$Date)

# Identify treatment start points
df <- df %>%
  group_by(id) %>%
  arrange(Date) %>%
  mutate(cum_sales = cumsum(Sales)) %>%
  mutate(event_start = ifelse(lag(Sales, 9) > 0 & cum_sales - lag(cum_sales, 10) >= 10, 1, 0))

# Ensure there are enough pre-treatment periods
df <- df %>%
  mutate(event_end = ifelse(event_start == 1, Date + 9, NA)) %>%
  mutate(pre_window_start = ifelse(event_start == 1, Date - 10, NA),
         pre_window_end = ifelse(event_start == 1, Date - 1, NA),
         post_window_start = ifelse(event_start == 1, Date, NA),
         post_window_end = ifelse(event_start == 1, Date + 19, NA)) %>%
  ungroup()

# Print debug information for windows
print("Window information:")
print(df %>% filter(event_start == 1) %>% select(id, Date, pre_window_start, pre_window_end, post_window_start, post_window_end))

# ---------------------------------------------------------------------------- #
# Construct Synthetic Control for each Event
# ---------------------------------------------------------------------------- #

# Function to perform synthetic control for one event
synth_control <- function(data, event_index, treated_id) {
  event_date <- data$Date[event_index]
  pre_start <- event_date - 10
  pre_end <- event_date - 1
  post_start <- event_date
  post_end <- event_date + 19
  
  # Extract relevant data for this event
  event_data <- data %>%
    filter(Date >= pre_start & Date <= post_end)
  
  # Ensure 'id' and 'Date_numeric' are numeric
  event_data$id <- as.numeric(event_data$id)
  event_data$Date_numeric <- as.numeric(event_data$Date_numeric)
  
  # Convert event_data to a data frame
  event_data <- as.data.frame(event_data)
  
  # Balance the panel data by performing linear interpolation
  event_data <- event_data %>%
    complete(id, Date_numeric) %>%
    mutate(across(where(is.numeric), ~ na.approx(., rule = 2)))
  
  # Fix NA values in country
  event_data <- event_data %>%
    group_by(id) %>%
    mutate(country = unique(country[!is.na(country)])) %>%
    ungroup()
  
  # Remake (again) into dataframe
  event_data <- as.data.frame(event_data)
  
  # Print structure of event_data for debugging
  print(str(event_data))
  
  # Ensure required columns are present
  required_columns <- c("id", "Date_numeric", "imports", "exports", "night_rate", "tpm", "pi", "embi", "ExRate", "country")
  missing_columns <- setdiff(required_columns, colnames(event_data))
  if (length(missing_columns) > 0) {
    stop(paste("Missing columns:", paste(missing_columns, collapse = ", ")))
  }
  
  # Check column types
  print(sapply(event_data, class))
  
  # Ensure unique mapping between id and country in event_data
  unique_mapping_event <- event_data %>%
    select(id, country) %>%
    distinct()
  
  if (any(duplicated(unique_mapping_event$id))) {
    # Print problematic rows for debugging
    problematic_rows <- unique_mapping_event %>%
      filter(duplicated(id) | duplicated(id, fromLast = TRUE))
    print(problematic_rows)
    stop("Each 'id' must correspond to a unique 'country' in event_data. Please check your data.")
  }
  
  # Ensure time.predictors.prior has valid periods
  time_predictors_prior <- unique(event_data$Date_numeric[event_data$Date >= pre_start & event_data$Date <= pre_end])
  print("Time predictors prior periods:")
  print(time_predictors_prior)
  if (length(time_predictors_prior) == 0) {
    stop("No valid periods found for time.predictors.prior. Please check the pre-treatment window.")
  }
  
  # Prepare data for Synth
  dataprep.out <- dataprep(
    foo = event_data,
    predictors = c("imports", "exports", "night_rate", "tpm", "pi", "embi"),
    predictors.op = "mean",
    dependent = "ExRate",
    unit.variable = "id",
    time.variable = "Date_numeric",
    treatment.identifier = treated_id, # Colombia is treated unit with id 5
    controls.identifier = unique(event_data$id[event_data$id != treated_id]),
    time.predictors.prior = time_predictors_prior,
    time.optimize.ssr = time_predictors_prior,
    unit.names.variable = "country",
    time.plot = unique(event_data$Date_numeric[event_data$Date >= post_start & event_data$Date <= post_end])
  )
  
  # Run Synth
  synth.out <- synth(dataprep.out)
  
  # Extract the treatment effect
  treatment_effect <- synth.out$Y1 - synth.out$Y0.synth
  return(treatment_effect)
}

# Apply the function to each event and save treatment effects
treated_id <- 5
events <- which(df$event_start == 1 & df$id == treated_id)
treatment_effects <- sapply(events, function(event) synth_control(df, event, treated_id))

# ---------------------------------------------------------------------------- #
# Plot the Distribution of Treatment Effects
# ---------------------------------------------------------------------------- #
hist(treatment_effects, main = "Distribution of Treatment Effects", xlab = "Treatment Effect", breaks = 20)




#### Other
rm(list = ls())

# ---------------------------------------------------------------------------- #
# Load Necessary Libraries
# ---------------------------------------------------------------------------- #
library(tidyverse)
library(dplyr)
library(ggplot2)
library(readxl)
library(openxlsx)
library(VIM)  # For KNN Imputation
library(DMwR2) # For KNN Imputation
library(Synth)  # For estimating Synth Control
library(zoo)

# ---------------------------------------------------------------------------- #
# Data Import and Cleaning
# ---------------------------------------------------------------------------- #

# Import CSV file
df <- read.csv("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension Final/2._ProcessedData/Long/FinalData.csv")

# Drop rows where country is "USA" or "URU"
df <- df %>%
  filter(!country %in% c("USA", "URU"))

# Create a numeric country ID unique identifier
df <- df %>%
  mutate(id = as.numeric(factor(country)))   # Colombia is 5 !

# Ensure the 'id' column is numeric
df$id <- as.numeric(df$id)

# Fix NA values in country
df <- df %>%
  group_by(id) %>%
  mutate(country = unique(country[!is.na(country)])) %>%
  ungroup()

# Check for unique mapping between id and country
unique_mapping <- df %>%
  select(id, country) %>%
  distinct()

if (any(duplicated(unique_mapping$id))) {
  stop("Each 'id' must correspond to a unique 'country'. Please check your data.")
}

# ---------------------------------------------------------------------------- #
# Linear Interpolation Data Imputation
# ---------------------------------------------------------------------------- #
df$Date <- as.Date(df$Date)
df$Date_numeric <- as.numeric(df$Date)

# Balance the panel data by completing missing dates for each country
full_dates <- seq(min(df$Date), max(df$Date), by = "day")
full_panel <- expand.grid(id = unique(df$id), Date = full_dates)
df <- left_join(full_panel, df, by = c("id", "Date"))

# Ensure all numeric columns are present
numeric_columns <- c("Purchases", "Sales", "imports", "exports", "night_rate", "tpm", "pi", "ExRate", "embi", "net")
missing_columns <- setdiff(numeric_columns, colnames(df))
if (length(missing_columns) > 0) {
  df[missing_columns] <- NA
}

# Interpolate numeric columns to handle any new NAs introduced by balancing
df <- df %>%
  group_by(id) %>%
  mutate(across(all_of(numeric_columns), ~ {
    if (sum(!is.na(.)) > 1) {
      na.approx(., rule = 2)
    } else {
      .
    }
  })) %>%
  ungroup()

# Fix NA values in country
df <- df %>%
  group_by(id) %>%
  mutate(country = unique(country[!is.na(country)])) %>%
  ungroup()

# Replace missing values in categorical columns with 0
df <- df %>%
  mutate(Type = ifelse(is.na(Type), 0, Type),
         Intervention = ifelse(is.na(Intervention), 0, Intervention),
         treatment = ifelse(is.na(treatment), 0, treatment),
         tipo = ifelse(is.na(tipo), 0, tipo))

# Interpolate Date_numeric
df <- df %>%
  group_by(id) %>%
  mutate(Date_numeric = zoo::na.approx(Date_numeric, rule = 2)) %>%
  ungroup()

# Calculate the number of missing values in each column
missing_values <- colSums(is.na(df))
print(missing_values)

# Ensure Date_numeric is integer (if needed)
df$Date_numeric <- as.integer(df$Date_numeric)

# Initialize the event-related columns with 0 values
df <- df %>%
  mutate(event_start = 0,
         event_end = 0,
         pre_window_start = 0,
         pre_window_end = 0,
         post_window_start = 0,
         post_window_end = 0)

# Calculate the number of missing values in each column
missing_values <- colSums(is.na(df))
print(missing_values)

# ---------------------------------------------------------------------------- #
# Define Pre & Post Event Windows
# ---------------------------------------------------------------------------- #
df <- df %>%
  group_by(id) %>%
  arrange(Date) %>%
  mutate(cum_sales = cumsum(Sales)) %>%
  mutate(event_start = ifelse(lag(Sales, 9) > 0 & cum_sales - lag(cum_sales, 10) >= 10, 1, 0)) %>%
  ungroup()

df <- df %>%
  mutate(event_end = ifelse(event_start == 1, Date + 9, NA),
         pre_window_start = ifelse(event_start == 1, Date - 10, NA),
         pre_window_end = ifelse(event_start == 1, Date - 1, NA),
         post_window_start = ifelse(event_start == 1, Date, NA),
         post_window_end = ifelse(event_start == 1, Date + 19, NA)) %>%
  ungroup()

print("Window information:")
print(df %>% filter(event_start == 1) %>% select(id, Date, pre_window_start, pre_window_end, post_window_start, post_window_end))

# ---------------------------------------------------------------------------- #
# Construct Synthetic Control for each Event
# ---------------------------------------------------------------------------- #
synth_control <- function(data, event_index, treated_id) {
  event_date <- data$Date[event_index]
  pre_start <- event_date - 10
  pre_end <- event_date - 1
  post_start <- event_date
  post_end <- event_date + 19
  
  event_data <- data %>%
    filter(Date >= pre_start & Date <= post_end)
  
  full_dates <- seq(pre_start, post_end, by = "day")
  full_panel <- expand.grid(id = unique(event_data$id), Date = full_dates)
  event_data <- left_join(full_panel, event_data, by = c("id", "Date"))
  
  event_data <- event_data %>%
    group_by(id) %>%
    mutate(across(all_of(numeric_columns), ~ {
      if (sum(!is.na(.)) > 1) {
        na.approx(., rule = 2)
      } else {
        .
      }
    })) %>%
    ungroup()
  
  # Ensure 'id' and 'Date_numeric' are numeric
  event_data$id <- as.numeric(event_data$id)
  event_data$Date_numeric <- as.numeric(event_data$Date)
  
  # Check for any remaining NA or infinite values in the predictors
  check_na_inf <- function(x) {
    any(is.na(x)) || any(is.infinite(x))
  }
  
  predictors <- c("imports", "exports", "night_rate", "tpm", "pi", "embi")
  for (predictor in predictors) {
    if (check_na_inf(event_data[[predictor]])) {
      stop(paste("NA or infinite values found in predictor:", predictor))
    }
  }
  
  # Print structure of event_data for debugging
  print(str(event_data))
  
  required_columns <- c("id", "Date_numeric", "imports", "exports", "night_rate", "tpm", "pi", "embi", "ExRate", "country")
  missing_columns <- setdiff(required_columns, colnames(event_data))
  if (length(missing_columns) > 0) {
    stop(paste("Missing columns:", paste(missing_columns, collapse = ", ")))
  }
  
  print(sapply(event_data, class))
  
  unique_mapping_event <- event_data %>%
    select(id, country) %>%
    distinct()
  
  if (any(duplicated(unique_mapping_event$id))) {
    problematic_rows <- unique_mapping_event %>%
      filter(duplicated(id) | duplicated(id, fromLast = TRUE))
    print(problematic_rows)
    stop("Each 'id' must correspond to a unique 'country' in event_data. Please check your data.")
  }
  
  time_predictors_prior <- unique(event_data$Date_numeric[event_data$Date >= pre_start & event_data$Date <= pre_end])
  time_predictors_prior <- na.omit(time_predictors_prior)
  print("Time predictors prior periods:")
  print(time_predictors_prior)
  if (length(time_predictors_prior) == 0) {
    stop("No valid periods found for time.predictors.prior. Please check the pre-treatment window.")
  }
  
  time_plot <- unique(event_data$Date_numeric[event_data$Date >= post_start & event_data$Date <= post_end])
  time_plot <- na.omit(time_plot)
  print("Time plot periods:")
  print(time_plot)
  if (length(time_plot) == 0) {
    stop("No valid periods found for time.plot. Please check the post-treatment window.")
  }
  
  event_data <- as.data.frame(event_data)
  
  dataprep.out <- dataprep(
    foo = event_data,
    predictors = predictors,
    predictors.op = "mean",
    dependent = "ExRate",
    unit.variable = "id",
    time.variable = "Date_numeric",
    treatment.identifier = treated_id,
    controls.identifier = unique(event_data$id[event_data$id != treated_id]),
    time.predictors.prior = time_predictors_prior,
    time.optimize.ssr = time_predictors_prior,
    unit.names.variable = "country",
    time.plot = time_plot
  )
  
  synth.out <- synth(dataprep.out, optimxmethod='All')
  
  treatment_effect <- synth.out$Y1 - synth.out$Y0.synth
  return(treatment_effect)
}

treated_id <- 5
events <- which(df$event_start == 1 & df$id == treated_id)

print(events)

treatment_effects <- sapply(events, function(event_index) synth_control(df, event_index, treated_id))

hist(treatment_effects, main = "Distribution of Treatment Effects", xlab = "Treatment Effect", breaks = 20)


#######
rm(list = ls())

# ---------------------------------------------------------------------------- #
# Load Necessary Libraries
# ---------------------------------------------------------------------------- #
library(tidyverse)
library(dplyr)
library(ggplot2)
library(readxl)
library(openxlsx)
library(VIM)  # For KNN Imputation
library(DMwR2) # For KNN Imputation
library(Synth)  # For estimating Synth Control
library(zoo)

# ---------------------------------------------------------------------------- #
# Data Import and Cleaning
# ---------------------------------------------------------------------------- #

# Import CSV file
df <- read.csv("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension Final/2._ProcessedData/Long/FinalData.csv")

# Drop rows where country is "USA" or "URU"
df <- df %>%
  filter(!country %in% c("USA", "URU"))

# Create a numeric country ID unique identifier
df <- df %>%
  mutate(id = as.numeric(factor(country)))   # Colombia is 5 !

# Ensure the 'id' column is numeric
df$id <- as.numeric(df$id)

# Fix NA values in country
df <- df %>%
  group_by(id) %>%
  mutate(country = unique(country[!is.na(country)])) %>%
  ungroup()

# Check for unique mapping between id and country
unique_mapping <- df %>%
  select(id, country) %>%
  distinct()

if (any(duplicated(unique_mapping$id))) {
  stop("Each 'id' must correspond to a unique 'country'. Please check your data.")
}

# ---------------------------------------------------------------------------- #
# Linear Interpolation Data Imputation
# ---------------------------------------------------------------------------- #
df$Date <- as.Date(df$Date)
df$Date_numeric <- as.numeric(df$Date)

# Balance the panel data by completing missing dates for each country
full_dates <- seq(min(df$Date), max(df$Date), by = "day")
full_panel <- expand.grid(id = unique(df$id), Date = full_dates)
df <- left_join(full_panel, df, by = c("id", "Date"))

# Ensure all numeric columns are present
numeric_columns <- c("Purchases", "Sales", "imports", "exports", "night_rate", "tpm", "pi", "ExRate", "embi", "net")
missing_columns <- setdiff(numeric_columns, colnames(df))
if (length(missing_columns) > 0) {
  df[missing_columns] <- NA
}

# Interpolate numeric columns to handle any new NAs introduced by balancing
df <- df %>%
  group_by(id) %>%
  mutate(across(all_of(numeric_columns), ~ {
    if (sum(!is.na(.)) > 1) {
      na.approx(., rule = 2)
    } else {
      .
    }
  })) %>%
  ungroup()

# Fix NA values in country
df <- df %>%
  group_by(id) %>%
  mutate(country = unique(country[!is.na(country)])) %>%
  ungroup()

# Replace missing values in categorical columns with 0
df <- df %>%
  mutate(Type = ifelse(is.na(Type), 0, Type),
         Intervention = ifelse(is.na(Intervention), 0, Intervention),
         treatment = ifelse(is.na(treatment), 0, treatment),
         tipo = ifelse(is.na(tipo), 0, tipo))

# Interpolate Date_numeric
df <- df %>%
  group_by(id) %>%
  mutate(Date_numeric = zoo::na.approx(Date_numeric, rule = 2)) %>%
  ungroup()

# Calculate the number of missing values in each column
missing_values <- colSums(is.na(df))
print(missing_values)

# Ensure Date_numeric is integer (if needed)
df$Date_numeric <- as.integer(df$Date_numeric)

# Initialize the event-related columns with 0 values
df <- df %>%
  mutate(event_start = 0,
         event_end = 0,
         pre_window_start = 0,
         pre_window_end = 0,
         post_window_start = 0,
         post_window_end = 0)

# Calculate the number of missing values in each column
missing_values <- colSums(is.na(df))
print(missing_values)

# ---------------------------------------------------------------------------- #
# Define Pre & Post Event Windows
# ---------------------------------------------------------------------------- #
df <- df %>%
  group_by(id) %>%
  arrange(Date) %>%
  mutate(cum_sales = cumsum(Sales)) %>%
  mutate(event_start = ifelse(lag(Sales, 9) > 0 & cum_sales - lag(cum_sales, 10) >= 10, 1, 0)) %>%
  ungroup()

df <- df %>%
  mutate(event_end = ifelse(event_start == 1, Date + 9, NA),
         pre_window_start = ifelse(event_start == 1, Date - 10, NA),
         pre_window_end = ifelse(event_start == 1, Date - 1, NA),
         post_window_start = ifelse(event_start == 1, Date, NA),
         post_window_end = ifelse(event_start == 1, Date + 19, NA)) %>%
  ungroup()

print("Window information:")
print(df %>% filter(event_start == 1) %>% select(id, Date, pre_window_start, pre_window_end, post_window_start, post_window_end))

# ---------------------------------------------------------------------------- #
# Construct Synthetic Control for each Event
# ---------------------------------------------------------------------------- #
synth_control <- function(data, event_index, treated_id) {
  event_date <- data$Date[event_index]
  pre_start <- event_date - 10
  pre_end <- event_date - 1
  post_start <- event_date
  post_end <- event_date + 19
  
  event_data <- data %>%
    filter(Date >= pre_start & Date <= post_end)
  
  full_dates <- seq(pre_start, post_end, by = "day")
  full_panel <- expand.grid(id = unique(event_data$id), Date = full_dates)
  event_data <- left_join(full_panel, event_data, by = c("id", "Date"))
  
  # Interpolate numeric columns to handle any new NAs introduced by balancing
  event_data <- event_data %>%
    group_by(id) %>%
    mutate(across(all_of(numeric_columns), ~ {
      if (sum(!is.na(.)) > 1) {
        na.approx(., rule = 2)
      } else {
        .
      }
    })) %>%
    ungroup()
  
  # Ensure 'id' and 'Date_numeric' are numeric
  event_data$id <- as.numeric(event_data$id)
  event_data$Date_numeric <- as.numeric(event_data$Date)
  
  # Check for any remaining NA or infinite values in the predictors
  check_na_inf <- function(x) {
    any(is.na(x)) || any(is.infinite(x))
  }
  
  predictors <- c("imports", "exports", "night_rate", "tpm", "pi", "embi")
  for (predictor in predictors) {
    if (check_na_inf(event_data[[predictor]])) {
      stop(paste("NA or infinite values found in predictor:", predictor))
    }
  }
  
  # Print structure of event_data for debugging
  print(str(event_data))
  
  required_columns <- c("id", "Date_numeric", "imports", "exports", "night_rate", "tpm", "pi", "embi", "ExRate", "country")
  missing_columns <- setdiff(required_columns, colnames(event_data))
  if (length(missing_columns) > 0) {
    stop(paste("Missing columns:", paste(missing_columns, collapse = ", ")))
  }
  
  print(sapply(event_data, class))
  
  unique_mapping_event <- event_data %>%
    select(id, country) %>%
    distinct()
  
  if (any(duplicated(unique_mapping_event$id))) {
    problematic_rows <- unique_mapping_event %>%
      filter(duplicated(id) | duplicated(id, fromLast = TRUE))
    print(problematic_rows)
    stop("Each 'id' must correspond to a unique 'country' in event_data. Please check your data.")
  }
  
  time_predictors_prior <- unique(event_data$Date_numeric[event_data$Date >= pre_start & event_data$Date <= pre_end])
  time_predictors_prior <- na.omit(time_predictors_prior)
  print("Time predictors prior periods:")
  print(time_predictors_prior)
  if (length(time_predictors_prior) == 0) {
    stop("No valid periods found for time.predictors.prior. Please check the pre-treatment window.")
  }
  
  time_plot <- unique(event_data$Date_numeric[event_data$Date >= post_start & event_data$Date <= post_end])
  time_plot <- na.omit(time_plot)
  print("Time plot periods:")
  print(time_plot)
  if (length(time_plot) == 0) {
    stop("No valid periods found for time.plot. Please check the post-treatment window.")
  }
  
  event_data <- as.data.frame(event_data)
  
  dataprep.out <- dataprep(
    foo = event_data,
    predictors = predictors,
    predictors.op = "mean",
    dependent = "ExRate",
    unit.variable = "id",
    time.variable = "Date_numeric",
    treatment.identifier = treated_id,
    controls.identifier = unique(event_data$id[event_data$id != treated_id]),
    time.predictors.prior = time_predictors_prior,
    time.optimize.ssr = time_predictors_prior,
    unit.names.variable = "country",
    time.plot = time_plot
  )
  
  synth.out <- synth(dataprep.out, optimxmethod='All')
  
  treatment_effect <- synth.out$Y1 - synth.out$Y0.synth
  return(treatment_effect)
}

treated_id <- 5
events <- which(df$event_start == 1 & df$id == treated_id)

print(events)

treatment_effects <- sapply(events, function(event_index) synth_control(df, event_index, treated_id))

hist(treatment_effects, main = "Distribution of Treatment Effects", xlab = "Treatment Effect", breaks = 20)





