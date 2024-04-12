# ******************************************************************************
# ******************************************************************************
# *Authors: 
# *Coder: Edmundo Arias De Abreu
# *Project: HE2 Project
# *Data: FX_Intervention.xlsx + Exch_Rate.xlsx
# *Stage: Panel Building
# 
# *Last checked: 04.04.2024
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
library(tidyverse)  # Essentials
library(readxl)     # For reading Excel files
library(openxlsx)   # For exporting Excel files

# ---------------------------------------------------------------------------- #
# Data Import and Cleaning
# ---------------------------------------------------------------------------- #

# Import Excel files
intervention <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/Proyecto/Exchange Rate Intervention & Effectiveness/Data/FX_Intervention copy.xlsx")
e_rate <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/Proyecto/Exchange Rate Intervention & Effectiveness/Data/E_rate copy.xlsx")

# Replace NaN and NA values with 0 for 'intervention' dataframe
intervention <- data.frame(lapply(intervention, function(x) replace(x, is.na(x) | is.nan(x), 0)))

# Replace NaN and NA values with 0 for 'e_rate' dataframe
e_rate <- data.frame(lapply(e_rate, function(x) replace(x, is.na(x) | is.nan(x), 0)))

# Preview cleaned dataframes
View(intervention)
View(e_rate)

# ---------------------------------------------------------------------------- #
# Data Merging
# ---------------------------------------------------------------------------- #

# Merge to keep all rows from 'e_rate' and merge matching rows from 'intervention'
panel <- merge(e_rate, intervention, by = "Date", all.x = TRUE)

# View the merged dataframe
View(panel)

# ------------------------------------------------------------------------------
# Data Transformation
# ------------------------------------------------------------------------------

# Convert the 'Type' column into a categorical variable (factor)
panel$Type <- factor(panel$Type)

# 'Treatment' indicator variable -> 1 if BR intervened (sales or purchases)
panel <- panel %>%
  mutate(Intervention = if_else(is.na(Sales) | is.na(Purchases), 0, if_else(Sales > 0 | Purchases > 0, 1, 0)))

# Preview the transformed dataframe
View(panel)

# Export to Excel 
write.xlsx(panel, file = "/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/Proyecto/Exchange Rate Intervention & Effectiveness/Data/Panel.xlsx")

# End of Script
# ------------------------------------------------------------------------------



