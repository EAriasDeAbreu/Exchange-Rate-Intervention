# ******************************************************************************
# ******************************************************************************
# *Authors: 
# *Coder: Edmundo Arias De Abreu
# *Project: HE2 Project
# *Data: Raw Data
# *Stage: Extension <- Data Construction
# 
# *Last checked: 13.04.2024
# 
# /*
# ******************************************************************************
# *                                 Contents                                   *
# ******************************************************************************
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


fx <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/2._ProcessedData/Panel.xlsx")


# VIX -------------------------------------------------------------------------#

vix <- read_csv("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/1._RawData/VIX.csv")


# Dropping columns and renaming columns
vix <- vix %>%
  select(-Open, -High, -Low, -`Adj Close`, -Volume)

vix <- vix %>%
  rename(vix = Close)

      
# Merge with COP Exchange Rate
fx <- fx %>%
  left_join(vix, by = "Date")


# Colombian Int. Rate ---------------------------------------------------------#

ir <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/1._RawData/TipCol.xlsx")

# Merge with COP Exchange Rate
fx <- fx %>%
  left_join(ir, by = "Date")

# FED Int. Rate      ---------------------------------------------------------#

fed <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/1._RawData/FEDFUNDS.xlsx")

# Create a year-month column in both dataframes
fx$YearMonth <- floor_date(fx$Date, "month")
fed$YearMonth <- floor_date(fed$Date, "month")

# Merge the dataframes based on the YearMonth column
fx <- left_join(fx, fed, by = "YearMonth")

# Remove Merge Columns
fx$YearMonth <- NULL
fx$Date.y <- NULL

fx <- fx %>%
  rename(Date = Date.x)

fx$Country <- "Colombia"


# ---------------------------------------------------------------------------- #
# Country - Day Panel
# ---------------------------------------------------------------------------- #

# Create a sequence of dates from January 1, 2000 to March 31, 2024
dates <- seq(from = as.Date("2000-01-01"), to = as.Date("2024-03-31"), by = "day")

# List of OECD countries plus specified additional countries
countries <- c("Australia", "Austria", "Belgium", "Canada", "Chile", "Colombia", 
               "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", 
               "Greece", "Hungary", "Iceland", "Ireland", "Israel", "Italy", "Japan", 
               "Korea", "Latvia", "Lithuania", "Luxembourg", "Mexico", "Netherlands", 
               "New Zealand", "Norway", "Poland", "Portugal", "Slovak Republic", 
               "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "United Kingdom", 
               "United States", "Brazil", "Peru", "Ecuador", "China")

# Ensure each country appears only once in case of overlap
countries <- unique(countries)

# Create a data frame with every combination of country and date
country_day_panel <- expand.grid(Country = countries, Date = dates)



# Merge FX Data (real) based on 'Date'
panel <- left_join(country_day_panel, fx, by = "Date")

















