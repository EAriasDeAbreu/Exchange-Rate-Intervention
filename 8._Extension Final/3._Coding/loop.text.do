*******************************************************************************
* Control sintetico HE
*********************************************************************************




cls
clear all
set more off

cd "C:\Users\Nicolas\OneDrive - Universidad de los andes\UNIVERSIDAD\7. SEPTIMO SEMESTRE\MACRO DESDE LA BANCA CENTRAL\PROYECTO\Exchange-Rate-Intervention\8._Extension Final\2._ProcessedData\Long"


use "long_imputed_interv.dta"


**********************************************************************************
*Definir eventos y tratamientos
***********************************************************************************


preserve

drop if country != "Colombia"


duplicates drop date, force
format date %td

sort date

gen ene = _n

tsset ene

tab tipo type

keep date ene tipo 


gen int_reservas_pur = 1 if tipo == 5

gen evsp_reservas_pur = 1 if (int_reservas_pur == 1 | l.int_reservas_pur ==1 | l2.int_reservas_pur == 1 | l3.int_reservas_pur == 1 | l4.int_reservas_pur==1 | l5.int_reservas_pur == 1 | f.int_reservas_pur == 1 | f2.int_reservas_pur == 1| f3.int_reservas_pur == 1| f4.int_reservas_pur == 1| f5.int_reservas_pur == 1)

gen t_int_res_pur = 1 if (int_reservas_pur == 1 | l.int_reservas_pur ==1 | l2.int_reservas_pur == 1 | l3.int_reservas_pur == 1 | l4.int_reservas_pur==1 | l5.int_reservas_pur == 1)

replace t_int_res_pur = 0 if (evsp_reservas_pur==1 & t_int_res_pur ==.)

gen int_res_pur_n = evsp_reservas_pur

replace int_res_pur_n = sum(evsp_reservas_pur != evsp_reservas_pur[_n-1]) + 1 if evsp_reservas_pur !=.

format date %td

*gen tr_per_res_pur =.
*replace tr_per_res_pur = date if (t_int_res_pur == 1 & l.t_int_res_pur==0)

replace int_res_pur_n = 31 if (ene >= 405 & ene <=425)

gen tr_per_res_pur =.
replace tr_per_res_pur = ene if (t_int_res_pur == 1 & l.t_int_res_pur==0)






gen int_reservas_sal = 1 if tipo == 1
gen evsp_reservas_sal = 1 if (int_reservas_sal == 1 | l.int_reservas_sal ==1 | l2.int_reservas_sal == 1 | l3.int_reservas_sal == 1 | l4.int_reservas_sal==1 | l5.int_reservas_sal == 1 | f.int_reservas_sal == 1 | f2.int_reservas_sal == 1| f3.int_reservas_sal == 1| f4.int_reservas_sal == 1| f5.int_reservas_sal == 1)

gen t_int_res_sal = 1 if (int_reservas_sal == 1 | l.int_reservas_sal ==1 | l2.int_reservas_sal == 1 | l3.int_reservas_sal == 1 | l4.int_reservas_sal==1 | l5.int_reservas_sal == 1)

replace t_int_res_sal = 0 if (evsp_reservas_sal==1 & t_int_res_sal ==.)

gen int_res_sal_n = evsp_reservas_sal

replace int_res_sal_n = sum(evsp_reservas_sal != evsp_reservas_sal[_n-1]) + 1 if evsp_reservas_sal !=.

replace int_res_sal_n = 5 if (ene >= 832 & ene <=843)

gen tr_per_res_sal =.
replace tr_per_res_sal = ene if (t_int_res_sal == 1 & l.t_int_res_sal==0)






gen int_disc = 1 if tipo == 4
gen evsp_disc = 1 if (int_disc == 1 | l.int_disc ==1 | l2.int_disc == 1 | l3.int_disc == 1 | l4.int_disc==1 | l5.int_disc == 1 | f.int_disc == 1 | f2.int_disc == 1| f3.int_disc == 1| f4.int_disc == 1| f5.int_disc == 1)

gen t_int_disc = 1 if (int_disc == 1 | l.int_disc ==1 | l2.int_disc == 1 | l3.int_disc == 1 | l4.int_disc==1 | l5.int_disc == 1)

replace t_int_disc = 0 if (evsp_disc==1 & t_int_disc ==.)

gen int_disc_n = evsp_disc

