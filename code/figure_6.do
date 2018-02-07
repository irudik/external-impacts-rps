////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// FIGURE 6: DAMAGE PER REC VS TOTAL RECS REQUIRED TO MEET 1% RPS INCREASE
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

use  "$data_path/rps_inc_damage_2011_to_2012.dta", clear

// Generate alternative StateFIPS code
rename state state_lower
gen state = upper(state_lower)
gen StateFIPS2=.					
replace StateFIPS = 15	if 	state=="HI"
replace StateFIPS = 1	if 	state=="AL"
replace StateFIPS = 2	if 	state=="AK"
replace StateFIPS = 4	if 	state=="AZ"
replace StateFIPS = 5	if 	state=="AR"
replace StateFIPS = 6	if 	state=="CA"
replace StateFIPS = 8	if 	state=="CO"
replace StateFIPS = 9	if 	state=="CT"
replace StateFIPS = 10	if 	state=="DE"
replace StateFIPS = 11	if 	state=="DC"
replace StateFIPS = 12	if 	state=="FL"
replace StateFIPS = 13	if 	state=="GA"
replace StateFIPS = 16	if 	state=="ID"
replace StateFIPS = 17	if 	state=="IL"
replace StateFIPS = 18	if 	state=="IN"
replace StateFIPS = 19	if 	state=="IA"
replace StateFIPS = 20	if 	state=="KS"
replace StateFIPS = 21	if 	state=="KY"
replace StateFIPS = 22	if 	state=="LA"
replace StateFIPS = 23	if 	state=="ME"
replace StateFIPS = 24	if 	state=="MD"
replace StateFIPS = 25	if 	state=="MA"
replace StateFIPS = 26	if 	state=="MI"
replace StateFIPS = 27	if 	state=="MN"
replace StateFIPS = 28	if 	state=="MS"
replace StateFIPS = 29	if 	state=="MO"
replace StateFIPS = 30	if 	state=="MT"
replace StateFIPS = 31	if 	state=="NE"
replace StateFIPS = 32	if 	state=="NV"
replace StateFIPS = 33	if 	state=="NH"
replace StateFIPS = 34	if 	state=="NJ"
replace StateFIPS = 35	if 	state=="NM"
replace StateFIPS = 36	if 	state=="NY"
replace StateFIPS = 37	if 	state=="NC"
replace StateFIPS = 38	if 	state=="ND"
replace StateFIPS = 39	if 	state=="OH"
replace StateFIPS = 40	if 	state=="OK"
replace StateFIPS = 41	if 	state=="OR"
replace StateFIPS = 42	if 	state=="PA"
replace StateFIPS = 44	if 	state=="RI"
replace StateFIPS = 45	if 	state=="SC"
replace StateFIPS = 46	if 	state=="SD"
replace StateFIPS = 47	if 	state=="TN"
replace StateFIPS = 48	if 	state=="TX"
replace StateFIPS = 49	if 	state=="UT"
replace StateFIPS = 50	if 	state=="VT"
replace StateFIPS = 51	if 	state=="VA"
replace StateFIPS = 53	if 	state=="WA"
replace StateFIPS = 54	if 	state=="WV"
replace StateFIPS = 55	if 	state=="WI"
replace StateFIPS = 56	if 	state=="WY"

// Percent change in damages
gen percent = 100*((total_damages_us_48-total_damages_s_)/total_damages_us_48) if StateFIPS == StateFIPS2

// Merge in change in the RPS values
merge m:1 state_lower using "$data_path/rps_increase_2012.dta"

bysort state_lower: gen order = _n
bysort state_lower: egen max_percent = max(percent)
keep if order == 1 
keep total_damages_us_48 state_lower *holder* max_percent state
sort state_lower

// Create variables for damages per REC and damages per RPS increase
gen damage_per_rec = total_damages_us_48/rec_holder
gen damage_per_rps =  total_damages_us_48/(rps_holder*100)

local replace_list total_damages_us_48 rps_holder rec_holder damage_per_rec damage_per_rps
local state_list ak al ar ca co fl ga hi ia id in ks ky la  mo ms mt nd ne nm nv ok or sc sd tn tx ut va vt wi wv wy 

foreach x in `replace_list' {
	foreach st in `state_list'{
				replace `x' =0 if state_lower=="`st'"
	}
}

// Create variable for RECs required to comply with a 1% RPS increase
gen recs_per_1_rps = (rec_holder/(rps_holder*100))/100000
replace damage_per_rec = -damage_per_rec
gen state_upper = upper(state_lower)

