* Propensity score matching data for the year immediately before the treatment year
* Match for each stacks

global stacks "D:\A whole new world\proper_stacks"
global PSM "D:\A whole new world\proper_PSM"
global all "D:\A whole new world"


local list1 "OH ID WI GA CO IL TX OR SC NH KY"
local list2 2004 2008 2009 2010 2011 2011 2011 2008 2010 2012 2014

local obs1 : word count `list1'


forvalues i = 1/`obs1'  { 
	
	local stt : word `i' of `list1'
	local year : word `i' of `list2'
	
	use "${stacks}\cohort_`stt'.dta", clear
	keep if fyear == `year'-1
	drop if state != "`stt'" & (weaker_year == `year' | stronger_year == `year') 
	drop fyear
	
	gen treat = 0
	replace treat = 1 if  state == "`stt'" & (weaker_year == `year' | stronger_year == `year') 
	* Propensity Score Matching
	psmatch2 treat size sales_g tangible leverage capex1 tobinq sales_g_sd, n(1) caliper(0.1) logit //noreplacement
	preserve
	save "${PSM}\balance_check\matched_`stt'.dta", replace    
	restore
	keep id treat _pscore _treated _support _weight _id _n1 _nn _pdif
	save "${PSM}\matched_`stt'.dta", replace	
	
	* Step 1: Merge pre-matched stacks with post-matched stacks (using id) so that each firms observation have their _id assigned by PSM
	use "${stacks}\cohort_`stt'.dta", clear
	drop _merge
	merge m:1 id using "${PSM}\matched_`stt'.dta"
	keep if _merge==3 & _support==1
	save "${PSM}\mergesample_`stt'.dta", replace
	
	* Step 2: In the post-matched stacks, Extract _id of the treated obs and their matched counterfactual obs. Turns this from wide to long form
	use "${PSM}\matched_`stt'.dta", clear
	keep if _support==1    
	drop if missing(_n1)    //only retain treated firms
	rename _id _id1         //ID of treated unit
	rename _n1 _id0			//ID of counterfactual unit	
	
	//Verse 1: noreplacement
	*reshape long _id, i(id) j(treat_nvm) 
	*keep treat_nvm _id
	
	//Verse 2: with replacement
	gen _aid1 = _id1*id
	gen _aid0 = _id0*id
	reshape long _aid, i(id) j(treat_nvm)
	
	gen _id = _aid/id
	keep treat_nvm _id
	duplicates drop _id, force
	save "${PSM}\matched_only_`stt'.dta", replace
	
	* Step 3: Merge the pre-matched sample (now with _id available) with the correspending _id. Then only retain the treated and their counterfactuals 
	use "${PSM}\mergesample_`stt'.dta", clear
	drop _merge
	merge m:1 _id using "${PSM}\matched_only_`stt'.dta"
	keep if _merge==3
	drop _merge
	save "${PSM}\finaldataset\mergesample_`stt'.dta", replace	
}



************************ Append **********************************
global stacks "D:\A whole new world\proper_stacks"
global PSM "D:\A whole new world\proper_PSM"
global all "D:\A whole new world"


cd "${PSM}\finaldataset"
clear
append using `: dir . files "*.dta"'

save "${all}\PSM_appended_data.dta", replace





************************ Table 3 here *****************************

use "${all}\PSM_appended_data.dta", clear

egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)


***** Columns 4: Propensity score matched sample
reghdfe qmean_gdfcomp cweaken size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
gen sample = e(sample)
* Group 1: GDF 
reghdfe qmean_gdfcomp cweaken if sample==1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
reghdfe qmean_gdfcomp cweaken size sales_g tangible leverage capex1 tobinq sales_g_sd if sample==1, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)





************************ Figure 2 here *****************************
// Dynamic effect on the propensity score matched sample
use "${all}\PSM_appended_data.dta", clear

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

reghdfe qmean_gdfcomp treatpostpre5 treatpostpre4 treatpostpre3 treatpostpre2 treatpostpre0 treatpostpos1 treatpostpos2 treatpostpos3 treatpostpos4 treatpostpos5  size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)


reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_firm cohort_year) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
