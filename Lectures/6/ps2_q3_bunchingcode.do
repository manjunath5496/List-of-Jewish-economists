clear
cd "/Users/DaanStruyven/Desktop/Dropbox/2. MIT/1. Teaching/14.471/PS/PS2"

// 14.471 Fall 2012: Proposed Solutions to PS 2-Q3 about bunching


use taxreturns.dta //This is the dta version of the data file Jim visualized in the Table of the PSquestion


* Generate the powers of agi and kink dummies

gen agisq=agi*agi
gen agicube=agi*agi*agi
gen ti=agi-8.95

gen kink1=0
replace kink1=1 if agi==7.5

gen kink2=0
replace kink2=1 if agi==17.5

gen kink3=0
replace kink3=1 if agi==42.5

gen kink4=0
replace kink4=1 if agi==87.5


//I. Quadratic


* Regress number of return on quadratic of AGI midpoint 
reg nbrret agi agisq 

* Visualize residuals
rvfplot, title ("# Returns predicted with 1st and 2nd powers of AGI")
graph export quadraticres.eps,replace


* Compute residual from regression
predict res,r

* Predict number of returns with regression 
predict nbrrethat

*actual values, and residual values, both plotted against agi

scatter nbrret nbrrethat agi, title("# Returns Actual vs. predicted with 1st/2nd powers of AGI") xtitle("Adjusted Gross Income") ytitle("# Returns") 
graph export Plotquadrat.eps,replace



// II. Cubic: 


* Regress number of return on quadratic of AGI midpoint 
reg nbrret agi agisq agicube

* Visualize residuals
rvfplot

* Compute residual from regression
predict rescub,r

* Predict number of returns with regression 
predict nbrrethatcub

*actual values, and residual values, both plotted against agi

scatter nbrret nbrrethatcub agi, title("# Returns Actual & predicted with 3 powers of AGI") xtitle("Adjusted Gross Income") ytitle("# Returns") 
graph export Plotcub.eps,replace


// III. Testing for excess bunching

* Quadratic
reg nbrret agi agisq kink1 kink2 kink3 kink4
estimates store quad

* Cubic 
reg nbrret agi agisq agicube kink1 kink2 kink3 kink4
estimates store cub
quietly esttab quad cub using bunch.tex, replace b(%10.4f) se star(* 0.10 ** 0.05 *** 0.01)


save excessmassv3.dta,replace

