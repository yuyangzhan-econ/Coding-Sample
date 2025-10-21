/******************************************************************************************* 
* NAME:0_Data_Preparation.do
* Date: 2025/7/10
* CREATED by ZHAN Yuyang
* NOTES:
  This document takes the raw data files `simulated_experiment_for_RAtask.csv` and `simulated_CBdata_for_RAtask.csv`, converts them to `.dta` format, and performs basic preprocessing. It then generates `simulated_experiment_dta.dta` and `simulated_CB_data.dta`.     
  Finally, it creates the required outcome variables and saves them in:
- Firm-level outcomes → `$dir/data/firm_level_outcomes.dta`
- Firm-to-firm-level outcomes → `$dir/data/firm_to_firm_level_outcomes.dta`

Points to Note:
  1. For both the firm-level and firm-to-firm-level data construction, I first use the experiment data to build a balanced panel and then fill in the actual transaction numbers. The reason I do not directly use the `collapse` command on the bank transaction data to obtain results is because this would lead to sample selection bias.
  2. I prefer to treat suppliers and buyers separately. Instead of merging a firm's data as a supplier and as a buyer based on the same `firm_id`, I use the `append` command to treat them as two separate datasets. The advantage of this approach is that it simplifies the coding for subsequent regression analysis. Moreover, from an economic perspective, I believe that suppliers are located upstream in the value chain and buyers downstream, so treating these two roles separately is more appropriate.

Directory：
- PRELIMINARIES
- 1. Load and process simulated experiment data
- 2. Load and process Central Bank transaction data
- 3. Create firm-level outcomes
- 4. Create firm-to-firm-level outcomes
*******************************************************************************************/


*****************
/*PRELIMINARIES*/
*****************
clear all
set maxvar 15000
set matsize 10000

*If you want to run this dofile separately, rather than through master.do, fill in your path here.
*    global dir "XXXXX"


*set seed
set seed 123456789


*************************************************
/*1. Load and process simulated experiment data*/
*************************************************
import delimited "$dir/data/simulated_experiment_for_RAtask.csv", clear

* encode string
label define treatlbl 0 "Control" 1 "Treatment"
encode treatment, gen(treat) label(treatlbl)
encode strata, gen(strata_id)
drop strata treatment
save "$dir/data/simulated_experiment_dta.dta", replace


*****************************************************
/*2. Load and process Central Bank transaction data*/
*****************************************************
import delimited "$dir/data/simulated_CBdata_for_RAtask.csv", clear

* Create date variables
gen date = ym(year, month)
format date %tm

* Define treatment timing (April 2024)
gen fair_date = ym(2024, 4)
gen post = (date >= fair_date)

* Create relative time to fair
gen months_to_fair = date - fair_date

* Define analysis sample: 6 months pre to 12 months post
keep if months_to_fair >= -6 & months_to_fair <= 12

save "$dir/data/simulated_CB_data.dta", replace


*********************************
/*3. Create firm-level outcomes*/
*********************************
use "$dir/data/simulated_CB_data.dta", clear

* Firm-level sales 
preserve
	gen n_prod = value/price
	egen n_buyer = nvals(buyer), by(seller months_to_fair)

collapse (sum) outcome_value=value ///Total sales and purchases
         (count) n_transactions=value ///
         (mean) n_partners=n_buyer ///Number of buyers
         (sum) n_products=n_prod, ///Number of products sold
         by(seller months_to_fair)

rename seller firm_id
gen type = "supplier"

tempfile sales
save `sales'
restore

* Firm-level purchases  
	gen n_prod = value/price
	egen n_seller = nvals(seller), by(buyer months_to_fair)

collapse (sum) outcome_value=value ///Total sales and purchases
         (count) n_transactions=value ///
         (mean) n_partners=n_seller ///Number of suppliers
         (sum) n_products=n_prod, ///Number of products purchased
         by(buyer months_to_fair)

rename buyer firm_id
gen type = "buyer"

* Combine sales and purchases
append using `sales'

* Calculate new partners (Number of new buyers and suppliers)
sort firm_id type months_to_fair
bys firm_id type: gen new_partners = n_partners - n_partners[_n-1] if _n > 1
replace new_partners = 0 if new_partners == .

tempfile transaction
save `transaction'

* Create time skeleton for balanced panel
use "$dir/data/simulated_experiment_dta.dta", clear
expand 19  // 19 months total (6 before + 1 treatment + 12 after)
bysort firm_id: gen months_to_fair = _n - 7
expand 2  // supplier/buyers
bysort firm_id months_to_fair: gen type_int = _n
gen type = "supplier" if type_int == 1
replace type = "buyer" if type_int == 2
drop type_int

* Merge with actual transaction data
merge 1:1 firm_id months_to_fair type using `transaction', keep(1 3) nogen

foreach v in outcome_value n_transactions n_partners n_products new_partners{
	replace `v' = 0 if missing(`v')
}

gen post = (months_to_fair >= 0)

save "$dir/data/firm_level_outcomes.dta", replace


*****************************************
/*4. Create firm-to-firm-level outcomes*/
*****************************************
* Create all possible firm pairs (418 × 417 excluding diagonal)
use "$dir/data/simulated_experiment_dta.dta", clear
preserve
keep firm_id
gen buyer = firm_id
tempfile firms
save `firms'
restore
cross using `firms'
rename firm_id seller
drop if seller == buyer  // Remove diagonal pairs

* Create time skeleton for all pairs
expand 19  // 19 months total (6 before + 1 treatment + 12 after)
bysort seller buyer: gen months_to_fair = _n - 7

* Calculate real firm-to-firm-level outcomes
preserve
use "$dir/data/simulated_CB_data.dta", clear
gen n_prod = value/price
* Collapse to pair-month level
collapse (count) n_transactions = value ///
         (sum) n_products=n_prod, ///
         by(buyer seller months_to_fair)
		 
tempfile transaction
save `transaction'
restore

* Merge with actual transaction data
merge 1:1 seller buyer months_to_fair using `transaction', keep(1 3) 

* Create firm-to-firm outcomes
gen has_sale = (_merge == 3)  //Whether there is a sale (or purchase)
drop _merge
replace n_transactions = 0 if missing(n_transactions)
replace n_products = 0 if missing(n_products)
gen pair = string(seller) + "_" + string(buyer)
egen long pair_id = group(seller buyer)
gen post = (months_to_fair >= 0)

save "$dir/data/firm_to_firm_level_outcomes.dta", replace


display "Data preparation complete."