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
#   lubriDate
# )

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

#path  <- "\\Users\\edmundoarias\\Documents\\Uniandes\\2024-10\\HE 2\\Proyecto"

path  <- "C:\\Users\\Nicolas\\OneDrive - Universidad de los andes\\UNIVERSIDAD\\7. SEPTIMO SEMESTRE\\MACRO DESDE LA BANCA CENTRAL\\PROYECTO"

df <- read_excel(paste(path,"\\Exchange-Rate-Intervention\\2._ProcessedData\\Panel.xlsx", sep=""), col_types = c("date", "numeric", "text", "numeric", "numeric", "numeric"))

# colnames(df)[4] <- "f"
# colnames(df)[5] <- "Sales"
# colnames(df)[4] <- "Purchases"

df$Date <- as.Date(df$Date)

# Restrict to author's period range (2002 - 2012)
df$Year <- format(df$Date, "%Y")
df <- df %>%
  filter(Year >= "2002" & Year <= "2024")


df$Type[is.na(df$Type)] <- "No hubo intervencion"

df$Sales[is.na(df$Sales)] <- 0

df$Purchases[is.na(df$Purchases)] <- 0

df$tipo <- factor(df$Type, levels = c("No hubo intervencion", "Calls (IR decumulation)", "Calls (volatility control)", "Direct Purchase Auction", "Discretionary", "Puts (accumulation of IR)","Puts (volatility control)", "Forwards", "FX Swaps Purchase", "FX Swaps Sale"), 
                  exclude =NA)

df$tipo  <- as.numeric(df$tipo) -1

# ---------------------------------------------------------------------------- #
# Events
# ---------------------------------------------------------------------------- #

# df  <- df[df$tipo != 3, ]

