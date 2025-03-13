# Bachelor Thesis: How does restricting labor mobility affect financial statement comparability? An examination of U.S. covenants not-to-compete.
This repository stores the scripts underlying the results in my bachelor thesis at VinUni.

### Compute financial statement comparability with local peer 
* input: Compustat quarterly 
* output: Annual financial statement (FS) comparability with local peers for each firm
Q_acctcomp.do


### Create the cleaned panel dataset
* input: Compustat annually 
* output: Cleaned annually panel, merged with FS comparability data
Annual_panel_processing.do


### Stacked DiD regressions: Baseline and robustnesss
* input: Cleaned annually panel
* output: Table 2, most of Table 3, and Figure 2
Stacked_DID.do


### (PSM) Stacked DiD regressions on propensity score matched sample
* input: Cleaned annually panel
* output: The rest of table 3, and Figure 2
PSM_Stacked_DiD.do


### (Plot) Event study plot
* input: Raw regressions result for 
* output: Plot 2
ploting_event_study.do


### (Firm pair) Stacked DiD regressions on firm-pair data
* input: Cleaned annually panel, firm-pair level
* output: Table 4
Pairlevel_Stacked DiD.do


### (Cross-sectional) Stacked DiD regressions: cross-sectional effect
* input: Cleaned annually panel
* output: Table 5
Cross_sectional_effect.do


### (Real) Stacked DiD regressions: real consequences
* input: Cleaned annually panel
* output: Real_consequences.do
Real_consequences.do


### Master do file
Master.do

