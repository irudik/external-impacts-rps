//Make a county damages map
	clear all
	use "$google/RPS/leakage_paper/build_dataset/intermediate_output/county_damages_2011.dta"
	//Keep only the variables I need
		keep StateFIPS CountyFIPS total_damages
	//Adjust for inflation and make positive
		replace total_damages=-total_damages*1.38
	//Reformat ID
		tostring StateFIPS, gen(STATEFPa)
		tostring CountyFIPS, gen(COUNTYFPa)
		gen STATEFP = string(real(STATEFPa),"%02.0f")
		gen COUNTYFP = string(real(COUNTYFPa),"%03.0f")
		
		keep STATEFP COUNTYFP tot*
		
	//Outsheet
		outsheet using "$google/RPS/leakage_paper/build_dataset/intermediate_output/county_damages.csv", comma replace
		save "$google/RPS/leakage_paper/build_dataset/intermediate_output/county_damages.dta", replace

	//Convert the shape file for the lower 48
		clear
		cd "$google/RPS/main_project/latex/paper/maps"
		shp2dta using "$google/RPS/main_project/latex/paper/maps/map_shapefiles/US_county_2011", database(us_county_data) coordinates(us_county_corr) genid(id) replace
		use us_county_data, clear

		replace COUNTYFP="025" if COUNTYFP=="086" & STATEFP=="12"

		merge 1:1 STATEFP COUNTYFP using "$google/RPS/leakage_paper/build_dataset/intermediate_output/county_damages.dta"

		keep if _merge==3
		drop _merge
		sum total_damages, detail
		di r(sum)
		
			//OLD-1,947,209,325.923
			//NEW- 2,671,580,302.42
		spmap total_damages using us_county_corr.dta, id(id) ///
		osize(thin ..)  ocolor(gs10  ..) ///
		clmethod(custom) clbreaks(-10000000 0 10000 100000 1000000 10000000 1000000000) clnumber(6) ///
		fcolor("203 24 29"  "199 233 192" "161 217 155" "116 196 118" "49 163 84" "0 109 44") ///
		legend(label(2 "<0") label(3 "$0 to $10k") label(4 "$10k to $100k") label(5 "$100k to $1M") label(6 "$1M to $10M") label(7 "$10 Million +")  size(*2))
		graph export "$google/RPS/leakage_paper/results/paper/maps/county_total_damages_2011.pdf", replace		


		//Make a state RPS 1% damage map
	clear all
    use "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_inc_damage_2011.dta"
	// Add State FIPS
		replace state=upper(state)
		
	//Keep only one observation per state fips
		bysort state: gen order2=_n
		keep if order2==1
		drop order2
		
	//Keep What we need
		keep  state total_damages_us_48
		

		gen StateFIPS=.					
		replace StateFIPS=	15	if 	state=="HI"
		replace StateFIPS=	1	if 	state=="AL"
		replace StateFIPS=	2	if 	state=="AK"
		replace StateFIPS=	4	if 	state=="AZ"
		replace StateFIPS=	5	if 	state=="AR"
		replace StateFIPS=	6	if 	state=="CA"
		replace StateFIPS=	8	if 	state=="CO"
		replace StateFIPS=	9	if 	state=="CT"
		replace StateFIPS=	10	if 	state=="DE"
		replace StateFIPS=	11	if 	state=="DC"
		replace StateFIPS=	12	if 	state=="FL"
		replace StateFIPS=	13	if 	state=="GA"
		replace StateFIPS=	16	if 	state=="ID"
		replace StateFIPS=	17	if 	state=="IL"
		replace StateFIPS=	18	if 	state=="IN"
		replace StateFIPS=	19	if 	state=="IA"
		replace StateFIPS=	20	if 	state=="KS"
		replace StateFIPS=	21	if 	state=="KY"
		replace StateFIPS=	22	if 	state=="LA"
		replace StateFIPS=	23	if 	state=="ME"
		replace StateFIPS=	24	if 	state=="MD"
		replace StateFIPS=	25	if 	state=="MA"
		replace StateFIPS=	26	if 	state=="MI"
		replace StateFIPS=	27	if 	state=="MN"
		replace StateFIPS=	28	if 	state=="MS"
		replace StateFIPS=	29	if 	state=="MO"
		replace StateFIPS=	30	if 	state=="MT"
		replace StateFIPS=	31	if 	state=="NE"
		replace StateFIPS=	32	if 	state=="NV"
		replace StateFIPS=	33	if 	state=="NH"
		replace StateFIPS=	34	if 	state=="NJ"
		replace StateFIPS=	35	if 	state=="NM"
		replace StateFIPS=	36	if 	state=="NY"
		replace StateFIPS=	37	if 	state=="NC"
		replace StateFIPS=	38	if 	state=="ND"
		replace StateFIPS=	39	if 	state=="OH"
		replace StateFIPS=	40	if 	state=="OK"
		replace StateFIPS=	41	if 	state=="OR"
		replace StateFIPS=	42	if 	state=="PA"
		replace StateFIPS=	44	if 	state=="RI"
		replace StateFIPS=	45	if 	state=="SC"
		replace StateFIPS=	46	if 	state=="SD"
		replace StateFIPS=	47	if 	state=="TN"
		replace StateFIPS=	48	if 	state=="TX"
		replace StateFIPS=	49	if 	state=="UT"
		replace StateFIPS=	50	if 	state=="VT"
		replace StateFIPS=	51	if 	state=="VA"
		replace StateFIPS=	53	if 	state=="WA"
		replace StateFIPS=	54	if 	state=="WV"
		replace StateFIPS=	55	if 	state=="WI"
		replace StateFIPS=	56	if 	state=="WY"
	//Adjust for inflation and make positive
		replace total_damages_us_48=-total_damages_us_48*1.38	
	//Add RPS Binary
		merge 1:m StateFIPS using "$google/RPS/main_project/creating_input_data/output/rps_characteristics.dta"
		keep if year==2011
		keep StateFIPS total_damages rps_primary rps_secondary

		gen rps_binary=0 // Generate binary variable for whether or not RPS is on
		replace rps_binary = 1 if (rps_primary>0 | rps_secondary>0) & ~missing(rps_primary)
		keep StateFIPS total_damages rps_binary

		sum total_damages if rps_binary==1 & total_damages!=0, detail

		bysort StateFIPS: egen rps_ever=max(rps_binary)

		replace total_damages=-9999 if rps_ever==0
		replace total_damages=0 if rps_ever==1 & missing(total_damages)

		keep StateFIPS total_damages
		drop if StateFIPS==11
	//Create the data for plotting
		tostring StateFIPS, gen(STATEFP10a)
		gen STATEFP10 = string(real(STATEFP10a),"%02.0f") 

		keep STATEFP10 total_damages
		
		outsheet using "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_damage_2011.csv", comma replace
		save "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_damage_2011.dta", replace



	//Map tot_damage, which is Total Damage to Row By All States (including self)
	//Convert the shape file for the lower 48
		clear
		cd "$google/RPS/main_project/latex/paper/maps/map_shapefiles"
		shp2dta using us_48_states_2010_wgs_84.shp, database(us_48_data) coordinates(us_48_corr) genid(id) replace
		use us_48_data, clear

		merge 1:1 STATEFP10 using "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_damage_2011.dta"
		keep if _merge==3
		drop _merge

	//plot and save the map  binary for the lower 48
		spmap total_damages using us_48_corr, id(id) ///
		fcolor("200 200 200" "255 255 255" "237 248 233" "186 228 179" "116 196 118" "35 139 69") ///  
		clmethod(custom) clbreaks(-1000000 -.000001 0  750000 7500000 75000000 750000000) clnumber(6) ///
		legend(label(2 "Not an RPS State in 2011") label(3 "$0 (REC trade not allowed)") label(4 "75k - $750k") label(5 "$750k - $7.5M") label(6 "$7.5M-$75M") label(7 "$75 Million+") size(*2)) 
		graph export "$google/RPS/leakage_paper/results/paper/maps/dollar_per_1_rps_2011.pdf", replace
