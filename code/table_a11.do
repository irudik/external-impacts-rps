		
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// TABLE A11: REGION-BY-YEAR EFFECTS
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

local y st_coal_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#i.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"	
	est sto m1_coal_state

	

/////////////////////////////////////////////////////////////////
// GAS
	 

local y st_gas_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#i.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"	
	est sto m1_gas_state 

/////////////////////////////////////////////////////////////////
// WIND
	 

local y st_wind_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#i.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"	
	est sto m1_wind_state

/////////////////////////////////////////////////////////////////
// FOSSIL

local y st_fossil_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#i.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"	
	est sto m1_fossil_state

	
/////////////////////////////////////////////////////////////////
// FOSSIL RATIO

local y st_fossil_ratio
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#i.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"	
	est sto m1_ratio_state

label var multiplier_level "REC Multiplier Level"
label var acp_binary "ACP Binary"
label var acp_level_primary "ACP Level: Primary"
label var acp_level_secondary "ACP Level: Secondary"
label var banking_time "Years of REC Banking"
label var in_state_demand_na_twh "In-State REC Demand (TWh)"
		
		
**Make Table
esttab m1_fossil_state m1_ratio_state m1_coal_state m1_gas_state ///
	m1_wind_state using "$results_path/table_a11.tex", replace ///
	label booktabs b(%20.3f) se(%20.3f) eqlabels(none) alignment(S S)  ///
	keep(*demand_na*)  ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	se f nonumbers  mtitles("Fossil" "Fossil Ratio" "Coal" "Gas" "Wind") substitute(\_ _)
