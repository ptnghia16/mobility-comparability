use "D:\A whole new world\annual_panel_and_quarterly_acctcomp.dta", clear

winsor2 ln_capgrowth ln_allequitygrowth ln_dlttgrowth ln_corecapitalgrowth capgrowth allequitygrowth dlttgrowth corecapitalgrowth debtissue capex1 capex2 invest_growth2 invest_growth3 companymarketcap MB tobinq cashflow1 cashflow2 size price_return cap_return gross_return earnings NI earnings_g loss roa sales_g roa_sd sales_g_sd cashflow1_sd cashflow2_sd gross_return_sd leverage tangible book_per_share NI_per_share size sales_g tangible leverage capex1 tobinq sales_g_sd q*, c(1 99) replace     

sort id fyear
xtset id fyear, yearly

* gdfcomp_meant4 barthcomp_meant4 mean_gdfcomp mean_barthcomp med_gdfcomp med_barthcomp


gen stronger_year=.
gen weaker_year=.
*replace stronger_year= 1996 if hqstate == "FL"
replace stronger_year= 2004 if state == "OH"
replace stronger_year= 2005 if state == "VT"
replace stronger_year= 2008 if state == "ID"
replace stronger_year= 2009 if state == "WI"
replace stronger_year= 2010 if state == "GA"
replace stronger_year= 2011 if state == "CO"
replace stronger_year= 2011 if state == "IL"
replace stronger_year= 2011 if state == "TX"

*replace weaker_year= 2001 if hqstate == "LA"
replace weaker_year= 2008 if state == "OR"
replace weaker_year= 2010 if state == "SC"
replace weaker_year= 2012 if state == "NH"
replace weaker_year= 2014 if state == "KY"




************************Set directory here************************
global stacks "D:\A whole new world\proper_stacks"
global all "D:\A whole new world"

//drop 1996 and 2001 here. ALso, drop 2005 (VT).

 
local list1 "OH ID WI GA CO IL TX OR SC NH KY"
local list2 2004 2008 2009 2010 2011 2011 2011 2008 2010 2012 2014

local obs1 : word count `list1'
local obs2 : word count `list2'

