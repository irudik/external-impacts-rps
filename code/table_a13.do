		
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// FIGURES A7-A11, TABLE A13: HETEROGENEOUS PLANT EFFECTS BY QUINTILES
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


// Local list of control variables 
global control_list in_state_demand_na_pwh multiplier_level ///
	acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured

use "$data_path/PLANT_DATASET.dta", clear

merge  m:1 plantid year using "$data_path/860_nameplate_age_1990_2015.dta"

// Drop years outside our sample
drop if year<1993
drop if year>2013

// Set plant ID
egen id=group(StateFIPS plantid)
drop if missing(id)
xtset id year
		
// Keep only if the plant had ever generated coal-fired power
bysort id: egen ever_coal = max(plant_coal_mwh)
keep if ever_coal > 0

// Log transform
gen base_plant_coal_mwh = plant_coal_mwh
replace plant_coal_mwh =  ln(plant_coal_mwh+ 1) 

// Baseline Nameplate Capacity Quintiles
gen nameplate_2001_A = nameplatecapacity if year == 2001
bysort plantid: egen nameplate_2001 = max(nameplate_2001_A)
xtile dec_name = nameplate_2001, n(5)

// Baseline Heatrate Quintiles
gen heatrate = coal_t_mmbtu/plant_coal_mwh //thermal efficiency
gen heatrate_2001_A = heatrate if year == 2001
bysort plantid: egen heatrate_2001 = max(heatrate_2001_A)
xtile dec_heat = heatrate_2001, n(5)
	
// Oldest Boiler in 2001 Quintiles
gen age_of_oldest_boiler = year - min_inserviceyear
xtile dec_age = age_of_oldest_boiler, n(5)
	
// Quantity Electricity Generated in 2001 Quintiles
gen plant_coal_twh_2001_A = plant_coal_twh if year == 2001
bysort plantid: egen plant_coal_twh_2001 = max(plant_coal_twh_2001_A)
xtile dec_twh = plant_coal_twh_2001, n(5)



////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// FIGURES A7-A10: HETEROGENOUS COAL PLANT EFFECTS BY QUINTILES
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////
// EFFECTS BY 2001 GENERATION
// EXCLUDED QUINTILE

capture drop xb
capture drop hi
capture drop lo
capture drop x

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1

forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
			  $control_list   ///
		if dec_twh != `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Excluded Output (MWh) in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a7_excluded.pdf", replace

/////////////////////////////////////
// EFFECTS BY 2001 GENERATION
// INCLUDED QUINTILE

capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1
	
forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_twh == `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Included Output (MWh) in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a7_included.pdf", replace

/////////////////////////////////////
// EFFECTS BY 2001 CAPACITY
// EXCLUDED QUINTILE

capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1
		
forvalues y = 1/5 {

//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_name != `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Excluded Output (MW) in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a8_excluded.pdf", replace

/////////////////////////////////////
// EFFECTS BY 2001 CAPACITY
// INCLUDED QUINTILE

capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1

forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_name == `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Included Output (MW) in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a8_included.pdf", replace

/////////////////////////////////////
// EFFECTS BY 2001 AGE OF OLDEST BOILER
// EXCLUDED QUINTILE

capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1

forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_age != `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Excluded Age of Oldest Boiler in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a9_excluded.pdf", replace

/////////////////////////////////////
// EFFECTS BY 2001 AGE OF OLDEST BOILER
// INCLUDED QUINTILE

capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1

forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_age == `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Included Age of Oldest Boiler in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a9_included.pdf", replace


/////////////////////////////////////
// EFFECTS BY 2001 HEATRATE
// EXCLUDED QUINTILE
capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1

forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_heat != `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Excluded Heatrate in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a10_excluded.pdf", replace

/////////////////////////////////////
// EFFECTS BY 2001 HEATRATE
// INCLUDED QUINTILE

capture drop xb* hi* lo* x*

g xb  = 0 in 1
g hi  = 0 in 1
g lo  = 0 in 1

forvalues y = 1/5 {

	//Run Estimation
	qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
		$control_list   ///
		if dec_heat == `y', a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   							
	replace xb    = _b[out_state_demand_na_pwh] in `y'
	replace hi = _b[out_state_demand_na_pwh] + 1.96 * _se[out_state_demand_na_pwh]  in `y'
	replace lo = _b[out_state_demand_na_pwh] - 1.96 * _se[out_state_demand_na_pwh]  in `y'

}

g x = _n in 1/5

tw (connected xb x in 1/6, m(O) mfcolor(white) mlcolor(edkblue) msize(medium) lcolor(edkblue) lwidth(medthick) mlwidth(medium)) ///
	(line hi x in 1/6, lpattern(dash) lcolor(erose)) ///
	(line lo x in 1/6, lpattern(dash) lcolor(erose)), ///
	graphr(color(white)) ///
	legend(off) ///
	xtit("Included Heatrate in 2001 Quintile", size(4.5)) ///
	subtit("Coefficient on Out-of-State REC Demand", size(6) pos(11)) ///
	yline(0, lcolor(cranberry)) ///
	ylabel(, noticks nogrid) ///
	xlabel(,nogrid)
	graph export  "$results_path/figure_a10_included.pdf", replace


		
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// TABLE A12: HETEROGENEOUS PLANT EFFECTS BY QUINTILES
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
est sto clear

qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
	$control_list   ///
	, a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	
estadd scalar KP_Wald_F = e(widstat)
estadd scalar Stock_Yogo=16.38
estadd local year_dum "Yes"
estadd local sys_year "No"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
estadd local iv "No"

eststo m0
			
gen plant_effect=_b[out_state_demand_na_pwh]*out_state_demand_na_pwh 

qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.nameplate_2001 ///
	$control_list   ///
	, a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))  
	
