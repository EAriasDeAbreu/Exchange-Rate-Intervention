*****************************************************************************
*Distribuciones resultados
*****************************************************************************

cls

clear all

set more off

cd "C:\Users\Lenovo\OneDrive - Universidad de los Andes\Septimo Semestre\HE BC\Edmundo Andres Arias De Abreu\HE2 – Talleres\Proyecto\FX-Intervention\8._Extension Final\2._ProcessedData\Long"


forvalues i = 2/31{
	
use "CS/res_pur_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca res_pur_`i' = t
clear
}



forvalues i = 2/5{
	
use "CS/res_sal_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca res_sal_`i' = t
clear
}

forvalues i = 2/10{
	
use "CS/res_dis_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca disc_`i' = t
clear
}

forvalues i = 2/18{
	
use "CS/vol_pur_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca vol_pur_`i' = t
clear
}

forvalues i = 2/14{
	
use "CS/vol_sal_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca vol_sal_`i' = t
clear
}



import excel using "panelxx.xlsx", sheet("dists") first
gen res_pur =.
gen res_sal =.
gen disc = .
gen vol_pur = .
gen vol_sal =.

forvalues i = 2/31{
replace res_pur = res_pur_`i' if ene == `i'
}
forvalues i = 2/5{
replace res_sal = res_sal_`i' if ene == `i'
}
forvalues i = 2/10{
replace disc = disc_`i' if ene == `i'
}
forvalues i = 2/18{
replace vol_pur = vol_pur_`i' if ene == `i'
}
forvalues i = 2/14{
replace vol_sal = vol_sal_`i' if ene == `i'
}



kdensity res_pur, 

kdensity res_sal

kdensity disc 

kdensity vol_pur 

kdensity vol_sal 



