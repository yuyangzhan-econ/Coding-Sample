*************************************************************************** 
* NAME:Master Dofile
* Date: 2025/7/10
* CREATED by ZHAN Yuyang
 
*************************************************************************** 

*****************
/*PRELIMINARIES*/
*****************
* Machine-specific root directories

else if "`c(username)'" == "" {
		global dir "F:/research/data task"  
}
	else global dir "XXXXX" //Please enter your path.

* Change ado directory
sysdir set PLUS "$dir/ado/plus"
sysdir set PERSONAL "$dir/ado/personal"


********************
/*Run all programs*/
********************
* Data preparation
do "$dir/code/stata_dofile/0_Data_Preparation.do"

* Tables
do "$dir/code/stata_dofile/1_Tables.do"

* Figures
do "$dir/code/stata_dofile/2_Figures.do"