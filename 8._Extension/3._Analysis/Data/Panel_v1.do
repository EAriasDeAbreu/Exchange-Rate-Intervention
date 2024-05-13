********************************************************************************
********************************************************************************
*Authors: 
*Coder: Edmundo Arias De Abreu
*Project: HE2 Project
*Data: FXI_Panel.dta
*Stage: Data Cleaning

*Last checked: 28.04.2024

/*
********************************************************************************
*                                 Contents                                     *
********************************************************************************

	

********************************************************************************
*/

*Prepare the terminal
clear
cls

*Set graph format
set scheme s2mono
grstyle init
grstyle set plain, horizontal box
grstyle color background white
grstyle set color navy gs5 gs10
grstyle set color gs10: major_grid
grstyle set lp solid dash dot 
grstyle set symbol circle triangle diamond X
grstyle set legend 6, nobox
graph set window fontface "Garamond"


********************************************************************************
*                                                                              *
*                           Import and Clean 'FXI_Panel'                       *
*                                                                              *
********************************************************************************

use "/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/2._ProcessedData/FXI_Panel.dta", clear

drop index

*------------------------------- Rename & Label -------------------------------#

* Country Data
label var ifscode "IMF Country Code ID"

rename country ctr
	label var ctr "Country Name"
	
label var ISO "Country 3 Letter ID"


label var period "Year-Month Period ID"

label var ctr_nomxr "Country Nominal Exchange Rate (in respect to USD)"

label var ctr_rexr "Country Real Effective Exchange Rate (by CPI)"

rename ctr_irr ctr_iir
	label var ctr_iir "Country Interbank/Overnight Nominal Interest Rate"
	
label var ctr_stir "Country Short-Term Nominal Interest Rate"

label var ctr_ltir "Country Long-Term Nominal Interest Rate"

label var ctr_spi "Country Share Price Index == 2015"


* Intervention Data – Estimated by IMF
label var FXI_spot_proxy_USD_m "Spot FXI Proxied in Millions of USD, monthly"

label var FXI_broad_proxy_USD_m "Total FXI Proxied in Millions of USD"

label var FXI_spot_proxy_GDP_m "Spot FXI Proxied in percentage points of (3-year moving average) GDP"

label var FXI_deriv_proxy_GDP_m "Derivatives FXI Proxied in percentage points of (3-year moving average) GDP"

label var FXI_broad_proxy_GDP_m "Total FXI Proxied in percentage points of (3-year moving average) GDP"

label var FXI_deriv_proxy_USD_m "Derivatives FXI Proxied in Millions of USD"

* Intervention Data – Published by Reporting Country
label var FXI_spot_pub_USD_m "Spot FXI Published in Millions of USD"

label var FXI_deriv_pub_USD_m "Derivatives FXI Published in Millions of USD"

label var FXI_broad_pub_USD_m "Total FXI Published in Millions of USD"

label var FXI_spot_pub_GDP_m "Spot FXI Published in percentage points of (3-year moving average) GDP"

label var FXI_deriv_pub_GDP_m "Derivatives FXI Published in percentage points of (3-year moving average) GDP"

label var FXI_broad_pub_GDP_m "Total FXI Published in percentage points of (3-year moving average) GDP"

* Other data available
label var Sterilization_dummy "Sterilization dummy based on the changes in short-term interest rate (1 = Fully Sterilized, 0 = Not Fully Sterilized)"

label var De_facto_EXR_regime "De facto exchange rate regime dummy based on IMF AREAER annual report (0 = Non Peg, 1= Peg)"

label var De_jure_EXR_regime "De jure exchnage rate regime dummy based on IMF AREAER annual report (0 = Non Peg, 1= Peg)"


********************************************************************************
*                                                                              *
*                                  Panel Set Up                                *
*                                                                              *
********************************************************************************

* Gen a date-indicating variable
gen temp_period = monthly(period, "YM")
drop period
rename temp_period period
format period %tm  // Apply a time format that displays as year-month

xtset ifscode period

xtsum

* Final re-ordering
order ifscode period ctr ISO year month ctr_nomxr ctr_rexr ctr_iir ctr_stir ctr_ltir ctr_spi FXI_spot_proxy_USD_m FXI_deriv_proxy_USD_m FXI_broad_proxy_USD_m FXI_spot_proxy_GDP_m FXI_deriv_proxy_GDP_m FXI_broad_proxy_GDP_m FXI_spot_pub_USD_m FXI_deriv_pub_USD_m FXI_broad_pub_USD_m FXI_spot_pub_GDP_m FXI_deriv_pub_GDP_m FXI_broad_pub_GDP_m Sterilization_dummy De_facto_EXR_regime De_jure_EXR_regime

sort ctr period


// Save Dataset
save "/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/2._ProcessedData/Ready/Panel_v1.dta", replace
