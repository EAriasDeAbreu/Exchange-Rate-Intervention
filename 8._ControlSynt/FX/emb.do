cls
clear all
set more off

cd "C:\Users\Lenovo\OneDrive - Universidad de los Andes\Septimo Semestre\HE BC\Edmundo Andres Arias De Abreu\HE2 – Talleres\Proyecto\FX-Intervention\8._ControlSynt\FX"

import excel using "processed/Control_Synth.xlsx", first cellrange("A1:EE5287")

foreach i in AUS COL BRA HUN IND INDO KOR MEX MAL NOR POL RUS SIN NZL SUD SUE TAI CHI CAN CZC URU{
	gen `i'_emb = `i'_tpm - USA_tpm
	
destring `i'_tc, replace 
} 


reg COL_tc COL_x COL_m COL_emb COL_ov COL_tpm COL_pi

save "processed/Control_Synth_emb.dta", replace

export excel using "processed/Control_Synth_emb.xlsx", cell("A1") first(var) 