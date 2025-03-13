global newhome "D:\A whole new world\pair"

use "$newhome\annual_panel_and_quarterly_acctcomp.dta", clear

egen id_xid = group(gvkey xgvkey)
sort id_xid fyear
xtset id_xid fyear, yearly

winsor2 gdfcomp barth2comp *_diff *_min, c(1 99) replace 
 

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
global stacks "D:\A whole new world\pair\proper_stacks"
global all "D:\A whole new world\pair"


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
	

	save "${stacks}\cohort_`stt'.dta", replace
	restore
}


************************ Append **********************************
global stacks "D:\A whole new world\pair\proper_stacks"
global all "D:\A whole new world\pair"

local list1 "OH ID WI GA CO IL TX OR SC NH KY"
local list2 2004 2008 2009 2010 2011 2011 2011 2008 2010 2012 2014

local obs1 : word count `list1'
local obs2 : word count `list2'

forvalues i = 1/`obs1' {
	local stt : word `i' of `list1'
	local year : word `i' of `list2'
	use "${stacks}\cohort_`stt'.dta", clear
	keep cohort id_xid fyear barth2comp gdfcomp *_diff *_min cweaken* 
	compress
	save "${stacks}\cohort_`stt'.dta", replace
}

clear
cd "${stacks}"
append using `: dir . files "*.dta"'

/*gen cweaker = 0
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
}*/

save "${all}\appended_data.dta", replace


************************ Table 4 here *****************************
// Firm-pair level evidence
global stacks "D:\A whole new world\pair\proper_stacks"
global all "D:\A whole new world\pair"

use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id_xid)
egen cohort_year = group (cohort fyear)

keep gdfcomp barth2comp cweaken *_diff *_min cohort_firm cohort_year id_xid

winsor2 gdfcomp barth2comp *_diff *_min, c(1 99) replace 

gen treatpost = -cweaken

reghdfe gdfcomp treatpost *_diff *_min, absorb(cohort_firm cohort_year) vce(cluster id_xid) 
gen sample = e(sample)
reghdfe gdfcomp treatpost if sample == 1, absorb(cohort_firm cohort_year) vce(cluster id_xid) 
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)

reghdfe gdfcomp treatpost *_diff *_min if sample == 1, absorb(cohort_firm cohort_year) vce(cluster id_xid) 
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)

asdoc tabstat gdfcomp treatpost *_diff *_min if sample==1, stat(N mean sd p25 median p75) col(stat) format(%9.4f) replace








