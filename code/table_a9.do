
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// TABLE A9: PLACEBO
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


// Local list of control variables 
global control_list in_state_demand_na_twh multiplier_level ///
	acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured

/////////////////////////////////////////////////////////////////
// COAL
	 
use "$data_path/MAIN_DATASET.dta", clear

label var multiplier_level "REC Multiplier Level"
label var acp_binary "ACP Binary"
label var acp_level_primary "ACP Level: Primary"
label var acp_level_secondary "ACP Level: Secondary"
label var banking_time "Years of REC Banking"

// Drop years outside our sample
drop if year<1993
drop if year>2013

// Set plant ID
capture drop id
egen id=group(StateFIPS)
drop if missing(id)
xtset id year

// Run Regression
reghdfe st_coal_twh out_state_demand_placebo $control_list  ///
	  , a(id year i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local controls "Yes"
	est sto placebo_1

// Run Regression
reghdfe st_gas_twh out_state_demand_placebo  $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local controls "Yes"
	est sto placebo_2
	
// Run Regression
reghdfe st_wind_twh out_state_demand_placebo  $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local controls "Yes"
	est sto placebo_3
	
// Make Table A9
esttab placebo_1 placebo_2 placebo_3 using "$results_path/table_a9.tex", replace ///
label booktabs b(%20.3f) se(%20.3f) eqlabels(none) alignment(S S)  ///
keep(out_state_demand_placebo in_state_demand_na*)  ///
star(* 0.10 ** 0.05 *** 0.01) ///
se f nonumbers mtitles("Coal" "Gas" "Wind") substitute(\_ _)
