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

#path  <- "C:\\Users\\Nicolas\\OneDrive - Universidad de los andes\\UNIVERSIDAD\\7. SEPTIMO SEMESTRE\\MACRO DESDE LA BANCA CENTRAL\\PROYECTO"
path <- "C:\\Users\\Lenovo\\OneDrive - Universidad de los Andes\\Septimo Semestre\\HE BC\\Edmundo Andres Arias De Abreu\\HE2 – Talleres\\Proyecto\\FX-Intervention"

#df <- read_dta(paste(path,"\\Exchange-Rate-Intervention\\8._ControlSynt\\FX\\processed\\Base_sin_embi.dta", sep=""))
df <- read_dta(paste(path,"\\8._ControlSynt\\FX\\processed\\Base_sin_embi.dta", sep=""))
df$Date <- as.Date(df$f)

df$f  <- NULL

#intervenciones <- read_excel(paste(path,"\\Exchange-Rate-Intervention\\2._ProcessedData\\Panel.xlsx", sep=""), col_types = c("date", "numeric", "text", "numeric", "numeric", "numeric"))
intervenciones <- read_excel(paste(path,"\\2._ProcessedData\\Panel.xlsx", sep=""), col_types = c("date", "numeric", "text", "numeric", "numeric", "numeric"))


intervenciones$Type[is.na(intervenciones$Type)] <- "No hubo intervencion"

intervenciones$Sales[is.na(intervenciones$Sales)] <- 0

intervenciones$Purchases[is.na(intervenciones$Purchases)] <- 0

intervenciones$Date <- as.Date(intervenciones$Date)


intervenciones$tipo <- factor(intervenciones$Type, levels = c("No hubo intervencion", "Calls (IR decumulation)", "Calls (volatility control)", "Direct Purchase Auction", "Discretionary", "Puts (accumulation of IR)","Puts (volatility control)", "Forwards", "FX Swaps Purchase", "FX Swaps Sale"), 
                  exclude =NA)

intervenciones$tipo  <- as.numeric(intervenciones$tipo) -1
# ---------------------------------------------------------------------------- #
# Sacamos growth rates y estandarizamos tasas de cambio
# ---------------------------------------------------------------------------- #

df  <- df %>%
  filter(!(wday(Date) %in% c(1, 7)))


tasas <- select(df, ends_with("tc")) 

df <- df %>%
  select(-ends_with("tc"))

cambios_porcentuales <- tasas %>%
  mutate(across(everything(), ~c(NA, (.x[-1] / .x[-length(.x)]) - 1)))

cambios_porcentuales <- cambios_porcentuales %>%
  mutate(across(everything(), ~scale(.x, center = TRUE, scale = TRUE)))

cambios_porcentuales$Date  <- df$Date

df <- merge(df, cambios_porcentuales, by = "Date")

# ---------------------------------------------------------------------------- #
# Merge con bd de intervenciones
# ---------------------------------------------------------------------------- #

df <- merge(intervenciones, df, by = "Date")

#write.xlsx(df, file = paste(path,"\\Exchange-Rate-Intervention\\8._ControlSynt\\FX\\processed\\Control_Synth.xlsx", sep=""), colNames = TRUE)
write.xlsx(df, file = paste(path,"\\8._ControlSynt\\FX\\processed\\Control_Synth.xlsx", sep=""), colNames = TRUE)