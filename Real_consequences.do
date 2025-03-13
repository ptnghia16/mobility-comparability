* Additional analysis
use "D:\A whole new world\annual_panel_and_quarterly_acctcomp.dta", clear

sort id fyear
xtset id fyear, yearly


gen capgrowth = (icapt/l.icapt)
gen ln_capgrowth = log(icapt/l.icapt)
gen allequity = icapt - dltt
gen allequitygrowth = (allequity/l.allequity)
gen ln_allequitygrowth = log(allequity/l.allequity)
gen dlttgrowth = (dltt/l.dltt)
gen ln_dlttgrowth = log(dltt/l.dltt)

gen corecapital = ceq + caps
gen corecapitalgrowth = (dltt/l.dltt)
gen ln_corecapitalgrowth = log(dltt/l.dltt)

gen debtissue = (dltis - dltr)/l.at


winsor2 ln_capgrowth ln_allequitygrowth ln_dlttgrowth ln_corecapitalgrowth capgrowth allequitygrowth dlttgrowth corecapitalgrowth debtissue capex1 capex2 invest_growth2 invest_growth3 companymarketcap MB tobinq cashflow1 cashflow2 size price_return cap_return gross_return earnings NI earnings_g loss roa sales_g roa_sd sales_g_sd cashflow1_sd cashflow2_sd gross_return_sd leverage tangible book_per_share NI_per_share q*, c(1 99) replace    

 
reghdfe ln_capgrowth weaken size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(id fyear) vce(cluster id) 


****** Change in comparability: pre-post change in comparability around the treatment -5 + 5: then use the median to identify high change vs low change...
global all "D:\A whole new world"
use "${all}\appended_data.dta", clear

keep if cever_treated != 0

sort id ttt 
by id: egen meanpre = mean(qmean_gdfcomp) if ttt < 0
by id: egen meanpos = mean(qmean_gdfcomp) if ttt > 0

gen post =.
replace post = 0 if ttt < 0
replace post = 1 if ttt > 0


collapse (mean) meanpre meanpos, by(id)

drop if missing(meanpos) | missing(meanpre)
drop if meanpos == 0 | meanpre == 0
gen delta_gdf = meanpos - meanpre 

xtile  delta_gdf_quartile  = delta_gdf, nq(4)

asdoc tabstat delta_gdf, stat(N mean sd p25 median p75) by( delta_gdf_quartile) col(stat) format(%9.4f) replace

keep id delta_gdf_quartile  
save "D:\A whole new world\delta_gdf_quartile.dta", replace


****************************
****** Add to Add: Change in comparability: pre-post change in comparability around the treatment -5 + 5: then use the median to identify high change vs low change...
global all "D:\A whole new world"
use "${all}\appended_data.dta", clear

keep if cever_treated != 0

sort id ttt 
by id: egen meanpre = mean(qgdfcomp) if ttt < 0
by id: egen meanpos = mean(qgdfcomp) if ttt > 0

gen post =.
replace post = 0 if ttt < 0
replace post = 1 if ttt > 0


collapse (mean) meanpre meanpos, by(id)

drop if missing(meanpos) | missing(meanpre)
drop if meanpos == 0 | meanpre == 0
gen delta_gdf = meanpos - meanpre 

xtile  delta_gdf_quartile  = delta_gdf, nq(4)

keep id delta_gdf_quartile  
save "D:\A whole new world\delta_last_gdf_quartile.dta", replace
****************************



******  Merging
global stacks "D:\A whole new world\proper_stacks"
global all "D:\A whole new world"

use "${all}\appended_data.dta", clear

drop _merge
* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

merge m:1 id using "D:\A whole new world\delta_gdf_quartile.dta"
*merge m:1 id using "D:\A whole new world\delta_last_gdf_quartile.dta"

gen treatpost = -cweaken

foreach stt in CO GA ID IL KY NH OH OR SC TX WI{
	drop if ((state == "`stt'") & (cohort == "cohort_`stt'") & missing(delta_gdf_quartile))
	replace delta_gdf_quartile = 0 if ((state == "`stt'") & (cohort != "cohort_`stt'")) //& !missing(delta_gdf_quartile))
}

reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_year cohort_firm) vce(cluster id)
gen s = e(sample)
keep if s == 1

replace delta_gdf_quartile = 0 if missing(delta_gdf_quartile)

gen delta_gdf_half = 1*(delta_gdf_quartile == 1 | delta_gdf_quartile == 2) + 2*(delta_gdf_quartile == 3 | delta_gdf_quartile == 4)

/*
reghdfe ln_capgrowth treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe capex1 treatpost size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
*/

**** jackpot
reghdfe ln_capgrowth c.treatpost##ib0.(delta_gdf_quartile) size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe capex1 c.treatpost##ib0.(delta_gdf_quartile) size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)


**** 
gen treatpost1 = treatpost*(delta_gdf_quartile == 1)
gen treatpost2 = treatpost*(delta_gdf_quartile == 2)
gen treatpost3 = treatpost*(delta_gdf_quartile == 3)
gen treatpost4 = treatpost*(delta_gdf_quartile == 4)

****************  Lets goooooooooooooo
reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)


reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
test treatpost1 - treatpost4 = 0
local sign_ag = sign(_b[treatpost1] - _b[treatpost4])
display "H_0: left >= right p-value = " normal(`sign_ag'*sqrt(r(F)))

reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
test treatpost1 - treatpost4 = 0
local sign_ag = sign(_b[treatpost1] - _b[treatpost4])
display "H_0: left >= right p-value = " normal(`sign_ag'*sqrt(r(F)))
****************

/****************
reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)

reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
test treatpost1 - treatpost4 = 0
local sign_ag = sign(_b[treatpost1] - _b[treatpost4])
display "H_0: left >= right p-value = " normal(`sign_ag'*sqrt(r(F)))

reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
test treatpost1 - treatpost4 = 0
local sign_ag = sign(_b[treatpost1] - _b[treatpost4])
display "H_0: left >= right p-value = " normal(`sign_ag'*sqrt(r(F)))
****************/



// Panel A
reghdfe ln_capgrowth treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
gen s1 = e(sample)
reghdfe capex1 treatpost size sales_g tangible leverage tobinq sales_g_sd if s==1, absorb(cohort_year cohort_firm) vce(cluster id)
gen s2 = e(sample)

reghdfe ln_capgrowth treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd if s1==1, absorb(cohort_year cohort_firm) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe capex1 treatpost size sales_g tangible leverage tobinq sales_g_sd if s2==1, absorb(cohort_year cohort_firm) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)



// Panel C 
reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s1==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s2==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)


reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s1==1, absorb(cohort_year) vce(cluster id)
test treatpost1 - treatpost4 = 0
local sign_ag = sign(_b[treatpost1] - _b[treatpost4])
display "H_0: left >= right p-value = " normal(`sign_ag'*sqrt(r(F)))

reghdfe ln_capgrowth ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage capex1 tobinq sales_g_sd if s1==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)


reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s2==1, absorb(cohort_year) vce(cluster id)
test treatpost1 - treatpost4 = 0
local sign_ag = sign(_b[treatpost1] - _b[treatpost4])
display "H_0: left >= right p-value = " normal(`sign_ag'*sqrt(r(F)))

reghdfe capex1 ib0.(delta_gdf_quartile) treatpost1 treatpost2 treatpost3 treatpost4 size sales_g tangible leverage tobinq sales_g_sd if s2==1, absorb(cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
