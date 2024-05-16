# ******************************************************************************
# ******************************************************************************
# *Authors:Arias, Gutierrez, Lozano, Paez, Sohed 
# *Coder: Nicolas Lozano Huertas
# *Project: HE2 Project
# *Data: Panel.xlsx
# *Stage: Synth Control & Extension <- Echavarria, Melo & Villamizar, 2014
# 
# *Last checked: 15.05.2024
# 
# /*
# ******************************************************************************
# Clear the Environment
# ---------------------------------------------------------------------------- #

rm(list = ls())

# ---------------------------------------------------------------------------- #
# Load Necessary Libraries
# ---------------------------------------------------------------------------- #
# require(pacman)

# p_load(
#   readxl,
#   dplyr,
#   forecast,
#   tidyverse,
#   lazyWeave,
#   stargazer,
#   openxlsx,
#   kableExtra,
#   knitr,
#   scales,
#   lubridate,
#   haven
# )

library(tidyverse)  # Essentials
library(readxl)     # For reading Excel files
library(openxlsx)   # For exporting Excel files
library(kableExtra)
library(knitr)      # For summary stats 
library(scales)
library(lubridate)
library(haven)
library(dplyr)

# ---------------------------------------------------------------------------- #
# Data Import 
# ---------------------------------------------------------------------------- #

path  <- "C:\\Users\\Nicolas\\OneDrive - Universidad de los andes\\UNIVERSIDAD\\7. SEPTIMO SEMESTRE\\MACRO DESDE LA BANCA CENTRAL\\PROYECTO"

df <- read_dta(paste(path,"\\Exchange-Rate-Intervention\\8._ControlSynt\\FX\\processed\\Base_sin_embi.dta", sep=""))

df$Date <- as.Date(df$f)

df$f  <- NULL

df  <- df %>%
  filter(!(wday(Date) %in% c(1, 7)))