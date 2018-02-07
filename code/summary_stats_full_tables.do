//Note: This must be ran after create_pollution_data.do

//State Level Variables
clear all
set matsize 800
use "$data_path/MAIN_DATASET.dta"

// Drop years not in analysis
drop if year>2013
drop if year<1993

	
sort StateFIPS year
xtset StateFIPS year
label variable out_state_demand_na_twh "Out-of-State REC Demand, TWh"
label variable in_state_demand_na_twh "In-State REC Demand, TWh"
label variable coal_net_gen_mil "Coal Net Generation, TWh"
label variable acp_level_primary "ACP Level: Primary, dollars per REC"
label variable acp_level_secondary "ACP Level: Secondary, dollars per REC"
label variable rggi "RGGI Membership Binary"
label variable restructured "Restructured Market Binary"
label variable rggi_price_int "RGGI Membership x RGGI CO2 Allowance Price, dollars per permit"
label variable retail_electricity_price "Lagged Retail Electricity price, cents per kWh"
label variable median_income_100 "\hspace{0.5cm} Median Income, \\$100k"
gen pred_out_state_demand_sys_na_twh = pred_out_state_demand_na*1000

// Controls
global control_list median_income_100 House Senate retail_electricity_price ///
	mgpo interconnection pbf restructured rggi rggi_price_int multiplier_level ///
	unbundled banking_time acp_binary acp_level_primary acp_level_secondary

// Local for the table	 
local state_list coal_net_gen_mil ng_net_gen_mil  ff_net_gen_mil ///
	solar_net_gen_mil wind_net_gen_mil fossil_ratio ///
	out_state_demand_na_twh  in_state_demand_na_twh  /// 
	$control_list



foreach x in `state_list' {
	local lab: variable label `x'
	label variable `x' "\hspace{0.5cm} `lab'"
}

label variable median_income_100 "\hspace{0.5cm} Median Income, \\$100k"

