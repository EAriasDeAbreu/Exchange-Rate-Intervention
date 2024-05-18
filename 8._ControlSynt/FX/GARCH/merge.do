cls
clear all
set more off

cd "C:\Users\Lenovo\OneDrive - Universidad de los Andes\Septimo Semestre\HE BC\Edmundo Andres Arias De Abreu\HE2 – Talleres\Proyecto\FX-Intervention\8._ControlSynt\FX"

import excel using "GARCH/vol.xlsx", first

merge m:m Date using "processed/Control_Synth_emb", nogenerate force

save "processed/Control_Synth_emb_vol"

export excel using "processed/Control_Synth_emb_vol.xlsx", first(var)