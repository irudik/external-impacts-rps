////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// TABLE 3: PARALLEL TRENDS CHECK
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////	 


clear all
set matsize 800
use "$data_path/MAIN_DATASET.dta"

sort StateFIPS year

//////////////////////////////////////////
// Create "RPS time." Time 0 is where the state first experiences out of state REC demand

// First year facing non-zero REC demand
bysort StateFIPS (year): gen first_out_year = sum(out_state_demand_na_twh ) != 0

// Index years after
bysort StateFIPS (year): gen rps_time_forward = sum(first_out_year)

// Index years before
gen nyear = -year
gen rps_time_dummy = 0
replace rps_time_dummy = -1 if rps_time_forward == 0
replace rps_time_dummy = 0 if rps_time_dummy == -1 & (rps_time_forward[_n+1] > 0 | year == 2013)
bysort StateFIPS (nyear): gen rps_time_backwards = sum(rps_time_dummy) if rps_time_dummy == -1
replace rps_time_backwards = 0 if missing(rps_time_backwards)

// RPS time variable
gen rps_time = rps_time_forward + rps_time_backwards
label variable rps_time "Years Since RPS Enactment"
label variable StateFIPS "state"

// Panel
sort StateFIPS year
xtset StateFIPS year

////////
//////// COAL
////////

// Local list of control variables (non-RPS)
local control_list multiplier_level acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured 

// Coal trends
reghdfe st_coal_twh in_state_demand_na_twh `control_list' ///
		 , a(FEc_state = i.StateFIPS FEc_time = i.year FEc_trend = i.nerc_list#c.time)
predict res_coal, res

// Plot in RPS time
xtset StateFIPS rps_time
gen pretreat = 0 
replace pretreat =1 if rps_time < 0 


xtline res_coal, xline(0) yline(0) recast(connected)
graph export "$results_path/figure_a1a.pdf", replace	
preserve

// Drop states that do not appear parallel
drop if StateFIPS == 13 | StateFIPS == 17 | StateFIPS == 18 | StateFIPS == 29 ///
	| StateFIPS == 45 | StateFIPS == 46 ///
	| StateFIPS == 42 
	
	
// Local list of control variables (non-RPS)
local control_list multiplier_level acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured 
	 
// Coal regression without non-parallel states
reghdfe st_coal_twh out_state_demand_na_twh in_state_demand_na_twh `control_list' ///
		 , a(i.StateFIPS i.year i.nerc_list#c.time)
estadd local year_dum "Yes"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
est store parallel_coal
restore		

////////
//////// GAS
////////
 
xtset StateFIPS year

// Local list of control variables (non-RPS)
local control_list multiplier acp_binary acp_level_primary acp_level_secondary ///
	mgpo unbundled pbf interconnection House Senate median_income_100

// Gas trends
reghdfe st_gas_twh in_state_demand_na_twh `control_list' ///
		 , a(FEg_state = i.StateFIPS FEg_time = i.year FEg_trend = i.nerc_list#c.time)

predict res_gas, res
xtset StateFIPS rps_time
xtline res_gas, xline(0) yline(0) recast(connected)
graph export "$results_path/figure_a1b.pdf", replace	


preserve
// Drop states that do not appear parallel
drop if StateFIPS == 4 | StateFIPS == 12 | StateFIPS == 28 | StateFIPS == 37 ///
	| StateFIPS == 40 | StateFIPS == 47 | StateFIPS == 48 

	
// Local list of control variables (non-RPS)
local control_list multiplier_level acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured 
	 
// Gas regression without non-parallel states
reghdfe st_gas_twh out_state_demand_na_twh in_state_demand_na_twh `control_list' ///
		 , a(i.StateFIPS i.year i.nerc_list#c.time)
estadd local year_dum "Yes"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
est store parallel_gas

restore		

////////
//////// WIND
////////

xtset StateFIPS year

// Local list of control variables (non-RPS)
local control_list multiplier acp_binary acp_level_primary acp_level_secondary ///
	mgpo unbundled pbf interconnection House Senate median_income_100

// Wind trends
reghdfe st_wind_twh in_state_demand_na_twh `control_list' ///
		 , a(FEw_state = i.StateFIPS FEw_time = i.year FEw_trend = i.nerc_list#c.time)

predict res_wind, res
xtset StateFIPS rps_time
xtline res_wind, xline(0) yline(0) recast(connected)
graph export "$results_path/figure_a1c.pdf", replace	

preserve
// Drop states that do not appear parallel
drop if StateFIPS == 48

// Local list of control variables (non-RPS)
local control_list multiplier_level acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured 
	 
// Wind regression without non-parallel states
reghdfe st_wind_twh out_state_demand_na_twh in_state_demand_na_twh `control_list' ///
		 , a(i.StateFIPS i.year i.nerc_list#c.time)
estadd local year_dum "Yes"
estadd local state_fe "Yes"
estadd local sys_trend "Yes"
est store parallel_wind

restore	

// Make Table 2
esttab parallel_* using "$results_path/table_2.tex", replace ///
label booktabs b(%10.3f) se(%10.3f) eqlabels(none) alignment(S S)  ///
keep(*out_state_demand_na* in_state_demand_na*)  ///
stats(N, ///
fmt(0)layout("\multicolumn{1}{c}{@}") ///
label("Observations" )) ///
star(* 0.10 ** 0.05 *** 0.01) ///
se f mtitles("Coal" "Gas" "Wind") nonumbers substitute(\_ _)

////////
//////// SOLAR
////////

xtset StateFIPS year

// Local list of control variables (non-RPS)
local control_list multiplier acp_binary acp_level_primary acp_level_secondary ///
	mgpo unbundled pbf interconnection House Senate median_income_100

// Wind trends
reghdfe st_solar_twh in_state_demand_na_twh `control_list' ///
		 , a(FEs_state = i.StateFIPS FEs_time = i.year FEs_trend = i.nerc_list#c.time)

predict res_solar, res
xtset StateFIPS rps_time
xtline res_solar, xline(0) yline(0) recast(connected)
graph export "$results_path/figure_a1d.pdf", replace	
