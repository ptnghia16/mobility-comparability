# Bachelor Thesis: How does restricting labor mobility affect financial statement comparability? An examination of U.S. covenants not-to-compete.
This repository stores the scripts underlying the results in my bachelor thesis at VinUni.

### Compute financial statement comparability with local peer 
* File name: Q_acctcomp.do
* input: Compustat quarterly 
* output: Annual financial statement (FS) comparability with local peers for each firm

### Create the cleaned panel dataset
* File name: Annual_panel_processing.do
* input: Compustat annually 
* output: Cleaned annually panel, merged with FS comparability data

### Run stacked DiD regressions for baseline results and robustnesss tests
* File name: Stacked_DID.do
* input: Cleaned annually panel
* output: Table 2, most of Table 3, and Figure 2

### Run stacked DiD regressions on the propensity score matched sample
* File name: PSM_Stacked_DiD.do
* input: Cleaned annually panel
* output: The rest of table 3, and Figure 2

### Creat the event study plot
* Filename: ploting_event_study.do
* input: Raw regressions result for 
* output: Figure 2

### Run stacked DiD regressions on firm-pair data
* Filename: Pairlevel_Stacked DiD.do
* input: Cleaned annually panel, firm-pair level
* output: Table 4

### Run stacked DiD regressions for cross-sectional effect
* Filename: Cross_sectional_effect.do
* input: Cleaned annually panel
* output: Table 5

### Run stacked DiD regressions for results on the real consequences lower FS comparability
* Filename: Real_consequences.do
* input: Cleaned annually panel
* output: Table 6

### Master do file
* Filename: Master.do