df$evento_directas <- NA
df$evento_forwards <- NA
df$evento_swaps_compra <- NA
df$evento_swaps_venta <- NA
df$evento_acc <- NA
df$evento_desacc <- NA
df$evento_discr <- NA
df$evento_svol <- NA
df$evento_pvol <- NA
total_eventos  <- 1
eventos_acc = 0
eventos_desacc = 0
eventos_discr = 0
eventos_svol = 0
eventos_pvol = 0
tipo =0

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=5){
    df$evento_acc[i] =0
    i=i+1
  }
  if(df$tipo[i]==5){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_acc[i])){
      df$evento_acc[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 5){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_acc[j] = total_eventos
      }
      else{
        df$evento_acc[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_acc = eventos_acc +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=2){
    df$evento_svol[i] =0
    i=i+1
  }
  if(df$tipo[i]==2){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_svol[i])){
      df$evento_svol[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 2){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_svol[j] = total_eventos
      }
      else{
        df$evento_svol[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_svol = eventos_svol +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=1){
    df$evento_desacc[i] =0
    i=i+1
  }
  if(df$tipo[i]==1){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_desacc[i])){
      df$evento_desacc[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 1){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_desacc[j] = total_eventos
      }
      else{
        df$evento_desacc[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_desacc = eventos_desacc +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=4){
    df$evento_discr[i] =0
    i=i+1
  }
  if(df$tipo[i]==4){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_discr[i])){
      df$evento_discr[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 4){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_discr[j] = total_eventos
      }
      else{
        df$evento_discr[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_discr =eventos_discr +1
      }
    }
  }
  print(i)
}


i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=6){
    df$evento_pvol[i] =0
    i=i+1
  }
  if(df$tipo[i]==6){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_pvol[i])){
      df$evento_pvol[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 6){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_pvol[j] = total_eventos
      }
      else{
        df$evento_pvol[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_pvol =eventos_pvol +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=7){
    df$evento_forwards[i] =0
    i=i+1
  }
  if(df$tipo[i]==7){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_forwards[i])){
      df$evento_forwards[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 7){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_forwards[j] = total_eventos
      }
      else{
        df$evento_forwards[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_acc = eventos_acc +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=8){
    df$evento_swaps_compra[i] =0
    i=i+1
  }
  if(df$tipo[i]==8){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_swaps_compra[i])){
      df$evento_swaps_compra[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 8){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_swaps_compra[j] = total_eventos
      }
      else{
        df$evento_swaps_compra[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_acc = eventos_acc +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=9){
    df$evento_swaps_venta[i] =0
    i=i+1
  }
  if(df$tipo[i]==9){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_swaps_venta[i])){
      df$evento_swaps_venta[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 9){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_swaps_venta[j] = total_eventos
      }
      else{
        df$evento_swaps_venta[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_acc = eventos_acc +1
      }
    }
  }
  print(i)
}

i=1
while(i< length(df$Date)){
  if(df$tipo[i]!=3){
    df$evento_directas[i] =0
    i=i+1
  }
  if(df$tipo[i]==3){
    if(i+5 <=length(df$Date)){
      k=i+5
    }
    else{
      k = length(df$Date)
    }
    if(is.na(df$evento_directas[i])){
      df$evento_directas[i] = total_eventos
    }
    encontro =FALSE
    for(j in k:(k-4)){
      if(df$tipo[j] == 3){
        encontro = TRUE
        i = j
      }
      if(encontro){
        df$evento_directas[j] = total_eventos
      }
      else{
        df$evento_directas[j] = 0
      }
      if(j == k-4 && encontro){
          
      }
      else if(j == k-4 && !encontro){
        i = k
        total_eventos = total_eventos+1
        eventos_acc = eventos_acc +1
      }
    }
  }
  print(i)
}

# # ---------------------------------------------------------------------------- #
# # DB of Events
# # ---------------------------------------------------------------------------- #

eventos <- data.frame(matrix(ncol = 20, nrow = 0),stringsAsFactors = FALSE)

i = 1
while(i  < length(df$evento_acc)){
  if(df$evento_acc[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_acc[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Purchases[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_acc[i]){
      monto = monto + df$Purchases[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }

    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_desacc)){
  if(df$evento_desacc[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
     tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_desacc[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Sales[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_desacc[i]){
      monto = monto + df$Sales[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }


    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_discr)){
  if(df$evento_discr[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_discr[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Purchases[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_discr[i]){
      monto = monto + df$Purchases[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }


    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_pvol)){
  if(df$evento_pvol[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
     tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_pvol[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Purchases[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_pvol[i]){
      monto = monto + df$Purchases[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }


    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_svol)){
  if(df$evento_svol[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_svol[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Sales[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_svol[i]){
      monto = monto + df$Sales[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }


    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_directas)){
  if(df$evento_directas[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_directas[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Purchases[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_directas[i]){
      monto = monto + df$Purchases[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }

    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_forwards)){
  if(df$evento_forwards[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_forwards[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Sales[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_forwards[i]){
      monto = monto + df$Sales[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }

    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_swaps_compra)){
  if(df$evento_swaps_compra[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_swaps_compra[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Purchases[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_swaps_compra[i]){
      monto = monto + df$Purchases[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }

    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}

i = 1
while(i  < length(df$evento_swaps_venta)){
  if(df$evento_swaps_venta[i]!=0){
    
    if ((i-5)>0){
      dif=5
    }
    else{
      dif=1
    }

    fecha_antes = df$Date[i-dif]
    tasa_antes5= df$Exchange.Rate[i-dif]
    tasa_antes1= df$Exchange.Rate[i-1]
    tasa_prom_antes = 0
    
    for(j in (i-1):(i-dif)){
        tasa_prom_antes = tasa_prom_antes + df$Exchange.Rate[j]
    }
    tasa_prom_antes= tasa_prom_antes/dif

    fecha_inicial = df$Date[i]
    num_evento = df$evento_swaps_venta[i]
    id_tipo =df$tipo[i]
    tipo =as.character(df$Type[i])
    duracion = 1
    tasa_inicial = df$Exchange.Rate[i]
    tasa_prom = tasa_inicial
    monto = df$Sales[i]
    cambio_promedio = 0
    i=i+1
    while (num_evento == df$evento_swaps_venta[i]){
      monto = monto + df$Sales[i]
      duracion = duracion +1
      cambio_promedio = cambio_promedio + (df$Exchange.Rate[i]-df$Exchange.Rate[i-1])
      tasa_prom = tasa_prom + df$Exchange.Rate[i]
      i = i+1
    }

    tasa_prom_desp =0

    for(h in i:(i+4)){
        tasa_prom_desp = tasa_prom_desp + df$Exchange.Rate[h]
    }
    tasa_prom_desp= tasa_prom_desp/5

    fecha_ult_int = df$Date[i-1]
    fecha_ventana = df$Date[i+4]
    tasa_ultima_int = df$Exchange.Rate[i-1]
    tasa_desp1 = df$Exchange.Rate[i]
    tasa_desp5 = df$Exchange.Rate[i+4]
    monto_promedio = monto/duracion
    tasa_prom = tasa_prom/duracion
    cambio_tasa = tasa_desp5 - tasa_antes5
    cambio_promedio=cambio_promedio/duracion

    vec_evento = c(fecha_antes, fecha_inicial, fecha_ult_int, fecha_ventana, as.character(tipo), id_tipo, duracion, monto, monto_promedio, tasa_antes5,tasa_antes1,tasa_inicial, tasa_ultima_int, tasa_desp1, tasa_desp5, cambio_tasa, cambio_promedio,tasa_prom_antes,tasa_prom,tasa_prom_desp)
  
    eventos = rbind(eventos,as.list(vec_evento))
  }
  i=i+1
  print(i)
}


colnames(eventos) <- c("Fecha_Pre5", "Fecha_Inicial", "Fecha_Ultima_Intervencion", "Fecha_Post5", "Tipo","Id_Tipo","Duracion", "Monto", "Monto_Promedio_Dia","Tasa_Pre5","Tasa_Pre1","Tasa_Inicial","Tasa_Ultima_Intervencion","Tasa_Post1", "Tasa_Post5","Cambio_Tasa","Cambio_Promedio","Tasa_Pre_Promedio","Tasa_Promedio","Tasa_Post_Promedio")

eventos$Fecha_Inicial = as.Date(eventos$Fecha_Inicial)
eventos$Fecha_Ultima_Intervencion = as.Date(eventos$Fecha_Ultima_Intervencion)
eventos$Fecha_Post5 = as.Date(eventos$Fecha_Post5)
eventos$Fecha_Pre5 = as.Date(eventos$Fecha_Pre5)
eventos$Tipo  <- as.character(eventos$Tipo)

eventos$Tipo[eventos$Id_Tipo==9] <- "FX Swaps Sale"
eventos$Tipo[eventos$Id_Tipo==8] <- "FX Swaps Purchase"
eventos$Tipo[eventos$Id_Tipo==7] <- "Forwards"
eventos$Tipo[eventos$Id_Tipo==6] <- "Puts (volatility control)"
eventos$Tipo[eventos$Id_Tipo==5] <- "Puts (accumulation of IR)"
eventos$Tipo[eventos$Id_Tipo==4] <- "Discretionary"
eventos$Tipo[eventos$Id_Tipo==3] <- "Direct Purchase Auction"
eventos$Tipo[eventos$Id_Tipo==2] <- "Calls (volatility control)"
eventos$Tipo[eventos$Id_Tipo==1] <- "Calls (IR decumulation)"

eventos <- eventos %>% arrange(Fecha_Inicial)

write.xlsx(eventos, file = paste(path,"\\Exchange-Rate-Intervention\\2._ProcessedData\\eventos.xlsx", sep=""), colNames = TRUE)

# # ---------------------------------------------------------------------------- #
# # Exclude announced interventions and day-to-day constant
# # ---------------------------------------------------------------------------- #




# # ---------------------------------------------------------------------------- #
# # Success: Direction Criterion
# # ---------------------------------------------------------------------------- #














# # ---------------------------------------------------------------------------- #
# # Intervention Critera: See p.16
# # ---------------------------------------------------------------------------- #










# # 2 day pause period -----------------------------------------------------------

