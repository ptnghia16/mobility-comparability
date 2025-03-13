use "D:\A whole new world\North America\North America\Compustat Daily Updates - Fundamentals Annual\lagslr2xeborqsb0.dta", clear

* Only keep what we need
keep gvkey ceq capx oancf prcc_f conm mkvalt loc csho cusip datadate fyear dp dvt ebit ebitda epspx naics ib xopr ppent revt xsga sic state at dltt dlc   icapt dltis dltr scstkc spstkc caps lt cogs xsga emp

* Drop firms outside USA
keep if loc == "USA"

* Drop: financial (SIC code 6000-6999) and utility industries (SIC code 4900-4999).
drop if sic >= "6000" & sic <= "6999"
drop if sic >= "4900" & sic <= "4999"

*** Drop holding companies
drop if strpos(lower(conm), " holding") > 0
drop if strpos(lower(conm), " group") > 0
drop if strpos(lower(conm), " adr") > 0
drop if strpos(lower(conm), " lp") > 0

* Drop all firms which still have duplicates in id, fyear
sort gvkey fyear
duplicates tag gvkey fyear, generate(dup)
by gvkey: egen sumdup = sum(dup)
drop if sumdup > 0


encode gvkey, gen(id)
xtset id fyear, yearly
sort id fyear

* X-digit SIC and NAICS
gen sic2 = substr(sic,1,2)
gen sic3 = substr(sic,1,3)
gen sic4 = substr(sic,1,4)
gen naics2 = substr(naics,1,2)
gen naics3 = substr(naics,1,3)
gen naics4 = substr(naics,1,4)
gen naics5 = substr(naics,1,5)
gen naics6 = substr(naics,1,6)


sort id fyear
* Imputing 
foreach vari in naics2 naics3 naics4 naics5 naics6 sic2 sic3 sic4 state {
	by id: replace `vari' = `vari'[_n-1] if missing(`vari')
}

foreach vari in naics2 naics3 naics4 naics5 naics6 sic2 sic3 sic4 state {
	by id: replace `vari' = `vari'[_n+1] if missing(`vari')
}


** Generate all variables of interest

* FnF: create the total equity variable:
gen et = at - lt

**** focal firms' characteristics
* dependent variables: capex scaled by lagged assets
gen capex1 = capx/l.at
gen capex2 = capx/l.ppent

*gen invest1 = (researchanddevelopment-capitalexpenditurescumulative)/l.totalassetsreported
*gen invest_growth1 = totalfixedassetsnet/l.totalfixedassetsnet
gen invest_growth2 = ppent/l.ppent
gen invest_growth3 = at/l.at


* independent variables: capex scaled by lagged assets
gen companymarketcap = prcc_f*csho
gen MB = (at - et + companymarketcap)/at 
gen tobinq = (dlc + dltt + companymarketcap)/at
gen cashflow1 = ebitda/l.at
gen cashflow2 = oancf/l.at
gen size = ln(at)

gen price_return = prcc_f/l.prcc_f -1 
gen cap_return = companymarketcap/l.companymarketcap -1 
replace dvt = 0 if missing(dvt)
gen gross_return = (companymarketcap+dvt)/l.companymarketcap -1 

gen earnings = ib/l.companymarketcap
gen NI = ib/l.at
gen earnings_g = (ib-l.ib)/l.companymarketcap
gen loss = (ib<0)*1 if missing(ib) == 0

* More independent variables
gen roa = ib/l.at
gen sales_g = revt/l.revt

*** For more analysis
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
***

sort id fyear
rangestat (sd) roa sales_g cashflow1 cashflow2 gross_return, interval(fyear -3 0) by(id)
by id: replace roa_sd=. if _n <= 3
by id: replace sales_g_sd=. if _n <= 3
by id: replace cashflow1_sd=. if _n <= 3
by id: replace cashflow2_sd=. if _n <= 3
by id: replace gross_return_sd=. if _n <= 3

gen leverage = (at - et)/at
gen tangible = ppent/at
gen book_per_share = et/csho
gen NI_per_share = ib/csho



save "D:\A whole new world\annual panel cleaned.dta", replace



/************************************************************************************* 
Step 1: Merging with Qacctcomp
Step 2: Code changes in CNC enforceability
Step 3: Save the final dataset
*************************************************************************************/

* Load the annual panel
use "D:\A whole new world\annual panel cleaned.dta", clear

* Merge with the Q acctcomp dataset
merge 1:1 gvkey fyear using "D:\A whole new world\quarterly_acctcomp.dta"

* Drop if missing
keep if _merge == 3

drop qgvkey qfyearq qid 


*************** * Coding changes in CNC enforceability 
sort id fyear
xtset id fyear, yearly

*** A single variable of shocks
gen weaken = 0
*Nine states strengthen
*replace weaken = -1 if fyear >= 1996 & state == "FL"
replace weaken = -1 if fyear >= 2004 & state == "OH"
replace weaken = -1 if fyear >= 2005 & state == "VT"
replace weaken = -1 if fyear >= 2008 & state == "ID"
replace weaken = -1 if fyear >= 2009 & state == "WI"
replace weaken = -1 if fyear >= 2010 & state == "GA"
replace weaken = -1 if fyear >= 2011 & state == "CO"
replace weaken = -1 if fyear >= 2011 & state == "IL"
replace weaken = -1 if fyear >= 2011 & state == "TX"

* Five states weaken
*replace weaken = 1 if fyear >= 2001 & state == "LA"
replace weaken = 1 if fyear >= 2008 & state == "OR"
replace weaken = 1 if fyear >= 2010 & state == "SC"
replace weaken = 1 if fyear >= 2012 & state == "NH"
replace weaken = 1 if fyear >= 2014 & state == "KY"

*** A single variable of shocks
gen stronger = 0
*Nine states strengthen
*replace weaken = -1 if fyear >= 1996 & state == "FL"
replace stronger = 1 if fyear >= 2004 & state == "OH"
replace stronger = 1 if fyear >= 2005 & state == "VT"
replace stronger = 1 if fyear >= 2008 & state == "ID"
replace stronger = 1 if fyear >= 2009 & state == "WI"
replace stronger = 1 if fyear >= 2010 & state == "GA"
replace stronger = 1 if fyear >= 2011 & state == "CO"
replace stronger = 1 if fyear >= 2011 & state == "IL"
replace stronger = 1 if fyear >= 2011 & state == "TX"

* Five states weaken
gen weaker = 0
*replace weaken = 1 if fyear >= 2001 & state == "LA"
replace weaker = 1 if fyear >= 2008 & state == "OR"
replace weaker = 1 if fyear >= 2010 & state == "SC"
replace weaker = 1 if fyear >= 2012 & state == "NH"
replace weaker = 1 if fyear >= 2014 & state == "KY"



save "D:\A whole new world\annual_panel_and_quarterly_acctcomp.dta", replace