estadd scalar KP_Wald_F = e(widstat)
estadd scalar Stock_Yogo=16.38
estadd local year_dum "Yes"
estadd local sys_year "No"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
estadd local iv "No"

eststo m1
	
qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.plant_coal_twh_2001 ///
	$control_list   ///
	, a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	
estadd scalar KP_Wald_F = e(widstat)
estadd scalar Stock_Yogo=16.38
estadd local year_dum "Yes"
estadd local sys_year "No"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
estadd local iv "No"

eststo m2

qui reghdfe plant_coal_mwh out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.nameplate_2001 ///
	c.out_state_demand_na_pwh#c.plant_coal_twh_2001 ///
	$control_list   ///
	, a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))
	
estadd scalar KP_Wald_F = e(widstat)
estadd scalar Stock_Yogo=16.38
estadd local year_dum "Yes"
estadd local sys_year "No"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
estadd local iv "No"
		
eststo m3
		
						
esttab m0  m2, ///
	keep(out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.plant_coal_twh_2001 ///		
	in_state_demand_na_pwh) ///
	order(out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.plant_coal_twh_2001 ///		
	in_state_demand_na_pwh) ///
	star(* 0.10 ** 0.05 *** 0.01)
		
esttab m0 m2 using "$results_path/table_a14.tex", ///
	keep(out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.plant_coal_twh_2001 ///		
	in_state_demand_na_pwh) ///
	order(out_state_demand_na_pwh ///
	c.out_state_demand_na_pwh#c.plant_coal_twh_2001 ///		
	in_state_demand_na_pwh) ///
	coeflabels(c.out_state_demand_na_pwh#c.plant_coal_twh_2001 "Out-of-State REC Demand (PWh) \$\times\$ Plant Output (TWh) in 2001") ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	replace ///
	stats(N, ///
	fmt(0)layout("\multicolumn{1}{c}{@}") label("Observations" )) ///) ///
	se label ///
	booktabs b(%20.3f) se(%20.3f) eqlabels(none) alignment(S S) ///
	f nomtitles substitute(\_ _) 
				


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// FIGURE A11: KAPLAN-MEIER SHUTDOWN SURVIVAL GRAPHS
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Shutdown dummy				
gen shutdown = 0
replace shutdown = 1 if plant_coal_twh == 0

order id time year
sort id year

stset time, failure(shutdown==1) id(id)
xtset id
			
// Generation
sts graph, ci  survival by(dec_twh) ///
	legend(order(2 "0-20%"4 "20-40%" ///
	6 "40%-60%"8 "60-80%" ///
	10 "80-100%" ) ///
	cols(1) rows(2) ring(0) position(6)) ///
	title("Kaplan-Meier Shutdown Estimates By Quintile of Output (MWh) in 2001") ///
	xtitle("Years Since Beginning of Sample") ytitle("Probability of Not Shutting Down")
	graph export "$results_path/figure_a11a.pdf", replace
	
// Capacity
sts graph, ci  survival by(dec_name) ///
	legend(order(2 "0-20%"4 "20-40%" ///
	6 "40%-60%"8 "60-80%" ///
	10 "80-100%" ) ///
	cols(1) rows(2) ring(0) position(6)) ///
	title("Kaplan-Meier Shutdown Estimates By Plant Nameplate Capacity (MW) in 2001") ///
	xtitle("Years Since Beginning of Sample") ytitle("Probability of Not Shutting Down")
	graph export "$results_path/figure_a11b.pdf", replace
	
// Age of Oldest Boiler
sts graph, ci  survival by(dec_age) ///
	legend(order(2 "0-20%"4 "20-40%" ///
	6 "40%-60%"8 "60-80%" ///
	10 "80-100%" ) ///
	cols(1) rows(2) ring(0) position(6)) ///
	title("Kaplan-Meier Shutdown Estimates By Quintile of Age of Oldest Boiler in 2001") ///
	xtitle("Years Since Beginning of Sample") ytitle("Probability of Not Shutting Down")
	graph export "$results_path/figure_a11c.pdf", replace

// Heat Rate
sts graph, ci  survival by(dec_heat) ///
	legend(order(2 "0-20%"4 "20-40%" ///
	6 "40%-60%"8 "60-80%" ///
	10 "80-100%" ) ///
	cols(1) rows(2) ring(0) position(6)) ///
	title("Kaplan-Meier Shutdown Estimates By Quintile of Heatrate in 2001") ///
	xtitle("Years Since Beginning of Sample") ytitle("Probability of not Shutting Down")
	graph export "$results_path/figure_a11d.pdf", replace


		   


			

