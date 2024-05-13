********************************************************************************
********************************************************************************
*Authors: 
*Coder: Edmundo Arias De Abreu
*Project: HE2 Project
*Data: Panel_v1.dta
*Stage: Event Study Setup & Analysis

*Last checked: 30.04.2024

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
*                           Event Study Design Set Up                          *
*                                                                              *
********************************************************************************

/// Import dataset
use "/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/FX-Intervention/8._Extension/2._ProcessedData/Ready/Panel_v1.dta", clear


xtset ifscode period
sort ifscode period


// Gen FXI Dummy -- For Now use Reported/Published Data
gen D_FXI = (FXI_spot_pub_USD_m != 0)



/// Gen First-Treat variable: year of first FXI
by ifscode: egen firsttreat = min(cond(D_FXI == 1, period, .))
tab firsttreat

/// Create dummy treatment variable specific on date
gen Dit = (period >= firsttreat & firsttreat!=0)
tab Dit

/// Create relative periods (t-t_0)
gen rel_time=period-firsttreat

tab rel_time, gen(evt) // dummies for each period
 *-> I have 98 leads & 284 lags !
 

 	 ** Leads
	forvalues x = 1/98 {
		
		local j= 99-`x'
		ren evt`x' evt_l`j'
		cap label var evt_l`j' "-`j'" 
	}

	**  Lags
	forvalues x = 0/284 {
		
		local j= 99+`x'
		ren evt`j' evt_f`x'
		cap label var evt_f`x' "`x'"  
	}
	
	
** Base period to be ommited becuase of perfect multicollinearity:
replace evt_l1=0



********************************************************************************
*                                                                              *
*                                Regressions                                   *
*                                                                              *
********************************************************************************




/// Event Study – TWFE
reghdfe ctr_nomxr evt_l11 evt_l10 evt_l9 evt_l8 evt_l7 evt_l6 evt_l5 evt_l4 evt_l3 evt_l2 evt_l1 evt_f0 evt_f1 evt_f2 evt_f3 evt_f4 evt_f5 evt_f6 evt_f7 evt_f8 evt_f9 evt_f10 evt_f11 , abs(ifscode period) vce(cluster ifscode)
	estimates store coefs_i 

*) Graph
coefplot coefs_i, omitted														///
	vertical 																	///
	label drop(_cons)															///
	yline(0, lpattern(dash) lwidth(*0.5))   							 		///
	ytitle("Votos hacia el Partido Conservador (log)")                          ///
	xtitle("Años Relativo al Ataque", size(medsmall))			 		        ///
	xlabel(, labsize(small) nogextend labc(black)) 	 				 			///
	ylabel(,nogrid nogextend labc(black) format(%9.2f)) 				 		///
	msymbol(O) 														 			///
	mlcolor(black) 													 			///
	mfcolor(black) 													 			///
	msize(vsmall) 													 			///
	levels(95) 														 			///
	xline(11, lpattern(dash) lwidth(*0.5))										///
	ciopts(lcol(black) recast(rcap) lwidth(*0.8)) 					 			///
	plotregion(lcolor(black) fcolor(white))  							 		///
	graphregion(lcolor(black) fcolor(white))  						 			///
	yscale(lc(black)) 												 			///
	xscale(lc(black)) 												 			///
	name(TWFE2_1, replace)

tab rel_time










