cd "D:\A whole new world\dos"

						* Master file
						* -----------

* Compute financial statement comparability with local peer 
* input: Compustat quarterly 
* output: Annual financial statement (FS) comparability with local peers for each firm
run Q_acctcomp.do


* Create the cleaned panel dataset
* input: Compustat annually 
* output: Cleaned annually panel, merged with FS comparability data
run Annual_panel_processing.do


* Stacked DiD regressions: Baseline and robustnesss
* output: Cleaned annually panel
* output: Table 2, most of Table 3, and Figure 2
run Stacked_DID.do


* (PSM) Stacked DiD regressions on propensity score matched sample
* output: Cleaned annually panel
* output: The rest of table 3, and Figure 2
run PSM_Stacked_DiD.do


* (Plot) Event study plot
* output: Raw regressions result for 
* output: Figure 2
run ploting_event_study.do


* (Firm pair) Stacked DiD regressions on firm-pair data
* output: Cleaned annually panel, firm-pair level
* output: Table 4
run Pairlevel_Stacked DiD.do


* (Cross-sectional) Stacked DiD regressions: cross-sectional effect
* output: Cleaned annually panel
* output: Table 5
run Cross_sectional_effect.do


* (Real) Stacked DiD regressions: real consequences
* output: Cleaned annually panel
* output: Real_consequences.do
run Real_consequences.do


