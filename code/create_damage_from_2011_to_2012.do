//This file will create a marginal damages estimate for actual  SO2, NOX, PM 2.5, PM 10, VOC, and NH3
	//for each US County on every other US County
	//Based off of Nick Mueller
	
	clear all
//Set Maximum Number of Variables
	set maxvar 32767 
//Change Working Directory	
	clear all
	cd 

//Get FIPS Ready
	insheet using "$results_path/damage_matrices/fips.csv"
	rename v1 fips

//pull state fips and county fips from this combined one
	tostring fips, replace format(%05.0f)

	gen StateFIPS=substr(fips,1,2)
	gen CountyFIPS=substr(fips,3,3)

	drop fips

	destring StateFIPS, replace
	destring CountyFIPS, replace

	gen order=_n
	save "$temp_path/temp_all_fips.dta", replace

//NOx Damages
	clear all
	cd "$results_path/damage_matrices/"

	//Import Marginal Damages Transport Matrix

		insheet using "$results_path/damage_matrices/nox_md_m_trans.csv"
		gen order=_n
	
		merge 1:1 order using "$temp_path/temp_all_fips.dta"


	//Rename Variables Appropriatley 
		*Use the formate state_#_county_#, where the # is the FIPS code
		*This assumes that the variables in the matrix are in the same order as the fips vector we imported
			ds v*

			local i=1

			foreach variable in `r(varlist)' {

				rename `variable' nox_s_`=StateFIPS[`i']'_c_`=CountyFIPS[`i']'
	
				local i = `i' + 1

			}


			drop _merge
			save "$temp_path/temp_all.dta", replace


//SO2 Damages
	cd "$results_path/damage_matrices/"

	insheet using "$results_path/damage_matrices/so2_md_m_trans.csv", clear
	gen order=_n

	merge 1:1 order using "$temp_path/temp_all_fips.dta"

	//Rename Variables Appropriatley 
		*Use the formate state_#_county_#, where the # is the FIPS code


		ds v*

		local i=1
	
		foreach variable in `r(varlist)' {

			rename `variable' so2_s_`=StateFIPS[`i']'_c_`=CountyFIPS[`i']'
	
			local i = `i' + 1

		}
		drop _merge
		merge 1:1 StateFIPS CountyFIPS using "$temp_path/temp_all.dta"
		drop _merge
		save "$temp_path/temp_all.dta", replace
	
//PM 2.5 Damages
		cd "$results_path/damage_matrices/"

		insheet using "$results_path/damage_matrices/pm25_md_m_trans.csv", clear
		gen order=_n

		merge 1:1 order using "$temp_path/temp_all_fips.dta"

	//Rename Variables Appropriatley 
	*Use the formate state_#_county_#, where the # is the FIPS code


		ds v*

		local i=1

		foreach variable in `r(varlist)' {

			rename `variable' pm_25_s_`=StateFIPS[`i']'_c_`=CountyFIPS[`i']'
	
			local i = `i' + 1

		}
		drop _merge
		merge 1:1 StateFIPS CountyFIPS using "$temp_path/temp_all.dta"
		drop _merge
		save "$temp_path/temp_all.dta", replace

//PM 10 Damages
	cd "$results_path/damage_matrices/"

	insheet using "$results_path/damage_matrices/pm10_md_m_trans.csv", clear
	gen order=_n

	merge 1:1 order using "$temp_path/temp_all_fips.dta"

	//Rename Variables Appropriatley 
	*Use the formate state_#_county_#, where the # is the FIPS code


		ds v*

		local i=1

		foreach variable in `r(varlist)' {

			rename `variable' pm_10_s_`=StateFIPS[`i']'_c_`=CountyFIPS[`i']'
	
			local i = `i' + 1

		}
		drop _merge
		merge 1:1 StateFIPS CountyFIPS using "$temp_path/temp_all.dta"
		drop _merge
		save "$temp_path/temp_all.dta", replace

//VOC Damages
	cd "$results_path/damage_matrices/"

	insheet using "$results_path/damage_matrices/voc_md_m_trans.csv", clear
	gen order=_n

	merge 1:1 order using "$temp_path/temp_all_fips.dta"

	//Rename Variables Appropriatley 
	*Use the formate state_#_county_#, where the # is the FIPS code


		ds v*

		local i=1

		foreach variable in `r(varlist)' {

			rename `variable' voc_s_`=StateFIPS[`i']'_c_`=CountyFIPS[`i']'
	
			local i = `i' + 1

		}
		drop _merge
		merge 1:1 StateFIPS CountyFIPS using "$temp_path/temp_all.dta"
		drop _merge
		save "$temp_path/temp_all.dta", replace

//Ammonia Damages
	cd "$results_path/damage_matrices/"

	insheet using "$results_path/damage_matrices/nh3_md_m_trans.csv", clear
	gen order=_n

	merge 1:1 order using "$temp_path/temp_all_fips.dta"

	//Rename Variables Appropriatley 
	*Use the formate state_#_county_#, where the # is the FIPS code


		ds v*

		local i=1

		foreach variable in `r(varlist)' {

			rename `variable' nh3_s_`=StateFIPS[`i']'_c_`=CountyFIPS[`i']'
	
			local i = `i' + 1

		}
		drop _merge
		merge 1:1 StateFIPS CountyFIPS using "$temp_path/temp_all.dta"
		drop _merge
		save "$temp_path/temp_all.dta", replace

//Combine with emissions as a result of Actual and Marginal RPS increases
	order StateFIPS CountyFIPS 
	sort StateFIPS CountyFIPS 

	merge 1:1 StateFIPS CountyFIPS using  "$data_path/rps_induced_emission_changes_2011_to_2012.dta"
	
	keep if _merge==3
	drop _merge

//Save Intermediate Point 
	save  "$temp_path/temp_2012.dta", replace


	use  "$temp_path/temp_2012.dta", clear
	//Generate Actual Differences

	qui ds nox_s*
	local nox `r(varlist)'

	qui ds so2_s*
	local so2 `r(varlist)' 
	
	qui ds pm_25_s*
	local pm_25 `r(varlist)'

	qui ds pm_10_s*
	local pm_10 `r(varlist)' 
	
	qui ds voc_s*
	local voc `r(varlist)'

	qui ds nh3_s*
	local nh3 `r(varlist)' 
	
	local state_lower  az	ca	co	ct	de	il  ia	ks  me	md	ma	mi mn  mo  mt	nv	nh	nj  nm	ny	nc oh or pa ri  tx wa wi	


	foreach st in `state_lower' {     
		//Load Dataset from Above
			use  "$temp_path/temp_2012.dta", clear
		//Keep only what we need 
			keep StateFIPS CountyFIPS so2_tons_change_`st' nox_tons_change_`st' pm_25_tons_change_`st' pm_10_tons_change_`st' voc_tons_change_`st' nh3_tons_change_`st' `nox' `so2' `pm_25' `pm_10' `voc' `nh3'
				
			foreach pollutant in `nox' {
				gen d_`pollutant'_`st'= `pollutant'*nox_tons_change_`st'
				drop `pollutant'
			}

			foreach pollutant in `so2' {
				gen d_`pollutant'_`st'= `pollutant'*so2_tons_change_`st'
				drop `pollutant'
			}

			foreach pollutant in `pm_25' {
				gen d_`pollutant'_`st'= `pollutant'*pm_25_tons_change_`st'
				drop `pollutant'
			}

			foreach pollutant in `pm_10' {
				gen d_`pollutant'_`st'= `pollutant'*pm_10_tons_change_`st'
				drop `pollutant'
			}

			foreach pollutant in `voc' {
				gen d_`pollutant'_`st'= `pollutant'*voc_tons_change_`st'
				drop `pollutant'
			}

			foreach pollutant in `nh3' {
				gen d_`pollutant'_`st'= `pollutant'*nh3_tons_change_`st'
				drop `pollutant'
			}
	
			keep d_so2_s_* d_nox_s_* d_pm_25_s_* d_pm_10_s_* d_voc_s_* d_nh3_s_*
		//Collapse into one observation

			
			gen order = _n
			
			qui ds d_so2_s_* d_nox_s_* d_pm_25_s_* d_pm_10_s_* d_voc_s_* d_nh3_s_*


			foreach x in `r(varlist)' {
				egen sum_`x' = total(`x')
				drop `x'
			}
	
			keep if order==1
			
			
		//This creates the total damage in each state from all sources in each year
			local fipses 1 4 5	6	8	9	11	10	12	13	19	16	17	18	20	21	22	25	24	23	26	27	29	28	30	37	38	31	33	34	35	32	36	39	40	41	42	44	45	46	47	48	49	51	50	53	55	54	56	

			foreach fips in `fipses' {
	
				egen nox_tot_s_`fips'=rowtotal(sum_d_nox_s_`fips'_*)
				label variable nox_tot_s_`fips' "Total $ NOx Damage in row state"

				egen so2_tot_s_`fips'=rowtotal(sum_d_so2_s_`fips'_*)
				label variable so2_tot_s_`fips' "Total $ SO2 Damage in row state"
	
				egen pm_25_tot_s_`fips'=rowtotal(sum_d_pm_25_s_`fips'_*)
				label variable pm_25_tot_s_`fips' "Total $ PM 2.5 Damage in row state"
	
				egen pm_10_tot_s_`fips'=rowtotal(sum_d_pm_10_s_`fips'_*)
				label variable pm_10_tot_s_`fips' "Total $ PM 10 Damage in row state"
	
				egen voc_tot_s_`fips'=rowtotal(sum_d_voc_s_`fips'_*)
				label variable voc_tot_s_`fips' "Total $ VOC Damage in row state"
	
				egen nh3_tot_s_`fips'=rowtotal(sum_d_nh3_s_`fips'_*)
				label variable nh3_tot_s_`fips' "Total $ NH3 Damage in row state"
				
				egen total_damages_s_`fips'=rowtotal(nox_tot_s_`fips' so2_tot_s_`fips' pm_25_tot_s_`fips' pm_10_tot_s_`fips' voc_tot_s_`fips' nh3_tot_s_`fips')
				label variable total_damages_s_`fips' "Total $ Damage in row state"			
			}
		//Keep Only the New Variables
			keep so2_tot_s_* nox_tot_s_*  pm_25_tot_s_*  pm_10_tot_s_*  voc_tot_s_*  nh3_tot_s_* 	total_damages_s_*

		//Create Total US Damage Variable from All Sources by Pollutant
			egen nox_us_48=rowtotal(nox_tot_s*)
			egen so2_us_48=rowtotal(so2_tot_s*)
			egen pm_25_us_48=rowtotal(pm_25_tot_s*)
			egen pm_10_us_48=rowtotal(pm_10_tot_s*)
			egen voc_us_48=rowtotal(voc_tot_s*)
			egen nh3_us_48=rowtotal(nh3_tot_s*)
			egen total_damages_us_48=rowtotal(total_damages_s_*)

			label variable nox_us_48 "Total $ NOx Damage, US"
			label variable so2_us_48 "Total $ SO2 Damage, US"
			label variable pm_25_us_48 "Total $ PM 2.5 Damage, US"
			label variable pm_10_us_48 "Total $ PM 10 Damage, US"
			label variable voc_us_48 "Total $ VOC Damage, US"
			label variable nh3_us_48 "Total $ NH3 Damage, US"
			label variable total_damages_us_48 "Total $ Damage, US"

		//Reshape the dataset so it's organized by StateFIPS rather than one observation
			gen year=2011
			reshape long nox_tot_s_@ so2_tot_s_@  pm_25_tot_s_@  pm_10_tot_s_@  voc_tot_s_@  nh3_tot_s_@ total_damages_s_@ , i(year) j(StateFIPS)
			gen state = "`st'"
		//Save State Level and US Level Damage datasetfrom ALL sources by Pollutant in the proper format
			save  "$data_path/state_us_damages_from_`st'_rps_inc_2011_to_2012.dta", replace
		//Make Noise When Done with One State
			*!afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/Forward.aiff

	}

	//Append the datasets
	clear all
	use  "$data_path/state_us_damages_from_az_rps_inc_2011_to_2012.dta"
	local state_lower  	ca	co	ct	de	il  ia	ks  me	md	ma	mi mn  mo  mt	nv	nh	nj  nm	ny	nc oh or pa ri  tx wa wi	

	//local state_lower  ca	co	ct	de	il  ia	ks  me	md	ma	mn  mo  mt	nv	nh	nj  nm	ny	nc oh or pa ri  tx wi	

	foreach  st in `state_lower' {
		append using  "$data_path/state_us_damages_from_`st'_rps_inc_2011_to_2012.dta"
	}

	save  "$data_path/rps_inc_damage_2011_to_2012.dta", replace

// Erase temp datasets
	erase   "$temp_path/temp_2012.dta"
	erase 	"$temp_path/temp_all_fips.dta"
	erase	"$temp_path/temp_all.dta"
	
