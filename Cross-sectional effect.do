* Set up dataset
global stacks "D:\A whole new world\proper_stacks"
global all "D:\A whole new world"

use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken




********************** Table 5 here  ********************** 
**** Column 1: leader vs follower
global all "D:\A whole new world"

use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

gen treatpost = -cweaken

gen pcm = (revt - cogs - xsga)/revt

reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_year cohort_firm) vce(cluster id)
gen sample = e(sample)
keep if sample

sort cohort_year sic2 state cohort_firm
by cohort_year sic2 state: egen pcm75 = pctile(pcm), p(75)
by cohort_year sic2 state: egen pcm70 = pctile(pcm), p(70)
by cohort_year sic2 state: egen pcm50 = pctile(pcm), p(50)
by cohort_year sic2 state: egen pcm30 = pctile(pcm), p(30)
by cohort_year sic2 state: egen pcm25 = pctile(pcm), p(25)

drop lead
gen lead = 0
replace lead = 1 if pcm > pcm75

drop follow
gen follow = 0
replace follow = 1 if pcm < pcm25          //Trick: get lower, get rid of single ton group

//reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd if lead==1, absorb(cohort_firm cohort_year) vce(cluster id)
//outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
//reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd if lead==0, absorb(cohort_firm cohort_year) vce(cluster id) 
//outreg2 using CNC_acctcomp.doc, dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)
   // Follower: more flexible to change their accct, Incentive to learn high, so the incentive to change their accounting system is also high...

reghdfe qmean_gdfcomp c.treatpost##follow size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_year cohort_firm) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)





*********** Columns 2: States that higher/lower labor market density
* Set up dataset
global stacks "D:\A whole new world\proper_stacks"
global all "D:\A whole new world"

use "${all}\appended_data.dta", clear

* Generate Cohort-firm and cohort-time 
egen cohort_firm = group (cohort id)
egen cohort_year = group (cohort fyear)

drop _merge

gen treatpost = -cweaken
reghdfe qmean_gdfcomp treatpost size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_year cohort_firm) vce(cluster id)
gen sample = e(sample)
keep if sample

gen captoemp = emp/ppent
sort cohort_year sic2 state cohort_firm
by cohort_year sic2 state: egen captoemp75 = pctile(captoemp), p(75)
by cohort_year sic2 state: egen captoemp70 = pctile(captoemp), p(70)
by cohort_year sic2 state: egen captoemp50 = pctile(captoemp), p(50)
by cohort_year sic2 state: egen captoemp30 = pctile(captoemp), p(30)
by cohort_year sic2 state: egen captoemp25 = pctile(captoemp), p(25)

drop lead
gen lead = 0
replace lead = 1 if captoemp > captoemp70

drop follow
gen follow = 0
replace follow = 1 if captoemp < captoemp25         

reghdfe qmean_gdfcomp c.treatpost##c.follow size sales_g tangible leverage capex1 tobinq sales_g_sd, absorb(cohort_year cohort_firm) vce(cluster id)
outreg2 using CNC_acctcomp.doc, replace dec(4) ctitle() addtext (Year FE,YES, Firm FE, YES)

