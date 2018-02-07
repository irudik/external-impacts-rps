////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// TABLE 2: MAIN RESULTS
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////	 

// Note: for plant-level regression we log generation and only use plants that
// had previously used that generation source

// Local list of control variables 
global control_list in_state_demand_na_twh multiplier_level ///
	acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
	 House Senate median_income_100 /// 
	 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured

	 
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// PLANT	 

/////////////////////////////////////////////////////////////////
// COAL
	 
use "$data_path/PLANT_DATASET.dta", clear
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
egen id=group(StateFIPS plantid)
drop if missing(id)
xtset id year

local plant_type coal
local y plant_coal_mwh

bysort id: egen ever_coal = max(plant_coal_mwh)
keep if ever_coal > 0
drop if `y' < 0
gen base_`y' = `y'
replace `y' =  ln(`y'+ 1) 
	
// Creates Mean
foreach x in $control_list {
	sum `x'
	scalar mean_`x' = `r(mean)'
}

sum base_plant_coal_mwh 
scalar mean_plant_coal_mwh = `r(mean)'
	
// Run Regression
reghdfe `y' out_state_demand_na_pwh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))  


// Store Basic Results
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "No"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "No"


//Evaluate Effect at Means  
lincom mean_plant_coal_mwh*out_state_demand_na_pwh/1e9 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_coal

// Display
esttab m1_coal , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_pwh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom mean_plant_coal_mwh*out_state_demand_na_pwh/1e9 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))	

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_coal
	
// Display
esttab m2_coal , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 

	

/////////////////////////////////////////////////////////////////
// GAS


use "$data_path/PLANT_DATASET.dta", clear
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
egen id=group(StateFIPS plantid)
drop if missing(id)
xtset id year

gen plant_ng_mwh = plant_ng_twh*1000000

local plant_type ng
local y plant_ng_mwh

bysort id: egen ever_ng = max(plant_ng_mwh)
keep if ever_ng > 0
drop if `y' <0
gen base_`y' = `y'
replace `y' =  ln(`y'+ 1) 
	 
	
// Creates Mean
foreach x in $control_list {
	sum `x'
	scalar mean_`x' = `r(mean)'
}

sum base_plant_ng_mwh 
scalar mean_plant_ng_mwh = `r(mean)'
	
// Run Regression
reghdfe `y' out_state_demand_na_pwh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))  


// Store Basic Results
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "No"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "No"
	


//Evaluate Effect at Means  
lincom mean_plant_ng_mwh*out_state_demand_na_pwh/1e9 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_ng

// Display
esttab m1_ng , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_pwh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom mean_plant_ng_mwh*out_state_demand_na_pwh/1e9 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_ng
	
// Display
esttab m2_ng , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 

	
/////////////////////////////////////////////////////////////////
// WIND	


use "$data_path/PLANT_DATASET.dta", clear
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
egen id=group(StateFIPS plantid)
drop if missing(id)
xtset id year

gen plant_wind_mwh = plant_wind_twh*1000000

local plant_type wind
local y plant_wind_mwh

bysort id: egen ever_wind = max(plant_wind_mwh)
keep if ever_wind > 0
drop if `y' < 0
gen base_`y' = `y'
replace `y' =  ln(`y'+ 1) 
	 
	
// Creates  Mean
foreach x in $control_list {
	sum `x'
	scalar mean_`x' = `r(mean)'
}

sum base_plant_wind_mwh 
scalar mean_plant_wind_mwh = `r(mean)'
	
// Run Regression
reghdfe `y' out_state_demand_na_pwh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))  


// Store Basic Results
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "No"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "No"
	



//Evaluate Effect at Means  
lincom mean_plant_wind_mwh*out_state_demand_na_pwh/1e9 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_wind

// Display
esttab m1_wind , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_pwh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom mean_plant_wind_mwh*out_state_demand_na_pwh/1e9 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_wind
	
// Display
esttab m2_wind , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// STATE

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

local plant_type coal
local y st_coal_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"

//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_coal_state

// Display
esttab m1_coal_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_twh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))	

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

else if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

