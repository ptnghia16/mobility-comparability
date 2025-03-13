global home "D:\A whole new world"

use "D:\A whole new world\North America\North America\Compustat Daily Updates - Fundamentals Quarterly\m8i1s5nucyhtps3d.dta", clear

* Only keep what we need
keep gvkey datadate fyearq fqtr fyr conm tic loc state naics sic uniamiq prccq iby ibmiiy ibcomy oancfy oibdpq teqq ceqq dvy cshoq mkvaltq atq

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


*** Generate quarterly date
gen qdate = yq(fyearq,fqtr)

* Drop all firms which still have duplicates in id, fyear and fquarter, which are mostly due to change in reporting day of choice
sort gvkey qdate
duplicates tag gvkey qdate, generate(dup)
by gvkey: egen sumdup = sum(dup)
drop if sumdup > 0


encode gvkey, gen(id)
xtset id qdate, quarterly
sort id qdate

* X-digit SIC and NAICS
gen sic2 = substr(sic,1,2)
gen sic3 = substr(sic,1,3)
gen sic4 = substr(sic,1,4)
gen naics2 = substr(naics,1,2)
gen naics3 = substr(naics,1,3)
gen naics4 = substr(naics,1,4)
gen naics5 = substr(naics,1,5)
gen naics6 = substr(naics,1,6)


* Imputing 
foreach vari in naics2 naics3 naics4 naics5 naics6 sic2 sic3 sic4 state {
	by id: replace `vari' = `vari'[_n-1] if missing(`vari')
}

foreach vari in naics2 naics3 naics4 naics5 naics6 sic2 sic3 sic4 state {
	by id: replace `vari' = `vari'[_n+1] if missing(`vari')
}
    
  
save "$home\cleaned_quarterly_data.dta", replace

****************************************************************************************************************************************************************************************      
  

* Calculate comparability
use "$home\cleaned_quarterly_data.dta", clear


* Create rolling regression to create proxy for accounting systems
sort id qdate
xtset id qdate, quarterly

gen companymarketcap = cshoq*prccq 
gen earnings = iby/l.companymarketcap 

gen price_return = prccq/l.prccq -1 
gen cap_return = companymarketcap/l.companymarketcap -1 
replace dvy = 0 if missing(dvy)
gen gross_return = (companymarketcap+dvy)/l.companymarketcap -1 

gen bve = ceqq/cshoq
gen NI = iby/cshoq

gen NI_over_price = NI/l.prccq 
gen delta_NI_over_price = (NI-l.NI)/l.prccq  

gen delta_earnings = earnings-l.earnings
 
gen CF1 = oancfy/l.atq
gen roa = iby/l.atq

* Winsorize so estimations of coefficients are not biased by outliers
winsor2 earnings gross_return bve NI NI_over_price delta_NI_over_price delta_earnings CF1 roa, c(1 99) replace 

* Generate loss and loss-related variables
gen loss = 1*(iby<0) 
gen loss_x_NI = loss*NI_over_price
gen loss_x_delta_NI = loss*delta_NI_over_price 
gen loss_x_earnings = loss*earnings
gen loss_x_delta_earnings = loss*delta_earnings


sort id qdate
xtset id qdate, quarterly

* GDF (2011)
bys id: asreg earnings gross_return, wind(qdate -16 0)   
gen gdf_b_return = _b_gross_return
gen gdf_b_cons = _b_cons
drop _Nobs _R2 _adjR2 _b_gross_return _b_cons

* Barth: Price ~ Book_per_share + NI_per_share (2012)
bys id: asreg prccq bve NI, wind(qdate -16 0)
gen barth_b_bve = _b_bve
gen barth_b_NI = _b_NI
gen barth_b_cons = _b_cons
drop _Nobs _R2 _adjR2 _b_bve _b_NI _b_cons

* Barth1: CF1 ~ roa  (2012)
bys id: asreg CF1 roa, wind(qdate -16 0)
gen barth1_b_roa = _b_roa
gen barth1_b_cons = _b_cons
drop _Nobs _R2 _adjR2 _b_roa _b_cons

* Barth2: gross_return ~  NI_over_price + delta_NI_over_price + loss + loss_x_NI + loss_x_delta_NI (2012)
bys id: asreg gross_return NI_over_price delta_NI_over_price loss loss_x_NI loss_x_delta_NI, wind(qdate -16 0)
gen barth2_b_NI_over_price = _b_NI_over_price
gen barth2_b_delta_NI_over_price = _b_delta_NI_over_price
gen barth2_b_loss = _b_loss
gen barth2_b_loss_x_NI = _b_loss_x_NI
gen barth2_b_loss_x_delta_NI = _b_loss_x_delta_NI
gen barth2_b_cons = _b_cons
drop _Nobs _R2 _adjR2 _b_NI_over_price _b_delta_NI_over_price _b_loss _b_loss_x_NI _b_loss_x_delta_NI _b_cons

