**************************************************************************************************

*Ventana 2
**************************************************************************************************
cls
clear all
set more off

cd "C:\Users\Lenovo\OneDrive - Universidad de los Andes\Septimo Semestre\HE BC\Edmundo Andres Arias De Abreu\HE2 – Talleres\Proyecto\FX-Intervention"

import excel using "2._ProcessedData/eventos_w2.xlsx", cellrange("A1:T463") first sheet("Sheet 1")

*convertir de 2 a 5 los nombres aunque sean 2 porque que jartera cambiar todo el codigo poniendo 2 en vez de 5.

rename Tasa_Post2 Tasa_Post5
rename Tasa_Pre2 Tasa_Pre5


*No se va a evaluar swaps ni auctions:

drop if (Id_Tipo == 3 | Id_Tipo == 9 |Id_Tipo == 8)

********************************************Direction*******************************************

*Loop compras
foreach i in  4 5 6 7{
	


preserve

drop if Id_Tipo != `i'

gen cambio_Post = Tasa_Post5 - Tasa_Post1
gen dir_`i' = 0 
replace dir_`i' = 1 if cambio_Post > 0

*desv- p-valor

sum dir_`i', d
sca desv_dir_`i' = r(sd)


gen ex_`i'_v = sum(dir_`i')

sca tot_dir_`i' = _N

drop if _n != _N
sca ex_dir_`i' = ex_`i'_v 
sca p_dir_`i' = ex_dir_`i'/desv_dir_`i'


restore
}





*Loop ventas

foreach i in  1 2{
	
preserve

drop if Id_Tipo != `i'

gen cambio_Post = Tasa_Post5 - Tasa_Post1
gen dir_`i' = 0 
replace dir_`i' = 1 if cambio_Post < 0

*desv- p-valor

sum dir_`i', d
sca desv_dir_`i' = r(sd)


gen ex_`i'_v = sum(dir_`i')

sca tot_dir_`i' = _N

drop if _n != _N
sca ex_dir_`i' = ex_`i'_v 
sca p_dir_`i' = ex_dir_`i'/desv_dir_`i'

restore
}

******************************************** Reversal *******************************************

*compras
foreach i in  4 5 6 7{
	


preserve

drop if Id_Tipo != `i'
gen cambio_Pre = Tasa_Pre1 - Tasa_Pre5
gen cambio_Post = Tasa_Post5 - Tasa_Post1
gen rev_`i' = 0 
replace rev_`i' = 1 if (cambio_Pre < 0) & (cambio_Post > 0)

*desv- p-valor

sum rev_`i', d
sca desv_rev_`i' = r(sd)


gen ex_`i'_v = sum(rev_`i')

sca tot_rev_`i' = _N

drop if _n != _N
sca ex_rev_`i' = ex_`i'_v 


restore
}


*ventas
foreach i in  1 2{
	


preserve

drop if Id_Tipo != `i'
gen cambio_Pre = Tasa_Pre1 - Tasa_Pre5
gen cambio_Post = Tasa_Post5 - Tasa_Post1
gen rev_`i' = 0 
replace rev_`i' = 1 if (cambio_Pre > 0) & (cambio_Post < 0)

*desv- p-valor

sum rev_`i', d
sca desv_rev_`i' = r(sd)


gen ex_`i'_v = sum(rev_`i')

sca tot_rev_`i' = _N

drop if _n != _N
sca ex_rev_`i' = ex_`i'_v 


restore
}


*******************************************Smoothing ***********************************************
*Loop compras
foreach i in  4 5 6 7{
	


preserve

drop if Id_Tipo != `i'

gen cambio_Post = Tasa_Post5 - Tasa_Post1
gen cambio_Pre = Tasa_Pre1 - Tasa_Pre5
gen smo_`i' = 0 
replace smo_`i' = 1 if cambio_Post > cambio_Pre

*desv- p-valor

sum smo_`i', d
sca desv_smo_`i' = r(sd)


gen ex_`i'_v = sum(smo_`i')

sca tot_smo_`i' = _N

drop if _n != _N
sca ex_smo_`i' = ex_`i'_v 



restore
}

