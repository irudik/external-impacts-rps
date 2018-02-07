		
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// FIGURE 3: QUANTITY SUPPLIED VS QUANTITY DEMANDED FOR RECS
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Use State Level Dataset
use "$data_path/MAIN_DATASET.dta", clear

// Generate State Renewable Supply
egen st_supply_mwh_renew_no_hyd = rowtotal(st_gen_mwh_bio st_gen_mwh_geo   st_gen_mwh_solar st_gen_mwh_wind st_gen_mwh_wood)

// Generate State Renewable Demanded	
gen st_demand_mwh_na = in_state_demand_na
 
// Collapse By Year
collapse (sum) st_supply_mwh_renew_no_hyd ///
	in_state_demand_na , by(year)

// Divide by 1,000,000
ds year, not
foreach x in `r(varlist)' {
	replace `x' = `x'/1000000
}

tostring year, gen(year_label)
 
// Quantity of RECs Supplied vs Quantity of RECs Demanded
twoway (scatter st_supply_mwh_renew_no_hyd in_state_demand_na, mlabel(year_label) mlabsize(4) ) ///
   (line in_state_demand_na in_state_demand_na) ///
   , legend(off) ///
   graphr(color(white)) ///
	xlabel(0(50)250, nogrid noticks labsize(4) ) ///
	xscale(range(0 250)) ///
	ylabel(0(50)250 ,nogrid noticks labsize(4)) ///
	ytitle("Renewable Quantity Supplied (Million MWhs)", size(4))  ///
	xtitle("REC Quantity Demanded (Million RECs)", size(4)) ///
	plotregion(lstyle("l") margin(r+10))
	graph export "$results_path/figure_3.pdf", replace