* Barth2a: gross_return ~  earnings + delta_earnings + loss + loss_x_earnings + loss_x_delta_earnings (2012)
bys id: asreg gross_return earnings delta_earnings loss loss_x_earnings loss_x_delta_earnings, wind(qdate -16 0)
gen barth2a_b_earnings = _b_earnings
gen barth2a_b_delta_earnings = _b_delta_earnings
gen barth2a_b_loss = _b_loss
gen barth2a_b_loss_x_earnings = _b_loss_x_earnings
gen barth2a_b_loss_x_delta_earnings = _b_loss_x_delta_earnings
gen barth2a_b_cons = _b_cons
drop _Nobs _R2 _adjR2 _b_earnings _b_delta_earnings _b_loss _b_loss_x_earnings _b_loss_x_delta_earnings _b_cons


save "$home\quarterly_focal.dta", replace


****************** Create the data of LOCAL PEERS ****************** ***** NOTE: CHANGE THE CHOICE OF PEER DEFINITION? Start from this line 
global home "D:\A whole new world"
use "$home\quarterly_focal.dta", clear
keep id qdate state naics* sic* gdf_b_* barth_b_* barth1_b_* barth2_b_* barth2a_b_*   
rename * x*
gen qdate = xqdate
gen state = xstate 
gen sic2 = xsic2
save "$home\quarterly_local_peers.dta", replace