replace int_disc_n = sum(evsp_disc != evsp_disc[_n-1]) + 1 if evsp_disc !=.

replace int_disc_n = 9 if (ene >= 1316 & ene <=1502)
replace t_int_disc = 0 if (ene >= 1316 & ene <=1322)
replace int_disc_n = 10 if (ene >= 1845 & ene <=1871)

gen tr_per_disc =.
replace tr_per_disc = ene if (t_int_disc == 1 & l.t_int_disc==0)





gen int_volatility_pur = 1 if tipo == 6

gen evsp_volatility_pur = 1 if (int_volatility_pur == 1 | l.int_volatility_pur ==1 | l2.int_volatility_pur == 1 | l3.int_volatility_pur == 1 | l4.int_volatility_pur==1 | l5.int_volatility_pur == 1 | f.int_volatility_pur == 1 | f2.int_volatility_pur == 1| f3.int_volatility_pur == 1| f4.int_volatility_pur == 1| f5.int_volatility_pur == 1)

gen t_volatility_pur = 1 if (int_volatility_pur == 1 | l.int_volatility_pur ==1 | l2.int_volatility_pur == 1 | l3.int_volatility_pur == 1 | l4.int_volatility_pur==1 | l5.int_volatility_pur == 1)

replace t_volatility_pur = 0 if (evsp_volatility_pur==1 & t_volatility_pur ==.)

gen int_volatility_pur_n = evsp_volatility_pur
replace int_volatility_pur_n = sum(evsp_volatility_pur != evsp_volatility_pur[_n-1]) + 1 if evsp_volatility_pur !=.

replace int_volatility_pur_n = 16 if (ene >= 1931 & ene <=1941)
replace int_volatility_pur_n = 17 if (ene >= 2022 & ene <=2032)
replace int_volatility_pur_n = 18 if (ene >= 2124 & ene <=2134)
replace t_volatility_pur = 0 if (ene >= 1931 & ene <=1935)


gen tr_volatility_pur =.
replace tr_volatility_pur = ene if (t_volatility_pur == 1 & l.t_volatility_pur==0)






gen int_volatility_sal = 1 if tipo == 2
gen evsp_volatility_sal = 1 if (int_volatility_sal == 1 | l.int_volatility_sal ==1 | l2.int_volatility_sal == 1 | l3.int_volatility_sal == 1 | l4.int_volatility_sal==1 | l5.int_volatility_sal == 1 | f.int_volatility_sal == 1 | f2.int_volatility_sal == 1| f3.int_volatility_sal == 1| f4.int_volatility_sal == 1| f5.int_volatility_sal == 1)

gen t_volatility_sal = 1 if (int_volatility_sal == 1 | l.int_volatility_sal ==1 | l2.int_volatility_sal == 1 | l3.int_volatility_sal == 1 | l4.int_volatility_sal==1 | l5.int_volatility_sal == 1)

replace t_volatility_sal = 0 if (evsp_volatility_sal==1 & t_volatility_sal ==.)

gen int_volatility_n = evsp_volatility_sal

replace int_volatility_n = sum(evsp_volatility_sal != evsp_volatility_sal[_n-1]) + 1 if evsp_volatility_sal !=.

replace int_volatility_n = 12 if (ene >= 1644 & ene <=1654)
replace int_volatility_n = 13 if (ene >= 1675 & ene <=1686)
replace int_volatility_n = 14 if (ene >= 1687 & ene <=1698)

gen tr_volatility_sal =.
replace tr_volatility_sal = ene if (t_volatility_sal == 1 & l.t_volatility_sal==0)






drop tipo

save "treatment.dta", replace

restore

merge m:1 date using "treatment.dta", nogenerate

format date %td

encode country, generate(pais)

*local lista_var : int_disc int_disc_n int_res_pur_n int_res_sal_n int_reservas_pur int_reservas_sal int_volatility_n int_volatility_pur int_volatility_pur_n int_volatility_sal t_int_disc t_int_res_pur t_int_res_sal  t_volatility_pur t_volatility_sal evsp_disc evsp_int_res_pur evsp_reservas_pur evsp_reservas_sal evsp_volatility_pur evsp_volatility_sal

