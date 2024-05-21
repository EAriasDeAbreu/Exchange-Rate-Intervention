cls
clear all
set more off

cd "C:\Users\Lenovo\OneDrive - Universidad de los Andes\Septimo Semestre\HE BC\Edmundo Andres Arias De Abreu\HE2 – Talleres\Proyecto\FX-Intervention\8._Extension Final\2._ProcessedData\Long"

import excel using "panel_vol", first

save "panel_vol", replace



replace country = "Australia" if country == "AUS"
replace country = "Brazil" if country == "BRA"
replace country = "Colombia" if country == "COL"
replace country = "New Zealand" if country == "NZL"
replace country = "Hungary" if country == "HUN"
replace country = "Czechia" if country == "CZC"
replace country = "Russia" if country == "RUS"
replace country = "India" if country == "IND"
replace country = "Indonesia" if country == "INDO"
replace country = "Malasya" if country == "MAL"
replace country = "Uruguay" if country == "URU"
replace country = "Chile" if country == "CHI"
replace country = "Mexico" if country == "MEX"
replace country = "Canada" if country == "CAN"
replace country = "Poland" if country == "POL"
replace country = "Korea" if country == "KOR"
replace country = "Singapore" if country == "SIN"
replace country = "Norway" if country == "NOR"
replace country = "Sweden" if country == "SUE"
replace country = "Tailand" if country == "TAI"
replace country = "South Africa" if country == "SUD"

rename Date date
save "panel_vol_pais", replace

clear

import excel using "Long_imputed.xlsx", first

merge m:m date country using "panel_vol_pais.dta", nogenerate force

drop if country == "Uruguay"

save "base_final_garch.dta", replace

clear

*import delimited "Panel_long.csv"

*export excel "panelxx.xlsx", first(var) 
import excel using "panelxx.xlsx", first 
gen dei = date(date, "YMD")

replace dei = 14612 if dei == .
format dei %td
drop date

gen date = dei
drop dei



replace country = "Australia" if country == "AUS"
replace country = "Brazil" if country == "BRA"
replace country = "Colombia" if country == "COL"
replace country = "New Zealand" if country == "NZL"
replace country = "Hungary" if country == "HUN"
replace country = "Czechia" if country == "CZC"
replace country = "Russia" if country == "RUS"
replace country = "India" if country == "IND"
replace country = "Indonesia" if country == "INDO"
replace country = "Malasya" if country == "MAL"
replace country = "Uruguay" if country == "URU"
replace country = "Chile" if country == "CHI"
replace country = "Mexico" if country == "MEX"
replace country = "Canada" if country == "CAN"
replace country = "Poland" if country == "POL"
replace country = "Korea" if country == "KOR"
replace country = "Singapore" if country == "SIN"
replace country = "Norway" if country == "NOR"
replace country = "Sweden" if country == "SUE"
replace country = "Tailand" if country == "TAI"
replace country = "South Africa" if country == "SUD"


keep date country intervention tipo purchases sales type

merge m:m country date using  "base_final_garch", nogenerate

drop if country  == "Uruguay"
drop if country == "USA"

save "long_imputed_interv.dta", replace

export excel using "long_imputed_interv.xlsx", first(var) replace
