cls
clear all
set more off

cd "C:\Users\Lenovo\OneDrive - Universidad de los Andes\Septimo Semestre\HE BC\Edmundo Andres Arias De Abreu\HE2 – Talleres\Proyecto\FX-Intervention\8._ControlSynt\FX"

import excel using "data/TPM.xlsx", sheet("TPM") cellrange("A1:W82") first
tsset f
gen trim_tpm = quarter(f)

save "processed/tpm.dta", replace

clear


import excel using "data/TPM.xlsx", sheet("OVN") cellrange("A1:V244") first
tsset f
gen mes = month(f)
save "processed/ovn.dta", replace

clear


import excel using "data/X.xlsx", sheet("Hoja1") cellrange("A1:U244") first
tsset f
save "processed/x.dta", replace

clear


import excel using "data/M.xlsx", sheet("Hoja1") cellrange("A1:U244") first
tsset f
save "processed/m.dta", replace

clear

import excel using "data/TC.xlsx", sheet("Hoja1") cellrange("A1:U7397") first


gen AUS_t = 1/AUS_tc
drop AUS_tc
rename AUS_t AUS_tc


merge 1:m f using "processed/m.dta", nogenerate

merge 1:m f using "processed/x.dta", nogenerate

merge 1:m f using "processed/ovn.dta", nogenerate

merge 1:m f using "processed/tpm.dta", nogenerate

tsset f

gen n = _n

destring COL_ov CHI_m     RUS_m     IND_x     TAI_x     RUS_ov    BRA_tpm   NZL_tpm COL_m     SIN_m     INDO_x    IND_ov    BRA_ov    CAN_tpm   POL_tpm CZC_m     SUD_m     KOR_x     INDO_ov   CHI_ov    CHI_tpm   CZC_tpm HUN_m     SUE_m     MAL_x     MAL_ov      COL_tpm   RUS_tpm IND_m     TAI_m  MEX_x     SIN_ov    MEX_ov    KOR_tpm   SIN_tpm INDO_m    AUS_x     NZL_x     KOR_ov    URU_ov    USA_tpm   SUD_tpm KOR_m     BRA_x     NOR_x     TAI_ov    SUD_ov    HUN_tpm   SUE_tpm MAL_m     CAN_x POL_x     AUS_ov    CAN_ov    IND_tpm   TAI_tpm MEX_m     CHI_x     RUS_x     NZL_ov    NOR_ov    INDO_tpm  URU_tpm AUS_m     NZL_m     COL_x     SIN_x     CZC_ov    SUE_ov    MAL_tpm   trim_tpm  BRA_m     NOR_m     CZC_x     SUD_x     HUN_ov        MEX_tpm     CAN_m     POL_m     HUN_x     SUE_x     POL_ov    AUS_tpm   NOR_tpm, replace force

foreach j in COL_ov CHI_m     RUS_m     IND_x     TAI_x     RUS_ov    BRA_tpm   NZL_tpm COL_m     SIN_m     INDO_x    IND_ov    BRA_ov    CAN_tpm   POL_tpm CZC_m     SUD_m     KOR_x     INDO_ov   CHI_ov    CHI_tpm   CZC_tpm HUN_m     SUE_m     MAL_x     MAL_ov      COL_tpm   RUS_tpm IND_m     TAI_m  MEX_x     SIN_ov    MEX_ov    KOR_tpm   SIN_tpm INDO_m    AUS_x     NZL_x     KOR_ov    URU_ov    USA_tpm   SUD_tpm KOR_m     BRA_x     NOR_x     TAI_ov    SUD_ov    HUN_tpm   SUE_tpm MAL_m     CAN_x POL_x     AUS_ov    CAN_ov    IND_tpm   TAI_tpm MEX_m     CHI_x     RUS_x     NZL_ov    NOR_ov    INDO_tpm  URU_tpm AUS_m     NZL_m     COL_x     SIN_x     CZC_ov    SUE_ov    MAL_tpm   trim_tpm  BRA_m     NOR_m     CZC_x     SUD_x     HUN_ov        MEX_tpm     CAN_m     POL_m     HUN_x     SUE_x     POL_ov    AUS_tpm   NOR_tpm{
	



forvalues i = 2(1)7396{
	if `j'[`i'] ==.{
		replace `j' = `j'[`i'-1] if n == `i'
	}
}
}


 
 




export excel using "processed/Base.xlsx", first(var) cell("A1") sheet("b", modify)

save "processed/Base_sin_embi.dta", replace
