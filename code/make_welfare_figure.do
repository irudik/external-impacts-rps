
use  "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_inc_damage_2011_to_2012.dta", clear


rename state state_lower
merge m:1 state_lower  using  "$google/RPS/leakage_paper/build_dataset/intermediate_output/rps_increase_2012.dta"

bysort state_lower: gen order = _n
keep if order ==1 
keep total_damages_us_48 state_lower *holder*
sort state_lower

gen damage_per_rec = total_damages_us_48/rec_holder
gen damage_per_rps =  total_damages_us_48/(rps_holder*100)


local replace_list total_damages_us_48 rps_holder rec_holder damage_per_rec damage_per_rps
local state_list ak al ar ca co fl ga hi ia id in ks ky la  mo ms mt nd ne nm nv ok or sc sd tn tx ut va vt  wi wv wy //Should WA be on this list?

foreach x in `replace_list' {
	foreach st in `state_list'{
				replace `x' =0 if state_lower=="`st'"

	}

}

gen recs_per_1_rps = (rec_holder/(rps_holder*100))/100000
replace damage_per_rec = -damage_per_rec
gen state_upper = upper(state_lower)

set seed 2
scalar jitter_numb=20
sum damage_per_rec
gen random_variable =  runiform()
gen damage_per_rec_jitt  = damage_per_rec + ((r(max) - r(min))/jitter_numb)*random_variable
sum recs_per_1_rps
gen recs_per_1_rps_jitt  = recs_per_1_rps + ((r(max) - r(min))/jitter_numb)*random_variable


//Need to Jitter AZ and RI
scatter  damage_per_rec_jitt recs_per_1_rps_jitt , mlabel(state_upper) msymbol(i) mlabposition(0)  mlabsize(2.75) ///
xtitle("Number of RECs (100k) Required for a 1% RPS Increase", size(2.75)) ///
ylabel(, noticks) ///
ytitle("") yscale(noline) ///
subtitle("Avoided Damage per REC in $", position(11) size(2.75)) ///
title("Beneit per REC Compared to RECs Needed for Marginal RPS Increase", position(11) size(3.75)) ///
note("Note: Points are jittered for clarity", size(2.75))

		replace damage_per_rps=-damage_per_rps*1.38	

gen str20 z=string(damage_per_rps,"%20.0fc")
gen damage = "$" + z

replace damage = " " + damage if state_upper =="IL"
replace damage = " " + damage if state_upper =="DE"
replace damage = "  " + damage if state_upper =="NC"
replace damage = " " + damage if state_upper =="WA"
replace damage = " " + damage if state_upper =="NY"


twoway scatter damage_per_rec recs_per_1_rps [weight=damage_per_rps], msymbol(Oh)  msize( normal ) ///
	|| scatter damage_per_rec recs_per_1_rps if recs_per_1_rps>5 & damage_per_rec>25, msymbol(none) mlabel(state_upper) mlabposition(0) ///
	|| scatter damage_per_rec recs_per_1_rps if recs_per_1_rps<5 & damage_per_rec>25, msymbol(none) mlabel(state_upper) mlabposition(12) mlabgap(1.5) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="MN", msymbol(none) mlabel(state_upper) mlabposition(12) mlabgap(3.25) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="NY", msymbol(none) mlabel(state_upper) mlabposition(6) mlabgap(3.) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper!="AZ"  & state_upper!="CT" &  state_upper!="NH" , msymbol(none) mlabel(state_upper) mlabposition(12) mlabgap(1) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper=="AZ" &  state_upper!="NH"  & state_upper!="CT" , msymbol(none) mlabel(state_upper) mlabposition(7) mlabgap(.5) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper!="AZ" &  state_upper=="NH"  & state_upper!="CT" , msymbol(none) mlabel(state_upper) mlabposition(6) mlabgap(.5) ///
	|| scatter damage_per_rec recs_per_1_rps if damage_per_rec<10 & state_upper!="AZ" &  state_upper!="NH"  & state_upper=="CT" , msymbol(none) mlabel(state_upper) mlabposition(2) mlabgap(.5) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="IL", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(5) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="DE", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(1) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="NC", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(3.5) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="WA", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(.5) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="NY", msymbol(none) mlabel(damage) mlabposition(3) mlabgap(3) ///
	|| scatter damage_per_rec recs_per_1_rps if state_upper=="MI", msymbol(none) mlabel(state_upper) mlabposition(0)  ///
	ylabel(, noticks) ///
	xtitle("Number of RECs (100k) Required for a 1% RPS Increase", size(2.75)) ///
	ytitle("") yscale(noline) ///
	legend(off) ///
	subtitle("Avoided Damage per REC in $", position(11) size(2.75))
	///
	*title("Beneit per REC Compared to RECs Needed for Marginal RPS Increase", position(11) size(3.75)) ///
	*note("Note: Size of circle displays aggregate U.S. benefit from the out-of-state emissions reduction induced by the reported state raising its RPS by 1%.", size(2))

	graph export "$google/RPS/leakage_paper/results/paper/state_rps_increase_damage_per_rec.pdf", replace
