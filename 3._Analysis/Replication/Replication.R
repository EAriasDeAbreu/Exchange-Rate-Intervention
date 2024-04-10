# ******************************************************************************
# ******************************************************************************
# *Authors: 
# *Coder: Edmundo Arias De Abreu
# *Project: HE2 Project
# *Data: Panel.xlsx
# *Stage: Replication <- Echavarria, Melo & Villamizar, 2014
# 
# *Last checked: 07.04.2024
# 
# /*
# ******************************************************************************
# *                                 Contents                                   *
# ******************************************************************************
#   
# This script aims to replicate the results of the 2014 paper: 
# "The Impact of Foreign Exchange Intervention in  Colombia. An Event Study 
# Approach" by Echavarria, Melo & Villamizar (2014)
#
#
#     Inputs:
#       - Panel.xlsx
# 
#     Output:
#       - Results
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
library(kableExtra)
library(knitr)      # For summary stats 
library(scales)
library(lubridate)

# ---------------------------------------------------------------------------- #
# Data Import 
# ---------------------------------------------------------------------------- #

# Import Panel
df <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/Proyecto/Exchange Rate Intervention & Effectiveness/Data/Panel.xlsx", col_types = c("date", "numeric", "text", "numeric", "numeric", "numeric"))
df$Date <- as.Date(df$Date)

# Restrict to author's period range (2002 - 2012)
df$Year <- format(df$Date, "%Y")
df <- df %>%
  filter(Year >= "2002" & Year <= "2012")

# ---------------------------------------------------------------------------- #
# Exclude announced interventions and day-to-day constant
# ---------------------------------------------------------------------------- #




# ---------------------------------------------------------------------------- #
# Success: Direction Criterion
# ---------------------------------------------------------------------------- #














# ---------------------------------------------------------------------------- #
# Intervention Critera: See p.16
# ---------------------------------------------------------------------------- #










# 2 day pause period -----------------------------------------------------------

