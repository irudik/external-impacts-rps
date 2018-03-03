////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// HOLLINGSWORTH AND RUDIK (hollinal@indiana.edu, irudik@cornell.edu)
// EXTERNAL IMPACTS OF LOCAL ENERGY POLICY: THE CASE OF RENEWABLE PORTFOLIO STANDARDS
// JOURNAL OF THE ASSOCIATION OF ENVIRONMENTAL AND RESOURCE ECONOMISTS
// VERSION: JANUARY 2018

// DESCRIPTION:
// THIS FILE RUNS THE SCRIPTS TO REPLICATE OUR TABLES AND FIGURES IN THE PAPER
// AND THE ONLINE APPENDIX, EXCEPT FOR FIGURES 2, 5, AND A2

// INSTRUCTIONS:
// RUN THIS FILE TO REPLICATE ALL RESULTS AFTER BUILDING THE MAIN DATASET (OR 
// USING THE PRE-COMPILED ONE THAT IS PROVIDED)
// YOU MUST SELECT THE FOLLOWING USING OPTIONS
// - root_path: the location of the repository for the replication files
// - install_stata_packages: = 1 if you wish to install all the necessary packages
// 							 = 0 if you already have them
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


clear all


////////////////////////////////////
////////////////////////////////////
// USER OPTIONS 
////////////////////////////////////
////////////////////////////////////

// Root folder directory that contains the subfolders for constructing the dataset and estimation
global root_path "/Users/ir229/Desktop/git/external-impacts-rps" 
// Install Stata Packages
global install_stata_packages 0 // Set to 1 if you need to install or update packages


////////////////////////////////////
////////////////////////////////////
// SET UP PACKAGES, PLOTS, PATHS
////////////////////////////////////
////////////////////////////////////

// Install packages if needed
if $install_stata_packages {
	ssc install ivreg2, replace all
	ssc install reghdfe, replace all
	ssc install ranktest, replace all
	ssc install carryforward, replace all
	ssc install estout, replace all
	ssc install rsource, replace all
	ssc install spmap, replace all
	ssc install shp2dta, replace all
	ssc install tuples, replace all
	ssc install blindschemes, replace all
	ssc install tuples, replace all
	set scheme plotplainblind
}
else  {
	di "All packages up to date."
	set scheme plotplainblind

}
// Change font
graph set window fontface "Helvetica"

// Set paths
global script_path "$root_path/code" // Path for running the scripts to create tables and figures
global results_path "$root_path/output" // Path for tables/figures output
global data_path "$root_path/data" // Path for data

////////////////////////////////////
////////////////////////////////////
// BUILD TABLES/FIGURES
////////////////////////////////////
////////////////////////////////////

do "$script_path/table_1.do" // Main results: Table 1

do "$script_path/table_2.do" // Remove non-parallel pre-trend states: Table 2 and Figure A1

do "$script_path/figure_3.do" // Quantity supplied vs quantity demanded for RECs: Figure 3

do "$script_path/figure_6.do" // Avoided damage per REC vs RECs required to meet 
							// 1% higher RPS, or avoided damage per 1% RPS vs
							// percent of benefits accruing out-of-state: 
							// Figures 6 and A14

do "$script_path/table_a8.do" // Non-RPS states: Table A8

do "$script_path/table_a9.do" // Placebo test: Table A9

do "$script_path/table_a10.do" // Instrument: Table A10

do "$script_path/table_a11.do" // Region-by-year FEs: Table A11

do "$script_path/table_a12.do" // CO2 emissions test: Table A12

do "$script_path/table_a13.do" // Heterogeneous plant responses: Table A13 and Figures A7-A11

do "$script_path/summary_stats_full_tables.do" // Create summary statistics table and full specification tables: Tables A1-A7