****************** Break down the local peer dataset for possibly faster joinby
forvalues i = 1/11{
	use "$home\quarterly_local_peers.dta", clear
	keep if xid >= (`i'-1)*1140+1 + 1 &  xid <= `i'*1140
	save "$home\quarterly_local_peers`i'.dta", replace
} 

****** Match focal dataset with local peers - defined as those in the same fyear, hqstate, and NAICS4 as the focal firms
forvalues i = 1/11{
	use "$home\quarterly_focal.dta", clear
	joinby qdate state sic2 using "$home\quarterly_local_peers`i'.dta",  unmatched(master)
	drop _merge
	save "$home\quarterly_matched_`i'.dta", replace
	display `i'
}



forvalues time = 1/11{
	use "$home\quarterly_matched_`time'.dta", clear
	
	* Drop self-match and duplicates
	drop if id == xid
	drop if missing(qdate)
	drop if missing(id)
	drop if missing(xid)

	****** Create pair-based cohort (e.g., groupby id_xid) => generate the focal firm's expected earnings from its accounting system and the local peer's accounting system  
	egen id_xid = group(id xid)
	sort id_xid qdate
	xtset id_xid qdate, quarterly

	 
	* gdf_b_return gdf_b_cons 
	* barth_b_bve barth_b_NI barth_b_cons 
	* barth1_b_roa barth1_b_cons 
	* barth2_b_NI_over_price barth2_b_delta_NI_over_price barth2_b_loss barth2_b_loss_x_NI barth2_b_loss_x_delta_NI barth2_b_cons 
	* barth2a_b_earnings barth2a_b_delta_earnings barth2a_b_loss barth2a_b_loss_x_earnings barth2a_b_loss_x_delta_earnings barth2a_b_cons

	****** Expected value from year 0 to year -15 (e.g., 16 most frequent quarters of data)  
	forvalues i = 0/15 {
		by id_xid: gen gdf_focal_`i' = gdf_b_cons + gdf_b_return*gross_return[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		by id_xid: gen gdf_peer_`i' = xgdf_b_cons + xgdf_b_return*gross_return[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		
		by id_xid: gen barth_focal_`i' = barth_b_cons + barth_b_NI*NI[_n-`i'] + barth_b_bve*bve[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		by id_xid: gen barth_peer_`i' = xbarth_b_cons + xbarth_b_NI*NI[_n-`i'] + xbarth_b_bve*bve[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		
		by id_xid: gen barth1_focal_`i' = barth1_b_cons + barth1_b_roa*roa[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		by id_xid: gen barth1_peer_`i' = xbarth1_b_cons + xbarth1_b_roa*roa[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		
		by id_xid: gen barth2_focal_`i' = barth2_b_cons + barth2_b_NI_over_price*NI_over_price[_n-`i'] + barth2_b_delta_NI_over_price*delta_NI_over_price[_n-`i'] + barth2_b_loss*loss[_n-`i'] + barth2_b_loss_x_NI*loss_x_NI[_n-`i'] + barth2_b_loss_x_delta_NI*loss_x_delta_NI[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		by id_xid: gen barth2_peer_`i' = xbarth2_b_cons + xbarth2_b_NI_over_price*NI_over_price[_n-`i'] + xbarth2_b_delta_NI_over_price*delta_NI_over_price[_n-`i'] + xbarth2_b_loss*loss[_n-`i'] + xbarth2_b_loss_x_NI*loss_x_NI[_n-`i'] + xbarth2_b_loss_x_delta_NI*loss_x_delta_NI[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
		
		by id_xid: gen barth2a_focal_`i' = barth2a_b_cons + barth2a_b_earnings*earnings[_n-`i'] + barth2a_b_delta_earnings*delta_earnings[_n-`i'] + barth2a_b_loss*loss[_n-`i'] + barth2a_b_loss_x_earnings*loss_x_earnings[_n-`i'] + barth2a_b_loss_x_delta_earnings*loss_x_delta_earnings[_n-`i'] if qdate[_n-`i'] + 15 >= qdate	
		by id_xid: gen barth2a_peer_`i' = xbarth2a_b_cons + xbarth2a_b_earnings*earnings[_n-`i'] + xbarth2a_b_delta_earnings*delta_earnings[_n-`i'] + xbarth2a_b_loss*loss[_n-`i'] + xbarth2a_b_loss_x_earnings*loss_x_earnings[_n-`i'] + xbarth2a_b_loss_x_delta_earnings*loss_x_delta_earnings[_n-`i'] if qdate[_n-`i'] + 15 >= qdate
	}

	forvalues i = 0/15 {
		gen gdf_dis_`i' = abs(gdf_focal_`i' - gdf_peer_`i')
		gen barth_dis_`i' = abs(barth_focal_`i' - barth_peer_`i')
		gen barth1_dis_`i' = abs(barth1_focal_`i' - barth1_peer_`i')
		gen barth2_dis_`i' = abs(barth2_focal_`i' - barth2_peer_`i')
		gen barth2a_dis_`i' = abs(barth2a_focal_`i' - barth2a_peer_`i')
	}


	****** Pairwise comparability
	egen gdfcomp = rowmean(gdf_dis_*)
	replace gdfcomp = -1*gdfcomp
	egen gdfcomp_count = rownonmiss(gdf_dis_*)

	egen barthcomp = rowmean(barth_dis_*)
	replace barthcomp = -1*barthcomp
	egen barthcomp_count = rownonmiss(barth_dis_*)

	egen barth1comp = rowmean(barth1_dis_*)
	replace barth1comp = -1*barth1comp
	egen barth1comp_count = rownonmiss(barth1_dis_*)

	egen barth2comp = rowmean(barth2_dis_*)
	replace barth2comp = -1*barth2comp
	egen barth2comp_count = rownonmiss(barth2_dis_*)

	egen barth2acomp = rowmean(barth2a_dis_*)
	replace barth2acomp = -1*barth2acomp
	egen barth2acomp_count = rownonmiss(barth2a_dis_*)

	*drop if gdfcomp_count == 0 | barth1comp_count == 0 | barth2comp_count == 0 | barth2acomp_count == 0

	
	save "$home\quarterly_matched_and_calculated_`time'.dta", replace
}



******** Compress
forvalues i = 1/11 {
	use "$home\quarterly_matched_and_calculated_`i'.dta", clear
	keep gvkey id fyearq qdate gdfcomp barthcomp barth1comp barth2comp barth2acomp
	compress
	save "$home\quarterly_matched_and_calculated_and_compressed_`i'.dta", replace
	display `i'
}



******* Append all joinby-ed and calculated datasets
use "$home\quarterly_matched_and_calculated_and_compressed_1.dta", clear
forvalues i = 2/11 {
	append using "$home\quarterly_matched_and_calculated_and_compressed_`i'.dta"
}


******* Save my compressed work
save "$home\quarterly_matched_and_calculated_and_compressed.dta", replace


******* Calculate mean of top4 
use "$home\quarterly_matched_and_calculated_and_compressed.dta", clear
* drop some string variables
* export delimited using "D:\A whole new world\Stata sucks\quarterly_matched_and_calculated.csv", replace


foreach ac of varlist gdfcomp barthcomp barth1comp barth2comp barth2acomp {
	sort id qdate `ac' 
	by id qdate: gen `ac'_pos = _n
	by id qdate: egen when_last_nonmissing = max( `ac'_pos / (!missing(`ac')*1))

	gen `ac'_h0  = `ac' if `ac'_pos == when_last_nonmissing
	sort id qdate `ac'_h0
	by id qdate: replace `ac'_h0 = `ac'_h0[1]

	gen `ac'_h1  = `ac' if `ac'_pos == when_last_nonmissing - 1 & when_last_nonmissing >= 1 + 1 
	sort id qdate `ac'_h1
	by id qdate: replace `ac'_h1 = `ac'_h1[1]

	gen `ac'_h2  = `ac' if `ac'_pos == when_last_nonmissing - 2 & when_last_nonmissing >= 1 + 2 
	sort id qdate `ac'_h2
	by id qdate: replace `ac'_h2 = `ac'_h2[1]

	gen `ac'_h3  = `ac' if `ac'_pos == when_last_nonmissing - 3 & when_last_nonmissing >= 1 + 3
	sort id qdate `ac'_h3
	by id qdate: replace `ac'_h3 = `ac'_h3[1]
	
	drop when_last_nonmissing
	di `"`: var label `ac''"' 
}

 
**** Create mean of top four for each firm-year obs
egen gdfcomp_meant4 = rowmean(gdfcomp_h*)
egen barthcomp_meant4 = rowmean(barthcomp_h*)
egen barth1comp_meant4 = rowmean(barth1comp_h*)
egen barth2comp_meant4 = rowmean(barth2comp_h*)
egen barth2acomp_meant4 = rowmean(barth2acomp_h*)

drop gdfcomp_pos gdfcomp_h0 gdfcomp_h1 gdfcomp_h2 gdfcomp_h3 barthcomp_pos barthcomp_h0 barthcomp_h1 barthcomp_h2 barthcomp_h3 barth1comp_pos barth1comp_h0 barth1comp_h1 barth1comp_h2 barth1comp_h3 barth2comp_pos barth2comp_h0 barth2comp_h1 barth2comp_h2 barth2comp_h3 barth2acomp_pos barth2acomp_h0 barth2acomp_h1 barth2acomp_h2 barth2acomp_h3

***** Collapse
sort id qdate
collapse (mean) gdfcomp barthcomp barth1comp barth2comp barth2acomp gdfcomp_meant4 barthcomp_meant4 barth1comp_meant4 barth2comp_meant4 barth2acomp_meant4 (median) med_gdfcomp=gdfcomp med_barthcomp=barthcomp med_barth1comp=barth1comp med_barth2comp=barth2comp med_barth2acomp=barth2acomp, by(id gvkey qdate fyearq)  

sort id qdate
collapse (last) gdfcomp barthcomp barth1comp barth2comp barth2acomp gdfcomp_meant4 barthcomp_meant4 barth1comp_meant4 barth2comp_meant4 barth2acomp_meant4 med_gdfcomp med_barthcomp med_barth1comp med_barth2comp med_barth2acomp (mean) mean_gdfcomp=gdfcomp  mean_barthcomp=barthcomp  mean_barth1comp=barth1comp  mean_barth2comp=barth2comp  mean_barth2acomp=barth2acomp  mean_gdfcomp_meant4=gdfcomp_meant4  mean_barthcomp_meant4=barthcomp_meant4  mean_barth1comp_meant4=barth1comp_meant4  mean_barth2comp_meant4=barth2comp_meant4  mean_barth2acomp_meant4=barth2acomp_meant4  mean_med_gdfcomp=med_gdfcomp  mean_med_barthcomp=med_barthcomp  mean_med_barth1comp=med_barth1comp  mean_med_barth2comp=med_barth2comp  mean_med_barth2acomp=med_barth2acomp   (median) median_gdfcomp=gdfcomp  median_barthcomp=barthcomp  median_barth1comp=barth1comp  median_barth2comp=barth2comp  median_barth2acomp=barth2acomp  median_gdfcomp_meant4=gdfcomp_meant4  median_barthcomp_meant4=barthcomp_meant4  median_barth1comp_meant4=barth1comp_meant4  median_barth2comp_meant4=barth2comp_meant4  median_barth2acomp_meant4=barth2acomp_meant4  median_med_gdfcomp=med_gdfcomp  median_med_barthcomp=med_barthcomp  median_med_barth1comp=med_barth1comp  median_med_barth2comp=med_barth2comp  median_med_barth2acomp=med_barth2acomp  , by(id gvkey fyear)

rename * q*
gen gvkey  = qgvkey
gen fyear = qfyearq

save "$home\quarterly_acctcomp.dta", replace