// Export Summary Table
eststo clear
estpost summarize  `state_list'
esttab using "$results_path/summary_statistics.tex", replace ///
cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
refcat(coal_net_gen_mil "\emph{State Level Variables}" , nolabel) noobs substitute(\_ _)

// Export Summary Table
local lab: variable label year
label variable year "\hspace{0.5cm} `lab'"
eststo clear
estpost summarize  year
esttab using "$results_path/summary_statistics.tex", append ///
cells("mean(fmt(%20.0f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.0f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.0f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.0f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) eform  ///
noobs substitute(\_ _) collabels(none) ///
nolines

//Plant Level Variables		 
local type_list coal ng solar wind 

	
/////////////////////////////////////////////////////////////////
// COAL


local list_of_plant_types coal ng solar wind
foreach plant_type in `list_of_plant_types' {
	if "`plant_type'" == "coal" {
		use "$data_path/PLANT_DATASET.dta", clear
		label var multiplier_level "REC Multiplier Level"
		label var acp_binary "ACP Binary"
		label var acp_level_primary "ACP Level: Primary"
		label var acp_level_secondary "ACP Level: Secondary"
		label var banking_time "Years of REC Banking"



		// Local list of control variables 
		local control_list multiplier_level  acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
			 House Senate median_income_100 /// 
			 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured


		// Drop years outside our sample
		drop if year<1993
		drop if year>2013

		// Set plant ID
		egen id=group(StateFIPS plantid)
		drop if missing(id)
		xtset id year
		
		local y plant_coal_mwh //plant_log_gen_coal  //plant_coal_twh

		// Keep only the correct type of plant
		bysort id: egen ever_coal = max(plant_coal_mwh)
		keep if ever_coal > 0

		drop if plant_coal_mwh<0
		
		local plant_list plant_coal_twh
		label variable plant_coal_twh "Coal Net Generation, TWh"
		label variable plant_ng_twh "Natural Gas Net Generation, TWh"
		label variable plant_pet_twh "Petroleum  Net Generation, TWh"
		label variable plant_all_fossil_fuel_twh "Fossil Fuel  Net Generation, TWh"
		label variable plant_wind_twh "Wind Net Generation, TWh"
		label variable plant_solar_twh "Solar Net Generation, TWh"
		local lab: variable label `plant_list'
		label variable `plant_list' "\hspace{0.5cm} `lab'"
		eststo clear
		estpost summarize  `plant_list'
		esttab using "$results_path/summary_statistics.tex", append ///
		cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
		nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
		refcat(plant_coal_twh "\emph{Plant Level Variables}" , nolabel) noobs substitute(\_ _) noline
		
	}	
	
	else if "`plant_type'" == "ng" {
		use "$data_path/PLANT_DATASET.dta", clear
		label var multiplier_level "REC Multiplier Level"
		label var acp_binary "ACP Binary"
		label var acp_level_primary "ACP Level: Primary"
		label var acp_level_secondary "ACP Level: Secondary"
		label var banking_time "Years of REC Banking"



		// Local list of control variables 
		local control_list multiplier_level  acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
			 House Senate median_income_100 /// 
			 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured


		// Drop years outside our sample
		drop if year<1993
		drop if year>2013

		// Set plant ID
		egen id=group(StateFIPS plantid)
		drop if missing(id)
		xtset id year
		
		
		// Keep only the correct type of plant
		bysort id: egen ever_ng = max(plant_ng_twh)
		keep if ever_ng > 0
		
		drop if plant_ng_twh<0		// Local list of variables to loop through
		local plant_list plant_ng_twh
		label variable plant_coal_twh "Coal Net Generation, TWh"
		label variable plant_ng_twh "Natural Gas Net Generation, TWh"
		label variable plant_pet_twh "Petroleum  Net Generation, TWh"
		label variable plant_all_fossil_fuel_twh "Fossil Fuel  Net Generation, TWh"
		label variable plant_wind_twh "Wind Net Generation, TWh"
		label variable plant_solar_twh "Solar Net Generation, TWh"
		local lab: variable label `plant_list'
		label variable `plant_list' "\hspace{0.5cm} `lab'"
		eststo clear
		estpost summarize  `plant_list'
		esttab using "$results_path/summary_statistics.tex", append ///
		cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
		nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)  collabels(none)eform  ///
		noobs substitute(\_ _) noline
		}	
			
		
	else if "`plant_type'" == "solar" {
		use "$data_path/PLANT_DATASET.dta", clear
		label var multiplier_level "REC Multiplier Level"
		label var acp_binary "ACP Binary"
		label var acp_level_primary "ACP Level: Primary"
		label var acp_level_secondary "ACP Level: Secondary"
		label var banking_time "Years of REC Banking"



		// Local list of control variables 
		local control_list multiplier_level  acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
			 House Senate median_income_100 /// 
			 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured


		// Drop years outside our sample
		drop if year<1993
		drop if year>2013

		// Set plant ID
		egen id=group(StateFIPS plantid)
		drop if missing(id)
		xtset id year
		
	
		// Keep only the correct type of plant
		bysort id: egen ever_solar = max(plant_solar_twh)
		keep if ever_solar > 0
		
		drop if plant_solar_twh<0		// Local list of variables to loop through
		// Local list of variables to loop through
		local plant_list plant_solar_twh
		label variable plant_coal_twh "Coal Net Generation, TWh"
		label variable plant_ng_twh "Natural Gas Net Generation, TWh"
		label variable plant_pet_twh "Petroleum  Net Generation, TWh"
		label variable plant_all_fossil_fuel_twh "Fossil Fuel  Net Generation, TWh"
		label variable plant_wind_twh "Wind Net Generation, TWh"
		label variable plant_solar_twh "Solar Net Generation, TWh"
		local lab: variable label `plant_list'
		label variable `plant_list' "\hspace{0.5cm} `lab'"
		eststo clear
		estpost summarize  `plant_list'
		esttab using "$results_path/summary_statistics.tex", append ///
		cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
		nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)  collabels(none)eform  ///
		noobs substitute(\_ _) noline
		}
		
	if "`plant_type'" == "wind" {
		use "$data_path/PLANT_DATASET.dta", clear
		label var multiplier_level "REC Multiplier Level"
		label var acp_binary "ACP Binary"
		label var acp_level_primary "ACP Level: Primary"
		label var acp_level_secondary "ACP Level: Secondary"
		label var banking_time "Years of REC Banking"



		// Local list of control variables 
		local control_list multiplier_level  acp_binary acp_level_primary acp_level_secondary banking_time unbundled /// 
			 House Senate median_income_100 /// 
			 mgpo pbf interconnection rggi rggi_price_int retail_electricity_price restructured


		// Drop years outside our sample
		drop if year<1993
		drop if year>2013

		// Set plant ID
		egen id=group(StateFIPS plantid)
		drop if missing(id)
		xtset id year
		
	
		// Keep only the correct type of plant
		bysort id: egen ever_wind = max(plant_wind_twh)
		keep if ever_wind > 0
		*keep if plant_coal_twh > 0
		// Local list of variables to loop through
		*local plant_list plant_log_gen_coal plant_coal_twh plant_log_gen_ng plant_ng_twh plant_log_gen_pet plant_pet_twh
		
		drop if plant_wind_twh<0
		// Local list of variables to loop through
		local plant_list plant_wind_twh 
		label variable plant_coal_twh "Coal Net Generation, TWh"
		label variable plant_ng_twh "Natural Gas Net Generation, TWh"
		label variable plant_pet_twh "Petroleum  Net Generation, TWh"
		label variable plant_all_fossil_fuel_twh "Fossil Fuel  Net Generation, TWh"
		label variable plant_wind_twh "Wind Net Generation, TWh"
		label variable plant_solar_twh "Solar Net Generation, TWh"
		local lab: variable label `plant_list'
		label variable `plant_list' "\hspace{0.5cm} `lab'"
		eststo clear
		estpost summarize  `plant_list'
		esttab using "$results_path/summary_statistics.tex", append ///
		cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
		nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none)  collabels(none)eform  ///
		noobs substitute(\_ _) noline
		}	
	}
	
// Plant Specific Emissions Factors
clear all 
use "$data_path/emissions_data_by_plant.dta"

local emissions_list nh3_lbs_per_mwh nox_lbs_per_mwh pm_25_lbs_per_mwh  pm_10_lbs_per_mwh  so2_lbs_per_mwh   voc_lbs_per_mwh   
label variable pm_25_lbs_per_mwh "PM 2.5 lbs. per MWh"
label variable pm_10_lbs_per_mwh "PM 10 lbs. per MWh"
label variable so2_lbs_per_mwh "SO\$\_2\$ lbs. per MWh"
label variable nox_lbs_per_mwh "NO\$\_x\$ lbs. per MWh"
label variable voc_lbs_per_mwh "VOC lbs. per MWh"
label variable nh3_lbs_per_mwh "NH\$\_3\$ lbs. per MWh"
	
foreach x in `emissions_list'{
	local lab: variable label `x'
	label variable `x' "\hspace{0.5cm} `lab'"

}
eststo clear
estpost summarize  `emissions_list'
esttab using "$results_path/summary_statistics.tex", append ///
cells("mean(fmt(%20.2f) label(\multicolumn{1}{c}{Mean} )) sd(fmt(%20.2f) label(\multicolumn{1}{c}{S.D.}) ) min(fmt(%20.2f) label(\multicolumn{1}{c}{Min.}) ) max(fmt(%20.2f) label(\multicolumn{1}{c}{Max.})) count(fmt(%3.0f) label(\multicolumn{1}{c}{N}))  ") ///
nomtitle nonum label f alignment(S S) booktabs nomtitles b(%20.2f) se(%20.2f) eqlabels(none) collabels(none) eform  ///
refcat(nh3_lbs_per_mwh "\emph{Coal Plant Emission Factors, 2011}" , nolabel) noobs substitute(\_ _) noline


	
//Clear Memory
clear all

// Local list of control variables 
global control_list median_income_100 House Senate retail_electricity_price ///
	mgpo interconnection pbf restructured rggi rggi_price_int multiplier_level ///
	unbundled banking_time acp_binary acp_level_primary acp_level_secondary

	 
	
use "$data_path/MAIN_DATASET.dta", clear
label variable out_state_demand_na_twh "Out-of-State REC Demand, TWh"
label variable in_state_demand_na_twh "In-State REC Demand, TWh"
label variable coal_net_gen_mil "Coal Net Generation, TWh"
label variable acp_level_primary "ACP Level: Primary, dollars per REC"
label variable acp_level_secondary "ACP Level: Secondary, dollars per REC"
label variable rggi "RGGI Membership Binary"
label variable restructured "Wholesale Generation Market Binary"
label variable rggi_price_int "RGGI Membership x RGGI CO2 Allowance Price, dollars per permit"
label variable retail_electricity_price "Lagged Retail Electricity price, cents per kWh"
label variable median_income_100 "Median Income, \\$100k"

// Drop years outside our sample
drop if year<1993
drop if year>2013

// Set plant ID
capture drop id
egen id = group(StateFIPS)
drop if missing(id)
xtset id year

// Local list of outcome variables
global ylist st_fossil_twh st_fossil_ratio st_coal_twh ///
	st_gas_twh st_wind_twh st_solar_twh

// Main Results
foreach yvar in $ylist{

	**1. Start with State and Year Fixed Effect**
	qui reghdfe `yvar' out_state_demand_na_twh, a(StateFIPS year) vce(cluster StateFIPS)
	
	estadd scalar KP_Wald_F = .
	estadd scalar Stock_Yogo=.
	estadd local year_dum "Yes"
	estadd local st_time_trend "No"
	estadd local state_fe "Yes"
	estadd local sys_trend "No"
	estadd local sys_year "No"
	estadd local iv "No"

	
	est store `yvar'_1

	**2.Add Correllates**
	qui reghdfe `yvar' out_state_demand_na_twh in_state_demand_na_twh $control_list, a(StateFIPS year) vce(cluster StateFIPS)

	estadd scalar KP_Wald_F = .
	estadd scalar Stock_Yogo=.
	estadd local year_dum "Yes"
	estadd local st_time_trend "No"
	estadd local state_fe "Yes"
	estadd local sys_trend "No"
	estadd local sys_year "No"
	estadd local iv "No"


	est store `yvar'_2
	
	**3. Add NERC Trend**
	qui reghdfe `yvar' out_state_demand_na_twh in_state_demand_na_twh $control_list ///
		, a(StateFIPS year i.nerc_list#c.time) vce(cluster StateFIPS)

	estadd scalar KP_Wald_F = .
	estadd scalar Stock_Yogo=.
	estadd local year_dum "Yes"
	estadd local st_time_trend "No"
	estadd local state_fe "Yes"
	estadd local sys_trend "Yes"
	estadd local sys_year "Yes"
	estadd local iv "No"
	est store `yvar'_3
	
	


	**Make Tex Table
	esttab `yvar'_* using "$results_path/`yvar'_na.tex", replace ///
	label booktabs b(%20.3f) se(%20.3f) eqlabels(none) alignment(S S)  ///
	stats(state_fe year_dum sys_trend  N, ///
	fmt(0 0 0  0 %3.2f  0)layout(  "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") label("State FE" ///
	"Year FE" "Region-Specific Linear Time Trends" "\hline Observations" )) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	se f nomtitles substitute(\_ _)
	
	
}