collapse exrate tpm night embi exports imports pi vol purchases sales intervention trade int_disc int_disc_n int_res_pur_n int_res_sal_n int_reservas_pur int_reservas_sal int_volatility_n int_volatility_pur int_volatility_pur_n int_volatility_sal t_int_disc t_int_res_pur t_int_res_sal  t_volatility_pur t_volatility_sal evsp_disc evsp_reservas_pur evsp_reservas_sal evsp_volatility_pur evsp_volatility_sal tr_per_res_pur ene tr_per_res_sal tr_per_disc tr_volatility_pur tr_volatility_sal, by(date pais)

tsset pais ene

**************************************************************************************
*obtener estimaciones para cada tipo de intervención
***********************************************************************************

forvalues i = 2/31{
	preserve
drop if evsp_reservas_pur ==.
drop if int_res_pur_n != `i'

save "CS/base.dta", replace


drop if tr_per_res_pur == .
gen en =_n 
drop if en != _N
sca esca = tr_per_res_pur 

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N - 5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_dia_res_pur_`i' = (com_d - ven_d)/dias

clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth exrate tpm embi night pi trade vol, trunit(5) trperiod(100) keep("CS/res_pur_`i'.dta") replace
restore
}


forvalues i = 2/5{
	preserve
drop if evsp_reservas_sal ==.
drop if int_res_sal_n != `i'

save "CS/base.dta", replace


drop if tr_per_res_sal == .
gen en =_n 
drop if en != _N
sca esca = tr_per_res_sal 

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N -5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_dia_res_sal_`i' = (com_d - ven_d)/dias

clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth exrate tpm embi night pi trade vol, trunit(5) trperiod(100) keep("CS/res_sal_`i'.dta") replace
restore
}


forvalues i = 2/10{
	preserve
drop if evsp_disc ==.
drop if int_disc_n != `i'

save "CS/base.dta", replace


drop if tr_per_disc == .
gen en =_n 
drop if en != _N
sca esca = tr_per_disc

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N-5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_dia_disc_`i' = (com_d - ven_d)/dias
clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth exrate tpm embi night pi trade vol, trunit(5) trperiod(100) keep("CS/res_dis_`i'.dta") replace
restore
}



forvalues i = 2/18{
	preserve
drop if evsp_volatility_pur ==.
drop if int_volatility_pur_n != `i'

save "CS/base.dta", replace


drop if tr_volatility_pur == .
gen en =_n 
drop if en != _N
sca esca = tr_volatility_pur

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N-5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_vol_pur_`i' = (com_d - ven_d)/dias

clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth exrate tpm embi night pi trade vol, trunit(5) trperiod(100) keep("CS/vol_pur_`i'.dta") replace
restore
}


forvalues i = 2/14{
	preserve
drop if evsp_volatility_sal ==.
drop if int_volatility_n != `i'

save "CS/base.dta", replace


drop if tr_volatility_sal == .
gen en =_n 
drop if en != _N
sca esca = tr_volatility_sal

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N-5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_vol_sal_`i' = (com_d - ven_d)/dias

clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth exrate tpm embi night pi trade vol, trunit(5) trperiod(100) keep("CS/vol_sal_`i'.dta") replace
restore
}


*****************************************************************************
*GARCH
********************************************************************************
drop if pais == 3
drop if pais == 9
drop if pais == 17

forvalues i = 2/18{
	preserve
drop if evsp_volatility_pur ==.
drop if int_volatility_pur_n != `i'

save "CS/base.dta", replace


drop if tr_volatility_pur == .
gen en =_n 
drop if en != _N
sca esca = tr_volatility_pur

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N-5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_vol_pur_`i' = (com_d - ven_d)/dias

clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth vol tpm embi night pi trade, trunit(5) trperiod(100) keep("CS/vol_garch_1_`i'.dta") replace
restore
}


forvalues i = 2/14{
	preserve
drop if evsp_volatility_sal ==.
drop if int_volatility_n != `i'

save "CS/base.dta", replace


drop if tr_volatility_sal == .
gen en =_n 
drop if en != _N
sca esca = tr_volatility_sal

clear

use "CS/base.dta"

drop if pais != 5
sca dias = _N-5
egen com_d = sum(sales)
egen ven_d = sum(purchases)
gen en =_n 
drop if en != _N
sca mont_vol_sal_`i' = (com_d - ven_d)/dias

clear

use "CS/base.dta"

replace ene = ene - esca + 100

tsset pais ene


synth vol tpm embi night pi trade, trunit(5) trperiod(100) keep("CS/vol_garch_2_`i'.dta") replace
restore
}