///////////////////////////////
// PLOT

set seed 2
scalar jitter_numb=20
sum damage_per_rec
gen random_variable =  runiform()
gen damage_per_rec_jitt  = damage_per_rec + ((r(max) - r(min))/jitter_numb)*random_variable
sum recs_per_1_rps
gen recs_per_1_rps_jitt  = recs_per_1_rps + ((r(max) - r(min))/jitter_numb)*random_variable
gen total_benefits=(-total_damages_us_48*1.38)/1000000
sum total_benefits
gen total_benefits_jitt  = total_benefits + ((r(max) - r(min))/jitter_numb)*random_variable
replace damage_per_rps=-damage_per_rps*1.38	
gen damage_per_rps_1m = damage_per_rps/1000000

twoway scatter damage_per_rps_1m max_percent ///
	, msymbol(none) mlabel(state) ///
	xtitle("Percent of Benefits Occurring Out-of-State [0-100]", size(3)) ///
	ytitle("") ///
	subtitle("Avoided Damages from 1% RPS Increase, Million $", pos(11) size(3)) ///
	xla(,nogrid noticks) ///
	yla(,nogrid noticks) ///
	plotregion(lstyle("l"))
	
graph export "$results_path/figure_a14.pdf", replace

//Need to Jitter AZ and RI
scatter  damage_per_rec_jitt recs_per_1_rps_jitt , mlabel(state_upper) msymbol(i) mlabposition(0)  mlabsize(2.75) ///
xtitle("Number of RECs (100k) Required for a 1% RPS Increase", size(2.75)) ///
ylabel(, noticks) ///
ytitle("") yscale(noline) ///
subtitle("Avoided Damages per REC ($)", position(11) size(2.75)) ///
title("Beneit per REC Compared to RECs Needed for Marginal RPS Increase", position(11) size(3.75)) ///
note("Note: Points are jittered for clarity", size(2.75)) ///
plotregion(lstyle("l"))


gen str20 z=string(damage_per_rps,"%20.0fc")
gen damage = "$" + z

replace damage = " " + damage if state_upper =="IL"
replace damage = " " + damage if state_upper =="DE"
replace damage = "  " + damage if state_upper =="NC"
replace damage = " " + damage if state_upper =="WA"
replace damage = " " + damage if state_upper =="NY"


twoway scatter damage_per_rec recs_per_1_rps [weight=damage_per_rps], msymbol(Oh)  msize( normal ) ///
	|| scatter damage_per_rec recs_per_1_rps if recs_per_1_rps>5 & damage_per_rec>25, msymbol(none) mlabel(state_upper) mlabposition(0)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if recs_per_1_rps<5 & damage_per_rec>25, msymbol(none) mlabel(state_upper) mlabposition(12) mlabgap(1.5)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="MN", msymbol(none) mlabel(state_upper) mlabposition(12) mlabgap(3.25)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="NY", msymbol(none) mlabel(state_upper) mlabposition(6) mlabgap(3.)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper!="AZ"  & state_upper!="CT" &  state_upper!="NH" , msymbol(none) mlabel(state_upper) mlabposition(12) mlabgap(1)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper=="AZ" &  state_upper!="NH"  & state_upper!="CT" , msymbol(none) mlabel(state_upper) mlabposition(7) mlabgap(.5)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper!="AZ" &  state_upper=="NH"  & state_upper!="CT" , msymbol(none) mlabel(state_upper) mlabposition(6) mlabgap(.5)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper!="AZ" &  state_upper!="NH"  & state_upper=="CT" , msymbol(none) mlabel(state_upper) mlabposition(2) mlabgap(.5)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="IL", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(5) mlabsize(4)  ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="DE", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(1)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="NC", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(3.5)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="WA", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(.5) mlabsize(4)  ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="NY", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(3)  mlabsize(4) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="MI", msymbol(none) mlabel(state_upper) mlabposition(0)   mlabsize(4) ///
	xtitle("REC Quantity Demanded (100k RECs)", size(4)) ///
	ytitle("Avoided Damages per REC ($)", size(4)) ///
	yla(0(10)50, nogrid  labsize(4) ) ///
	xla(,nogrid  labsize(4) ) ///
	legend(off) ///
	plotregion(lstyle("l") margin(r+5))
	
	*	subtitle("Avoided Damage per REC in $", position(11) size(2.75))
	graph export "$results_path/figure_6.pdf", replace	