else if  p_val<=.1 {
	scalar string_mean = string_mean + "\sym{.*}"
}

	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_coal_state
	
// Display
esttab m2_coal_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 

	

/////////////////////////////////////////////////////////////////
// GAS
	 

local plant_type gas
local y st_gas_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"

//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_gas_state

// Display
esttab m1_gas_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_twh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))	

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_gas_state
	
// Display
esttab m2_gas_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 

/////////////////////////////////////////////////////////////////
// WIND
	 

local plant_type wind
local y st_wind_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"

//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_wind_state

// Display
esttab m1_wind_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_twh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))	

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}

// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m2_wind_state

// Display
esttab m2_wind_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 	

/////////////////////////////////////////////////////////////////
// FOSSIL

local plant_type fossil
local y st_fossil_twh
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"

//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_fossil_state

// Display
esttab m1_fossil_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_twh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))	

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	
	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_fossil_state
	
// Display
esttab m2_fossil_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 

	
/////////////////////////////////////////////////////////////////
// FOSSIL RATIO

local plant_type fossil_ratio
local y st_fossil_ratio
	
// Run Regression
reghdfe `y' out_state_demand_na_twh $control_list  ///
	  , a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))   
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"

//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	


	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
	
// Store the estimates
est sto m1_ratio_state

// Display
esttab m1_ratio_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 
	
qui reghdfe `y' $control_list  ///
	 (out_state_demand_na_twh = pred_out_state_demand_na_sys), a(id year  i.nerc_list#c.time) vce(cluster StateFIPS, suite(mwc))    
	
	
estadd scalar KP_Wald_F = e(widstat)
	estadd scalar Stock_Yogo=16.38
	estadd local year_dum "Yes"
	estadd local sys_year "Yes"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local iv "Yes"


//Evaluate Effect at Means  
lincom out_state_demand_na_twh 

//Calculate P-Value since it's not stored
scalar p_val = 2*ttail(r(df),abs(r(estimate)/r(se)))	

// Round Estimates to Whatever place we need
scalar rounded_estimate = round(r(estimate),.001)
local rounded_estimate = rounded_estimate
scalar string_mean = "`rounded_estimate'"

// Round Standard Errors
scalar rounded_se = round(r(se),.001)
local rounded_se = rounded_se
scalar string_se = "("+"`rounded_se'"+")"

//Add Stars for Significance 
if p_val <= .01	{
	scalar string_mean = string_mean + "\sym{***}"
}	

if p_val>.01 & p_val<=.05 {
	scalar string_mean = string_mean + "\sym{**}"

}

if  p_val>.05 & p_val<=.1 {
	scalar string_mean = string_mean + "\sym{*}"

}
else {
	scalar string_mean = string_mean 
}
	
	
// Add the results
estadd local me_at_mean =string_mean
estadd local se_at_mean =string_se
	
est sto m2_ratio_state
	
// Display
esttab m2_ratio_state , ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	stats(me_at_mean se_at_mean) ///
	drop(*) 

label var multiplier_level "REC Multiplier Level"
label var acp_binary "ACP Binary"
label var acp_level_primary "ACP Level: Primary"
label var acp_level_secondary "ACP Level: Secondary"
label var banking_time "Years of REC Banking"

// Make Table 1
esttab  m1_fossil_state m1_ratio_state m1_coal_state m1_coal m1_gas_state m1_ng m1_wind_state m1_wind  ///
		using "$results_path/table_1.tex", ///
		star(* 0.10 ** 0.05 *** 0.01) ///
		stats(me_at_mean se_at_mean state_fe year_dum sys_trend  N, ///
		fmt(0) layout( "@" "@" "\multicolumn{1}{c}{@}") ///
		label("Out-of-State REC Demand (TWh)" "~" "\hline Observations" )) ///
		replace keep(in_state_demand_na_*)  ///
		se  ///
		booktabs b(%20.3f) se(%20.3f) eqlabels(none) alignment(S S) ///
		f  substitute(\_ _) ///
		mtitles("Fossil - State" "Fossil Ratio - State" "Coal - State" "Coal - Plant" "Gas - State" "Gas - Plant" "Wind - State" "Wind - Plant")