*******************************************************************************
*Distribuciones
********************************************************************************



clear


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


forvalues i = 2/18{
	
use "CS/vol_garch_1_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca vol_garch_1_`i' = t
clear
}


forvalues i = 2/14{
	
use "CS/vol_garch_2_`i'.dta"

drop _Co_Number _W_Weight

drop if _time <= 100
drop _time

gen t = _Y_treated - _Y_synthetic

collapse (mean) t

sca vol_garch_2_`i' = t
clear
}


import excel using "panelxx.xlsx", sheet("dists") first
gen res_pur =.
gen res_sal =.
gen disc = .
gen vol_pur = .
gen vol_sal =.
gen vol_garch = .

gen mon_d_res_pur =.
gen mon_d_res_sal =.
gen mon_d_disc =. 
gen mon_d_vol_pur =.
gen mon_d_vol_sal =.


forvalues i = 2/31{
replace res_pur = res_pur_`i' if ene == `i'
replace mon_d_res_pur = mont_dia_res_pur_`i' if ene == `i'
}
forvalues i = 2/5{
replace res_sal = res_sal_`i' if ene == `i'
replace mon_d_res_sal = mont_dia_res_sal_`i' if ene == `i'
}
forvalues i = 2/10{
replace disc = disc_`i' if ene == `i'
replace mon_d_disc = mont_dia_disc_`i' if ene == `i'
}
forvalues i = 2/18{
replace vol_pur = vol_pur_`i' if ene == `i'
replace mon_d_vol_pur = mont_vol_pur_`i' if ene == `i'
}
forvalues i = 2/14{
replace vol_sal = vol_sal_`i' if ene == `i'
replace mon_d_vol_sal = mont_vol_sal_`i' if ene == `i'
}
forvalues i = 2/18{
replace vol_garch = vol_garch_1_`i' if ene == `i'
}
forvalues i = 2/14{
replace vol_garch = vol_garch_2_`i' if ene == (`i'+17)
}

gen mon_d_vol_garch = mon_d_vol_pur
forvalues i = 19/31{
	preserve
	drop if ene != `i' - 17
	sca montoo = (-1)*(mon_d_vol_sal) 
	restore
	replace mon_d_vol_garch = montoo if ene ==`i' 
}
*replace mon_d_vol_garch = (-1)*(mon_d_vol_sal) if mon_d_vol_garch==.

/*

forvalues i = 2/31{
replace res_pur = res_pur_`i'/mont_dia_res_pur_`i' if ene == `i'
}
forvalues i = 2/5{
replace res_sal = res_sal_`i'/mont_dia_res_sal_`i' if ene == `i'
}
forvalues i = 2/10{
replace disc = disc_`i'/mont_dia_disc_`i' if ene == `i'
}
forvalues i = 2/18{
replace vol_pur = vol_pur_`i'/mont_vol_pur_`i' if ene == `i'
}
forvalues i = 2/14{
replace vol_sal = vol_sal_`i'/mont_vol_sal_`i' if ene == `i'
}
*/


sum res_pur,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "RES PURCH"
display med " " sd " " t " " obs



*preserve

*drop if mon_d_res_pur <= 40

twoway (kdensity res_pur, lcolor(black) xline(0.34, lc(stred)) xline(-0.64, lc(stred)) xline(-0.15, lc(stblue)) lc(gs2)) || ///
       (function y=0, range(0.036 0.036) lcolor(stblue)) || ///
	   (function y=0, range(0.036 0.036) lcolor(stred)), ///
       legend(order(1 "Density" 2 "Mean" 3 "CI 95%")) ///
	   title("International reserves acummulation options") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("Density")
graph export "graficas/res_pur_t.png", replace

*restore


sum res_sal,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "RES SALE"
display med " " sd " " t " " obs

twoway (kdensity res_sal, range(-0.1 0.35) lcolor(black) xline(0.31, lc(stred)) xline(-0.07, lc(stred)) xline(0.1257, lc(stblue)) lc(gs2)) || ///
       (function y=1, range(-0.07 -0.07) lcolor(stblue)) || ///
	   (function y=1, range(0.01257 0.01257) lcolor(stred)), ///
       legend(order(1 "Density" 2 "Mean" 3 "CI 95%")) ///
	   title("International reserves decummulation options") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("Density")
