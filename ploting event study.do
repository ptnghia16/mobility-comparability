*** Minus1
use "D:\A whole new world\Plot\minus1.dta", clear


gen hi95 = estimates + 1.95996*se
gen lo95 = estimates - 1.95996*se
gen hi90 = estimates + 1.64485*se
gen lo90 = estimates - 1.64485*se

twoway (rcap lo95 hi95 row, vertical) (scatter estimates row if estimator =="Stacked DiD", mcolor(red)) (scatter estimates row if estimator =="PSM Stacked DiD", mcolor(blue)), legend(row(1) order(2 "Stacked DiD" 3 "PSM Stacked DiD") pos(6)) xlabel(1.5 "-5" 4.5 "-4" 7.5 "-3" 10.5 "-2" 13.5 "-1" 16.5 "0" 19.5 "1" 22.5 "2" 25.5 "3" 28.5 "4" 31.5 "5", angle(0) noticks) title("Accounting Comparability") xtitle("Years to treatment") ytitle("Coefficient estimates and 95% CI") yline(0, lpattern(dash) lcolor(gs8)) xsize(8) ysize(5)




*** 0
use "D:\A whole new world\Plot\zero.dta", clear


gen hi95 = estimates + 1.95996*se
gen lo95 = estimates - 1.95996*se
gen hi90 = estimates + 1.64485*se
gen lo90 = estimates - 1.64485*se

twoway (rcap lo95 hi95 row, vertical) (scatter estimates row if estimator =="Stacked DiD", mcolor(red)) (scatter estimates row if estimator =="PSM Stacked DiD", mcolor(blue)), legend(row(1) order(2 "Stacked DiD" 3 "PSM Stacked DiD") pos(6)) xlabel(1.5 "-5" 4.5 "-4" 7.5 "-3" 10.5 "-2" 13.5 "-1" 16.5 "0" 19.5 "1" 22.5 "2" 25.5 "3" 28.5 "4" 31.5 "5", angle(0) noticks) title("Accounting Comparability") xtitle("Years to treatment") ytitle("Coefficient estimates and 95% CI") yline(0, lpattern(dash) lcolor(gs8)) xsize(8) ysize(5)

