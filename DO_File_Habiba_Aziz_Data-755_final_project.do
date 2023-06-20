*Habiba Aziz
*Data-755
*Final Project

set logtype text, perm

*pointing to my directory
cd  "c:\users\habiba aziz\desktop\data-755"
use NHIS_rev_11-2-2020_EJ, clear

svyset psu,[pweight=sampweight] strata(strata) singleunit(scaled) 
keep if astatflg==1 | astatflg==6
*sex
tab sex

*year
tab year

*sexorien Sexual orientation
tab sexorien
tabulate year sexorien , missing

*droping the years in which sexorien data is missing
drop if year < 2012

*missing values of sex orientation
tabulate sexorien, missing
tabulate sexorien, missing nolabel
*RECODE as MISSING the NIU, Refused, Not Ascertained responses
recode sexorien (0=.) (7/8=.)

*CHECK resulting sexual orientation frequency distribution
tabulate sexorien, missing

 *ANALYSIS #1: Variation in Orientations by Gender (sex)
tab sexorien sex, col chi
by sex, sort : tabulate sexorien sex, cchi2 chi2 column

*region 
tab region

*age
tab age

*AgeC
generate AgeC=age
label var AgeC "Collapsed Age"
recode AgeC (18/35=18)(36/50=36) ///
      (51/69=51) (70/85=70)
label define AgeC_Lbl 18"18-35" 35"36-50" ///
      36"36-50" 51"51-69" 70"70+" 
label values AgeC AgeC_Lbl
tab AgeC

*smokestatus2  Cigarette smoking recode 2: Currentdetailed/former/never
tab smokestatus2 

*missing values 
tabulate smokestatus2  , missing
tabulate smokestatus2  , missing nolabel
*RECODE as MISSING the NIU, Refused, Not Ascertained responses
recode smokestatus2 (40/90=.)
*ANALYSIS #2: Variation in smokestatus2 by region 
tabulate smokestatus2, missing

* Frequency drank alcohol in past year: Days per week

tab alcdayswk
tab alcdayswk, nolabel
recode alcdayswk (0=0.5)(80=0)(10=1)(20=2)(30=3)(40=4)(50=5)(60=6)(70=7)(96/99=.), generate (alcdayswk2)
tab alcdayswk2

label var alcdayswk2"Drinking Status"
recode alcdayswk2(0=1)(0.5=2) ///
      (1/2=3) (3/4=4) (5/6 = 5)(7=6)
label define alcdayswk2_Lbl 1"No Drinks" 2"less than a day" ///
      3"Between 1 to 2 days" 4"Between 3 to 4 days" 5"Between 5 to 6 days" 6"All seven days"
label values alcdayswk2 alcdayswk2_Lbl
*tab AgeC
tab alcdayswk2 

*deprx ( Take medication for |depression)
tab deprx
tabulate deprx , missing
tabulate deprx , missing nolabel
*RECODE as MISSING the NIU, Refused, Not Ascertained responses
recode deprx (0=.) (7/9=.)
tabulate deprx, missing
svy : tabulate alcdayswk2  deprx , row 

tab deprx, nolabel
tab deprx, nolabel
gen deprx_new = deprx
recode deprx_new (1=0) (2=1) 
tab deprx deprx_new




*depfeelevl - Level of depression, last time depressed 
tab depfeelevl, nolabel
*missing values of depfeelevl
tabulate depfeelevl , missing
tabulate depfeelevl , missing nolabel
*RECODE as MISSING the NIU, Refused, Not Ascertained responses
recode depfeelevl (0=.) (7/9=.)
*CHECK resulting depression frequency distribution
tabulate depfeelevl, missing
generate depression_level=depfeelevl

tab depression_level
label var depression_level "Depression level"
label define depression_level_Lbl 1"A little depressed" 3"Somewhere b/w A litte and A lot" ///
      2"A lot depressed" 
label values depression_level depression_level_Lbl
tab   depression_level

*label define order  1 "A little depressed" 3 "Somewehere b/w A litte and A lot" 2 "A lot depressed" 
*encode depression_level, generate(depression_level2) label(order)

*cross-tab depression level over alcohol status 
svy : tabulate   depression_level alcdayswk2 

*cross-tab region level over alcohol status 
svy : tabulate  region alcdayswk2  , row 

*cross-tab region level over smoke status 
svy : tabulate  region smokestatus2  , row 

*female variable  generate 
gen female=sex
recode female (1=0)(2=1)
tab sex female
*pause
tab racenew ,nolabel
recode racenew (61/99=.)
tab racenew

*creating new sexorien  variable 
tab sexorien, nolabel
gen sexorien_new = sexorien

label var sexorien_new"Sexorien new"
recode sexorien_new  (4/5=7)
label define sexorien_new_Lbl  2"Straight" 1"Gay/Lesbian" ///
      3"Bisexual" 7"Other"  
label values sexorien_new sexorien_new_Lbl
tab sexorien_new


*graph predicted probablity 
graph box alcdayswk2, over(sexorien_new) ///
title("Predicted probability of depression level  by  sexual orientation across drinking status") ///
blabel(bar, format(%4.1f)) ///
intensity(25)

*predicted propbablity graphs 
graph hbar (mean) depression_level, over(sexorien_new) by(alcdayswk2) ///
blabel(bar, format(%4.1f)) ///
intensity(25)
*predicted propbablity graphs 
graph hbar (mean) depression_level, over(sexorien_new) by(smokestatus2)  ///
blabel(bar, format(%4.1f)) ///
intensity(25)

*deprx
graph bar, over(deprx) ///
ytitle("Percent of Respondents") ///
title("Medication for depression") ///
blabel(bar, format(%4.1f)) ///
intensity(25)

*depression level
graph hbar, over(depression_level) ///
ytitle("Percent of Respondents") ///
title("Depression Level") ///
blabel(bar, format(%4.1f)) ///
intensity(25)

** ordered Logistic Regression 

sort depression_level
svy: ologit  depression_level i.alcdayswk2  i.smokestatus2    i.sexorien_new i.AgeC i.racenew i.region, or 

*Average Adjusted Predictions & Marginal Effects

margins alcdayswk2
margins smokestatus2
margins sexorien_new


*logit regression 

svy: logit  deprx_new i.sexorien_new##female i.alcdayswk2 i.smokestatus2 i.AgeC i.racenew i.region, or

*post estimation 
testparm i.sexorien_new##female
margins sexorien_new#female
marginsplot