forvalues i = 1/`obs1' {
	preserve
	local stt : word `i' of `list1'
	local year : word `i' of `list2'
	
	
	keep if fyear >= `year' - 5 & fyear <= `year' + 5
	keep if (weaker_year == `year' & state == "`stt'") | (stronger_year == `year' & state == "`stt'") | (missing(weaker_year) & missing(stronger_year)) | (weaker_year > `year' + 5) | (stronger_year > `year' + 5)         
	
	gen cohort = "cohort_`stt'" 
	
	//gen cohort_weak = 1 if weaker_year == `year'
	//replace cohort_weak  = 0 if missing(cohort_weak)
	//gen cohort_strong = 0
	
	gen cweakenpre7 = 1*(fyear == `year' - 7) if weaker_year == `year'  & state == "`stt'"
	replace cweakenpre7 = -1*(fyear == `year' - 7) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre7 = 0 if missing(cweakenpre7)
	label variable cweakenpre7 "-7"
	
	gen cweakenpre6 = 1*(fyear == `year' - 6) if weaker_year == `year' & state == "`stt'"
	replace cweakenpre6 = -1*(fyear == `year' - 6) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre6 = 0 if missing(cweakenpre6)
	label variable cweakenpre6 "-6"
	
	gen cweakenpre5 = 1*(fyear == `year' - 5) if weaker_year == `year' & state == "`stt'"
	replace cweakenpre5 = -1*(fyear == `year' - 5) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre5 = 0 if missing(cweakenpre5)
	label variable cweakenpre5 "-5"
	
	gen cweakenpre4 = 1*(fyear == `year' - 4) if weaker_year == `year' & state == "`stt'"
	replace cweakenpre4 = -1*(fyear == `year' - 4) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre4 = 0 if missing(cweakenpre4)
	label variable cweakenpre4 "-4"
	
	gen cweakenpre3 = 1*(fyear == `year' - 3) if weaker_year == `year'  & state == "`stt'"
	replace cweakenpre3 = -1*(fyear == `year' - 3) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre3 = 0 if missing(cweakenpre3)
	label variable cweakenpre3 "-3"
	
	gen cweakenpre2 = 1*(fyear == `year' - 2) if weaker_year == `year' & state == "`stt'"
	replace cweakenpre2 = -1*(fyear == `year' - 2) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre2 = 0 if missing(cweakenpre2)
	label variable cweakenpre2 "-2"
	
	gen cweakenpre1 = 1*(fyear == `year' - 1) if weaker_year == `year' & state == "`stt'"
	replace cweakenpre1 = -1*(fyear == `year' - 1) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre1 = 0 if missing(cweakenpre1)
	label variable cweakenpre1 "-1"
	
	gen cweakenpre0 = 1*(fyear == `year' - 0) if weaker_year == `year' & state == "`stt'"
	replace cweakenpre0 = -1*(fyear == `year' - 0) if stronger_year== `year' & state == "`stt'"
	replace cweakenpre0 = 0 if missing(cweakenpre0)
	label variable cweakenpre0 "0"
	
	gen cweakenpos1 = 1*(fyear == `year' + 1) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos1 = -1*(fyear == `year' + 1) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos1  = 0 if missing(cweakenpos1)
	label variable cweakenpos1 "1"
	
	gen cweakenpos2 = 1*(fyear == `year' + 2) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos2 = -1*(fyear == `year' + 2) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos2  = 0 if missing(cweakenpos2)
	label variable cweakenpos2 "2"
	
	gen cweakenpos3 = 1*(fyear == `year' + 3) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos3 = -1*(fyear == `year' + 3) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos3 = 0 if missing(cweakenpos3)
	label variable cweakenpos3 "3"
	
	gen cweakenpos4 = 1*(fyear == `year' + 4) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos4 = -1*(fyear == `year' + 4) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos4 = 0 if missing(cweakenpos4)
	label variable cweakenpos4 "4"
	
	gen cweakenpos5 = 1*(fyear == `year' + 5) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos5 = -1*(fyear == `year' + 5) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos5 = 0 if missing(cweakenpos5)
	label variable cweakenpos5 "5"
	
	gen cweakenpos6 = 1*(fyear == `year' + 6) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos6 = -1*(fyear == `year' + 6) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos6 = 0 if missing(cweakenpos6)
	label variable cweakenpos6 "6"
	
	gen cweakenpos7 = 1*(fyear == `year' + 7) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos7 = -1*(fyear == `year' + 7) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos7 = 0 if missing(cweakenpos7)
	label variable cweakenpos7 "7"
	
	gen cweakenpos3plus = 1*(fyear >= `year' + 3) if weaker_year == `year' & state == "`stt'"
	replace cweakenpos3plus = -1*(fyear >= `year' + 3) if stronger_year== `year' & state == "`stt'"
	replace cweakenpos3plus = 0 if missing(cweakenpos3plus)
	label variable cweakenpos3plus "3+"
	
	gen cweaken = 1*(fyear >= `year') if weaker_year == `year' & state == "`stt'"
	replace cweaken = -1*(fyear >= `year') if stronger_year == `year' & state == "`stt'"
	replace cweaken = 0 if missing(cweaken)
	
	gen cever_treated = 1 if weaker_year == `year' & state == "`stt'"
	replace cever_treated = -1 if stronger_year == `year' & state == "`stt'"
	replace cever_treated = 0 if missing(cever_treated)
	
	gen ttt = -7 if fyear == `year'-7
	replace ttt = -6 if fyear == `year'-6
	replace ttt = -5 if fyear == `year'-5
	replace ttt = -4 if fyear == `year'-4
	replace ttt = -3 if fyear == `year'-3
	replace ttt = -2 if fyear == `year'-2
	replace ttt = -1 if fyear == `year'-1
	replace ttt = 0 if fyear == `year'+0
	replace ttt = 1 if fyear == `year'+1
	replace ttt = 2 if fyear == `year'+2
	replace ttt = 3 if fyear == `year'+3
	replace ttt = 4 if fyear == `year'+4
	replace ttt = 5 if fyear == `year'+5
	replace ttt = 6 if fyear == `year'+6
	replace ttt = 7 if fyear == `year'+7
	
	save "${stacks}\cohort_`stt'.dta", replace
	restore
}


************************ Append **********************************
clear
cd "${stacks}"
append using `: dir . files "*.dta"'

gen cweaker = 0
replace cweaker = 1 if cweaken == 1
gen cstronger = 0
replace cstronger = 1 if cweaken == -1

gen cweakerpre0 = 0
replace cweakerpre0 = 1 if cweakenpre0 == 1
gen cstrongerpre0 = 0
replace cstrongerpre0 = 1 if cweakenpre0 == -1

forvalues i = 1/5 {
	* Pre
	gen cweakerpre`i' = 0
	replace cweakerpre`i' = 1 if cweakenpre`i' == 1
	gen cstrongerpre`i' = 0
	replace cstrongerpre`i' = 1 if cweakenpre`i' == -1
	
	* Pos
	gen cweakerpos`i' = 0
	replace cweakerpos`i' =1 if cweakenpos`i' == 1
	gen cstrongerpos`i' = 0
	replace cstrongerpos`i' =1 if cweakenpos`i' == -1
}

save "${all}\appended_data.dta", replace
clear


************************ Table 2 here *****************************
global stacks "D:\A whole new world\proper_stacks"
global all "D:\A whole new world"

use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken

reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
gen sample = e(sample)
* Group 1: GDF 
reghdfe qmean_gdfcomp treatpost if sample==1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe qmean_gdfcomp treatpost  size sales_g tangible leverage capex1 tobinq sales_g_sd if sample==1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)


drop sample
reghdfe qmean_barth2comp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
gen sample = e(sample)
* Group 3: Barth2
reghdfe qmean_barth2acomp treatpost if sample == 1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe qmean_barth2comp treatpost (size sales_g tangible leverage capex1 tobinq sales_g_sd) if sample == 1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)





************************ Figure 2 here *****************************

global stacks "D:\A whole new world\proper_stacks"
global all "D:\A whole new world"

use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken
gen treatpostpre0 = -cweakenpre0

forvalues i = 1/5 {
	* Pre
	gen treatpostpre`i' = -cweakenpre`i'	
	* Pos
	gen treatpostpos`i' = -cweakenpos`i'

}


* Group 1: GDF 
global weak cweakerpre5 cweakerpre4 cweakerpre3 cweakerpre2 cweakerpre0 cweakerpos1 cweakerpos2 cweakerpos3 cweakerpos4 cweakerpos5
global strong cstrongerpre5 cstrongerpre4 cstrongerpre3 cstrongerpre2 cstrongerpre0 cstrongerpos1 cstrongerpos2 cstrongerpos3 cstrongerpos4 cstrongerpos5

reghdfe qmean_gdfcomp cweakenpre5 cweakenpre4 cweakenpre3 cweakenpre2 cweakenpre0 cweakenpos1 cweakenpos2 cweakenpos3 cweakenpos4 cweakenpos5 size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)  
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)

reghdfe qmean_gdfcomp treatpostpre5 treatpostpre4 treatpostpre3 treatpostpre2 treatpostpre0 treatpostpos1 treatpostpos2 treatpostpos3 treatpostpos4 treatpostpos5 size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)  
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)



drop sample
reghdfe qmean_barth2comp cweaken size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
gen sample = e(sample)
* Group 3: Barth2
reghdfe qmean_barth2comp cweakenpre7 cweakenpre6 cweakenpre5 cweakenpre4 cweakenpre3 cweakenpre2 cweakenpre1 cweakenpos1 cweakenpos2 cweakenpos3 cweakenpos4 cweakenpos5 cweakenpos6 cweakenpos7 if sample == 1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)

reghdfe qmean_barth2comp cweakenpre5 cweakenpre4 cweakenpre3 cweakenpre2 cweakenpre0 cweakenpos1 cweakenpos2 cweakenpos3 cweakenpos4 cweakenpos5  size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)





************************ Table 3 here *****************************
use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken

***** Columns 1: Drop states with judicial Drop treatment cohorts with nonjudicial CNC changes       
* Change in CNC that is not judicial  
drop if cohort == "cohort_ID" | cohort == "cohort_GA" | cohort == "cohort_OR" | cohort == "cohort_NH" 

reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(id fyear) vce(cluster id)
generate sample = e(sample)
* Group 1: GDF 
reghdfe qmean_gdfcomp treatpost if sample ==1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd if sample ==1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)



***** Columns 2: Drop states with partisan judicial elections
use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken

* Partisan election      OH ID WI GA CO IL TX OR SC NH KY
drop if state == "TX" | state == "LA" | state == "AL" | state == "IL" | state == "PA" | state == "NC" 

reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_risk.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)

reghdfe qmean_barth2comp cweaken size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_risk.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)



***** Columns 3: Only neighboring states  
use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken


reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
gen sample = e(sample)
keep if sample == 1

gen tokeep = 0

replace tokeep = 1 if (cohort == "cohort_OH") & (state == "OH" | state == "MI" | state == "PA" | state == "WV" | state == "IN" | state == "KY")
replace tokeep = 1 if (cohort == "cohort_ID") & (state == "ID" | state == "UT" | state == "WA" | state == "WY" | state == "MT" | state == "NV" | state == "NV" | state == "OR")
replace tokeep = 1 if (cohort == "cohort_WI") & (state == "WI" | state == "MI" | state == "MN" | state == "IL" | state == "IA")
replace tokeep = 1 if (cohort == "cohort_GA") & (state == "GA" | state == "NC" | state == "SC" | state == "TN" | state == "AL" | state == "FL")
replace tokeep = 1 if (cohort == "cohort_CO") & (state == "CO" | state == "NM" | state == "OK" | state == "UT" | state == "WY" | state == "AZ" | state == "KS" | state == "NE")
replace tokeep = 1 if (cohort == "cohort_IL") & (state == "IL" | state == "KY" | state == "MO" | state == "WI" | state == "IN" | state == "IA" | state == "MI")
replace tokeep = 1 if (cohort == "cohort_TX") & (state == "TX" | state == "NM" | state == "OK" | state == "AR" | state == "LA")
replace tokeep = 1 if (cohort == "cohort_OR") & (state == "OR" | state == "NV" | state == "WA" | state == "CA" | state == "ID")
replace tokeep = 1 if (cohort == "cohort_SC") & (state == "SC" | state == "SC" | state == "GA")
replace tokeep = 1 if (cohort == "cohort_NH") & (state == "NH" | state == "VT" | state == "MA" | state == "ME")
replace tokeep = 1 if (cohort == "cohort_KY") & (state == "KY" | state == "TN" | state == "VA" | state == "WV" | state == "IL" | state == "IN" | state == "MO" | state == "OH")

keep if tokeep == 1


reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_risk.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES) */