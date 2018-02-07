////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// TABLE A8: Non-RPS States
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


// Local list of control variables 
global control_list in_state_demand_na_twh multiplier_level ///
	acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured


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

// Run all regressions
reghdfe st_fossil_twh out_state_demand_na_twh `control_list' ///
	if !rps_ever , a(StateFIPS year i.nerc_list#c.time) vce(cluster StateFIPS)
est store non_rps_1

reghdfe st_fossil_ratio out_state_demand_na_twh `control_list' ///
	if !rps_ever , a(StateFIPS year i.nerc_list#c.time) vce(cluster StateFIPS)
est store non_rps_2

reghdfe st_coal_twh out_state_demand_na_twh `control_list' ///
	if !rps_ever , a(StateFIPS year i.nerc_list#c.time) vce(cluster StateFIPS)
est store non_rps_3

reghdfe st_gas_twh out_state_demand_na_twh `control_list' ///
	if !rps_ever , a(StateFIPS year i.nerc_list#c.time) vce(cluster StateFIPS)
est store non_rps_4

reghdfe st_wind_twh out_state_demand_na_twh `control_list' ///
	if !rps_ever , a(StateFIPS year i.nerc_list#c.time) vce(cluster StateFIPS)
est store non_rps_5

// Make Table A8
esttab non_rps_* using "$results_path/table_a8.tex", replace ///
label booktabs b(%20.3f) se(%20.3f) eqlabels(none) alignment(S S)  ///
keep(*out_state_demand*)  ///
star(* 0.10 ** 0.05 *** 0.01) ///
se f nonumbers mtitles("Fossil" "Fossil Ratio" "Coal" "Gas" "Wind") substitute(\_ _)