graph export "graficas/res_sal_t.png", replace

sum disc,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "RES DISC ALL"
display med " " sd " " t " " obs

twoway (kdensity disc, range(-0.2 0.45) lcolor(black) xline(0.036, lcolor(stblue)) lc(gs2)) || ///
       (function y=0, range(0.036 0.036) lcolor(stblue)), ///
       legend(order(1 "Density" 2 "Mean")) ///
	   title("Discretionary interventions dollars purchases") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("density")
graph export "graficas/disc_t.png", replace

sum vol_pur,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "VOL PURCH"
display med " " sd " " t " " obs

twoway (kdensity vol_pur, range(-1 1.5) lcolor(black) xline(0.79, lc(stred)) xline(-0.71, lc(stred)) xline(0.036, lc(stblue)) lc(gs2)) || ///
       (function y=1, range(-0.07 -0.07) lcolor(stblue)) || ///
	   (function y=1, range(0.01257 0.01257) lcolor(stred)), ///
       legend(order(1 "Density" 2 "Mean" 3 "CI 95%")) ///
	   title("Volatility options dollars purchases") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("Density")
graph export "graficas/vol_pur_t.png", replace

sum vol_sal,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "VOL SAL"
display med " " sd " " t " " obs

twoway (kdensity vol_sal, range(-1 3) lcolor(black) xline(1.58, lc(stred)) xline(-0.96, lc(stred)) xline(0.31, lc(stblue)) lc(gs2)) || ///
       (function y=1, range(-0.07 -0.07) lcolor(stblue)) || ///
	   (function y=1, range(0.01257 0.01257) lcolor(stred)), ///
       legend(order(1 "Density" 2 "Mean" 3 "CI 95%")) ///
	   title("Volatility options dollars sales") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("Density")
graph export "graficas/vol_sal_t.png", replace

preserve

drop if mon_d_vol_garch <= 10
sum vol_garch ,d
twoway (kdensity vol_garch, range(-4 3) lcolor(black) xline(-0.01043367, lc(stblue)) lc(gs2)) || ///
       (function y=0, range(0 0) lcolor(stblue)), ///
       legend(order(1 "Density" 2 "Mean")) ///
	   title("Volatility options effects on volatility measured with GARCH") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("Density")
graph export "graficas/vol_garch.png", replace

sum vol_garch,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "VOL GARCH"
display med " " sd " " t " " obs

restore


preserve

	drop if mon_d_disc <= 30

	twoway (kdensity disc, range(-0.2 0.45) lcolor(black) xline(0.036, lcolor(stblue)) lc(gs2)) || ///
		   (function y=0, range(0.036 0.036) lcolor(stblue)), ///
		   legend(order(1 "Density" 2 "Mean")) ///
		   title("Discretionary interventions dollars purchases") ///
		   xtitle("SC effects distribution") xlabel(,nogrid) ///
		   ylabel(,nogrid) ytitle("density")
	graph export "graficas/disc_t2.png", replace

	sum disc,d

	sca ar = r(p95)
	sca ab = r(p5)
	sca med = r(mean)
	sca sd = r(sd)
	sca obs = r(N)
	sca t = med/(sd/sqrt(obs))

	display "RES DISC FIL"
	display med " " sd " " t " " obs

restore

preserve
drop if mon_d_vol_pur <= 15
kdensity vol_pur 
restore


preserve
*drop if mon_d_vol_sal >= -10 
kdensity vol_sal 
restore

preserve
drop if mon_d_vol_garch <= 10
kdensity vol_garch
restore


sum vol_garch ,d
twoway (kdensity vol_garch, range(-4 3) lcolor(black) xline(-0.04265245 , lc(stblue)) lc(gs2)) || ///
       (function y=0, range(0 0) lcolor(stblue)), ///
       legend(order(1 "Density" 2 "Mean")) ///
	   title("Volatility options effects on volatility measured with GARCH") ///
	   xtitle("SC effects distribution") xlabel(,nogrid) ///
	   ylabel(,nogrid) ytitle("Density")
graph export "graficas/vol_garch2.png", replace

sum vol_garch,d

sca ar = r(p95)
sca ab = r(p5)
sca med = r(mean)
sca sd = r(sd)
sca obs = r(N)
sca t = med/(sd/sqrt(obs))

display "VOL GARCH"
display med " " sd " " t " " obs