//Make a state marginal REC damage map
	clear all
    use "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_inc_damage_2011.dta"
	// Add State FIPS
		replace state=upper(state)
		
	//Keep only one observation per state fips
		bysort state: gen order2=_n
		keep if order2==1
		drop order2
		
	//Keep What we need
		keep  state total_damages_us_48
		

		gen StateFIPS=.					
		replace StateFIPS=	15	if 	state=="HI"
		replace StateFIPS=	1	if 	state=="AL"
		replace StateFIPS=	2	if 	state=="AK"
		replace StateFIPS=	4	if 	state=="AZ"
		replace StateFIPS=	5	if 	state=="AR"
		replace StateFIPS=	6	if 	state=="CA"
		replace StateFIPS=	8	if 	state=="CO"
		replace StateFIPS=	9	if 	state=="CT"
		replace StateFIPS=	10	if 	state=="DE"
		replace StateFIPS=	11	if 	state=="DC"
		replace StateFIPS=	12	if 	state=="FL"
		replace StateFIPS=	13	if 	state=="GA"
		replace StateFIPS=	16	if 	state=="ID"
		replace StateFIPS=	17	if 	state=="IL"
		replace StateFIPS=	18	if 	state=="IN"
		replace StateFIPS=	19	if 	state=="IA"
		replace StateFIPS=	20	if 	state=="KS"
		replace StateFIPS=	21	if 	state=="KY"
		replace StateFIPS=	22	if 	state=="LA"
		replace StateFIPS=	23	if 	state=="ME"
		replace StateFIPS=	24	if 	state=="MD"
		replace StateFIPS=	25	if 	state=="MA"
		replace StateFIPS=	26	if 	state=="MI"
		replace StateFIPS=	27	if 	state=="MN"
		replace StateFIPS=	28	if 	state=="MS"
		replace StateFIPS=	29	if 	state=="MO"
		replace StateFIPS=	30	if 	state=="MT"
		replace StateFIPS=	31	if 	state=="NE"
		replace StateFIPS=	32	if 	state=="NV"
		replace StateFIPS=	33	if 	state=="NH"
		replace StateFIPS=	34	if 	state=="NJ"
		replace StateFIPS=	35	if 	state=="NM"
		replace StateFIPS=	36	if 	state=="NY"
		replace StateFIPS=	37	if 	state=="NC"
		replace StateFIPS=	38	if 	state=="ND"
		replace StateFIPS=	39	if 	state=="OH"
		replace StateFIPS=	40	if 	state=="OK"
		replace StateFIPS=	41	if 	state=="OR"
		replace StateFIPS=	42	if 	state=="PA"
		replace StateFIPS=	44	if 	state=="RI"
		replace StateFIPS=	45	if 	state=="SC"
		replace StateFIPS=	46	if 	state=="SD"
		replace StateFIPS=	47	if 	state=="TN"
		replace StateFIPS=	48	if 	state=="TX"
		replace StateFIPS=	49	if 	state=="UT"
		replace StateFIPS=	50	if 	state=="VT"
		replace StateFIPS=	51	if 	state=="VA"
		replace StateFIPS=	53	if 	state=="WA"
		replace StateFIPS=	54	if 	state=="WV"
		replace StateFIPS=	55	if 	state=="WI"
		replace StateFIPS=	56	if 	state=="WY"
	//Adjust for inflation and make positive
		replace total_damages_us_48=-total_damages_us_48*1.38	
	//Add RPS Binary
		merge 1:m StateFIPS using "$google/RPS/main_project/creating_input_data/output/rps_characteristics.dta"
		keep if year==2011
		keep StateFIPS total_damages rps_primary rps_secondary state

		gen rps_binary=0 // Generate binary variable for whether or not RPS is on
		replace rps_binary = 1 if (rps_primary>0 | rps_secondary>0) & ~missing(rps_primary)
		keep StateFIPS total_damages rps_binary state


		bysort StateFIPS: egen rps_ever=max(rps_binary)
		
		merge 1:1 StateFIPS using "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_increase_2011_for_cost.dta"

		gen benefit_per_rec=total_damages_us_48/eff_rps_num_diff	
		
		replace benefit_per_rec=-9999 if rps_ever==0
		replace benefit_per_rec=0 if rps_ever==1 & missing(benefit_per_rec)

		
		sum benefit_per_rec if rps_binary==1 & benefit_per_rec!=0, detail

		drop if StateFIPS==11
		
		keep StateFIPS state benefit_per_rec eff_rps_num_diff

	//Create the data for plotting
		tostring StateFIPS, gen(STATEFP10a)
		gen STATEFP10 = string(real(STATEFP10a),"%02.0f") 

		keep STATEFP10 state benefit_per_rec eff_rps_num_diff
		
		outsheet using "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_damage_2011.csv", comma replace
		save "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_per_rec_2011.dta", replace



	//Map tot_damage, which is Total Damage to Row By All States (including self)
	//Convert the shape file for the lower 48
		clear
		cd "$google/RPS/main_project/latex/paper/maps/map_shapefiles"
		shp2dta using us_48_states_2010_wgs_84.shp, database(us_48_data) coordinates(us_48_corr) genid(id) replace
		use us_48_data, clear

		merge 1:1 STATEFP10 using "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_per_rec_2011.dta"
		keep if _merge==3
		drop _merge

	//plot and save the map  binary for the lower 48
		spmap benefit_per_rec using us_48_corr, id(id) ///
		fcolor("200 200 200" "255 255 255" "237 248 233" "186 228 179" "116 196 118" "35 139 69") ///  
		clmethod(custom) clbreaks(-1000000 -.000001 0  2 20 40 750000000) clnumber(6) ///
		legend(label(2 "Not an RPS State in 2011") label(3 "$0 (REC trade not allowed)") label(4 "$1 - $2") label(5 "$2 - $20") label(6 "$20-60") label(7 "$60+") size(*2)) 
		graph export "$google/RPS/leakage_paper/results/paper/maps/dollar_per_rec_2011.pdf", replace
		
		
		
//Export data to make a $ per REC graph in ggplot2
	clear all
	use  "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_per_rec_2011.dta"
	drop if benefit_per_rec < 0 
	drop if state=="HI"
	saveold  "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_per_rec_ggplot.dta", replace version(11)

	//Y Axis- $- Value per additional REC
	//X Axis- # RECs in a 1% RPS increase
	//Change the size based upon? Anything? 