*Loop ventas
foreach i in  1 2{
	


preserve

drop if Id_Tipo != `i'

gen cambio_Post = Tasa_Post5 - Tasa_Post1
gen cambio_Pre = Tasa_Pre1 - Tasa_Pre5
gen smo_`i' = 0 
replace smo_`i' = 1 if cambio_Post < cambio_Pre

*desv- p-valor

sum smo_`i', d
sca desv_smo_`i' = r(sd)


gen ex_`i'_v = sum(smo_`i')

sca tot_smo_`i' = _N

drop if _n != _N
sca ex_smo_`i' = ex_`i'_v 

restore
}

************************************Matching*************************************
*Loop compras
foreach i in  4 5 6 7{
	


preserve

drop if Id_Tipo != `i'

gen mat_`i' = Tasa_Post_Prom - Tasa_Pre_Prom 


*desv- p-valor

sum mat_`i', d
sca desv_mat_`i' = r(sd)
sca ex_mat_`i' = r(mean)

sca tot_mat_`i' = _N

restore
}


*Loop ventas
foreach i in  1 2 {
	

preserve

drop if Id_Tipo != `i'

gen mat_`i' = Tasa_Post_Prom - Tasa_Pre_Prom 


*desv- p-valor

sum mat_`i', d
sca desv_mat_`i' = r(sd)
sca ex_mat_`i' = r(mean)
sca tot_mat_`i' = _N


restore
}

*Exportar resultados

matrix define res_dir = (tot_dir_4,ex_dir_4,desv_dir_4\.,.,.\tot_dir_5,ex_dir_5,desv_dir_5\tot_dir_1,ex_dir_1,desv_dir_1\tot_dir_6,ex_dir_6,desv_dir_6\tot_dir_2,ex_dir_2,desv_dir_2\tot_dir_7,ex_dir_7,desv_dir_7)

matrix rownames res_dir = Discretional disc_sale Puts_IR_acc Calls_IR_deacc Puts_VC Calls_VC Forwards_Prc
matrix colnames res_dir = Events Succesfull_events Est_dev

matrix define res_rev = (tot_rev_4, ex_rev_4, desv_rev_4\.,.,. \ tot_rev_5, ex_rev_5, desv_rev_5 \ tot_rev_1, ex_rev_1, desv_rev_1 \ tot_rev_6, ex_rev_6, desv_rev_6 \ tot_rev_2, ex_rev_2, desv_rev_2\ tot_rev_7, ex_rev_7, desv_rev_7)

matrix rownames res_rev = Discretional disc_sale Puts_IR_acc Calls_IR_deacc Puts_VC Calls_VC Forwards_Prc
matrix colnames res_rev = Events Succesfull_events Est_dev

matrix define res_smo = (tot_smo_4,ex_smo_4,desv_smo_4\.,.,.\tot_smo_5,ex_smo_5,desv_smo_5\tot_smo_1,ex_smo_1,desv_smo_1\tot_smo_6,ex_smo_6,desv_smo_6\tot_smo_2,ex_smo_2,desv_smo_2\tot_smo_7,ex_smo_7,desv_smo_7)

matrix rownames res_smo = Discretional disc_sale Puts_IR_acc Calls_IR_deacc Puts_VC Calls_VC Forwards_Prc
matrix colnames res_smo = Events Succesfull_events Est_dev

matrix define res_mat = (tot_mat_4,ex_mat_4,desv_mat_4\.,.,.\tot_mat_5,ex_mat_5,desv_mat_5\tot_mat_1,ex_mat_1,desv_mat_1\tot_mat_6,ex_mat_6,desv_mat_6\tot_mat_2,ex_mat_2,desv_mat_2\tot_mat_7,ex_mat_7,desv_mat_7)

matrix rownames res_mat = Discretional disc_sale Puts_IR_acc Calls_IR_deacc Puts_VC Calls_VC Forwards_Prc
matrix colnames res_mat = Events Succesfull_events Est_dev


matrix list res_dir
matrix list res_rev
matrix list res_smo
matrix list res_mat


*Exportar

putexcel set "2._ProcessedData/tablas.xlsx", sh("stat_w2", replace) modify

putexcel B3 = matrix(res_dir)

putexcel B13 = matrix(res_rev)

putexcel B23 = matrix(res_smo)

putexcel B33 = matrix(res_mat)


