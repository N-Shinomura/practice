************************************;
************************************;
****** 3. Empirical Analysis *******;
************************************;
************************************;

cd "C:\Users\xg2285\Dropbox\Replication Package Spillovers JFE\"

log using Results\output, replace

cd Datasets

*** TABLE 1 ***;

	/* Table 1 has no estimates (text only) */

*** TABLE 2 ***;

*plant-level;

use "t4.dta", clear
sum emp tvs inv pat nclusters cluster_global

*firm-level;

use "t2.dta", clear
sum femp ftvs nplants ncounties ncities nstates share_iplants share_icounties share_icities share_istates

*** TABLE 3 ***;

*Columns (1)-(4);

use "t3a.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(cluster_local)

reghdfe logpatinv lcluster [aweight=emp], absorb(field year lbdnum) cluster(bea year)
reghdfe ltfp lcluster [aweight=emp], absorb(field year lbdnum) cluster(bea year)
reghdfe logpatinv lcluster [aweight=emp], absorb(field#year bea#year field#bea lbdnum) cluster(bea year)
reghdfe ltfp lcluster [aweight=emp], absorb(field#year bea#year field#bea lbdnum) cluster(bea year)

*Column (5);

use "t3b.dta", clear

gen lcluster = log(cluster_local)

reghdfe ltfp lcluster [aweight=emp], absorb(ffield#year bea#year ffield#bea lbdnum) cluster(bea year)

*** TABLE 4 ***;

use "t4.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(cluster_global)

*Columns (1)-(6);

reghdfe logpatinv lcluster [aweight=emp], absorb(field year lbdnum) cluster(bea year)
reghdfe ltfp lcluster [aweight=emp], absorb(field year lbdnum) cluster(bea year)
reghdfe logpatinv lcluster [aweight=emp], absorb(field#year bea#year field#bea lbdnum) cluster(bea year)
reghdfe ltfp lcluster [aweight=emp], absorb(field#year bea#year field#bea lbdnum) cluster(bea year)
reghdfe logpatinv lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)
reghdfe ltfp lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*** TABLE 5 ***;

*Columns (1)-(2);

use "t5a.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(clusterplacebo)

reghdfe logpatinv lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)
reghdfe ltfp lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (3);

use "t5b.dta", clear

gen lcluster = log(sclusteradj)

reghdfe ltfp lcluster [aweight=emp], absorb(ffield#bea#year lbdnum) cluster(bea year)

*Column (4);

use "t5c.dta", clear

gen lcluster = log(cluster_nip)

reghdfe ltfp lcluster [aweight=emp], absorb(ffield#bea#year lbdnum) cluster(bea year)

*** TABLE 6 ***;

*Columns (1)-(3);

use "t6.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(cluster_global)
gen lz = log(z)

reghdfe lcluster lz [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)
ivreghdfe logpatinv (lcluster=lz) [aweight=emp], first absorb(field#bea#year lbdnum) cluster(bea year)
ivreghdfe ltfp (lcluster=lz) [aweight=emp], first absorb(field#bea#year lbdnum) cluster(bea year)

*** TABLE 7 ***;

*Column (1);

use "t7a.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(cluster_global_dist)

reghdfe logpatinv lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (2);

use "t7b.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(cluster_global_dist)

reghdfe logpatinv lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (3);

use "t7c.dta", clear

gen logpatinv = log(pat/inv)
gen lcluster = log(cluster_global_dist)

reghdfe logpatinv lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (4);

use "t7a.dta", clear

gen lcluster = log(cluster_global_dist)

reghdfe ltfp lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (5);

use "t7b.dta", clear

gen lcluster = log(cluster_global_dist)

reghdfe ltfp lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (6);

use "t7c.dta", clear

gen lcluster = log(cluster_global_dist)

reghdfe ltfp lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*** TABLE 8 ***;

*Columns (1)-(4);

use "t4.dta", clear
gen lcluster = log(cluster_global)

reghdfe citshare1 lcluster [aweight=emp], absorb(field year lbdnum) cluster(bea year)
reghdfe citshare1 lcluster [aweight=emp], absorb(field#year bea#year field#bea lbdnum) cluster(bea year)
reghdfe citshare1 lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)
reghdfe citshare2 lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*Column (5);

use "t5a.dta", clear
gen lcluster = log(clusterplacebo)

reghdfe citshare3 lcluster [aweight=emp], absorb(field#bea#year lbdnum) cluster(bea year)

*** Sufficient Statistics ***;

*Wedges (179 BEAs);

use "S.dta", clear
keep if year == 1976
mkmat _1-_179, mat(S)

use "Omega.dta", clear
keep if year == 1976
mkmat _1-_179, mat(Omega)

use "R.dta", clear
keep if year == 1976
mkmat rtvs, mat(R)

mat id = I(179)

mat omegaS = I(179)
forvalues i = 1/179 {
	forvalues j = 1/179 {
		mat omegaS[`i',`j'] = Omega[`i',`j']*S[`i',`j']
	}
}

mat beta = R' * omegaS

mat gamma = beta * inv(id - (0.076*omegaS))
	
	/* within-cluster elasticity from Table 3 (0.076) */

mat gammabeta = J(1,179,0)
forvalues i = 1/179 {
		 matrix gammabeta[1,`i']= gamma[1,`i']/beta[1,`i']
}

mat gb = gammabeta'

mat beta1976 = beta'
mat gamma1976 = gamma'

*algorithm;

forvalues yyyy = 1976/2018 {

use "S.dta", clear
keep if year == `yyyy'
mkmat _1-_179, mat(S)

use "Omega.dta", clear
keep if year == `yyyy'
mkmat _1-_179, mat(Omega)

use "R.dta", clear
keep if year == `yyyy'
mkmat rtvs, mat(R)

mat id = I(179)

mat omegaS = I(179)
forvalues i = 1/179 {
	forvalues j = 1/179 {
		mat omegaS[`i',`j'] = Omega[`i',`j']*S[`i',`j']
	}
}

mat beta = R' * omegaS

mat gamma = beta * inv(id - (0.076*omegaS))

mat gammabeta = J(1,179,0)
forvalues i = 1/179 {
		 matrix gammabeta[1,`i']= gamma[1,`i']/beta[1,`i']
}

mat gb = gammabeta'

mat beta`yyyy' = beta'
mat gamma`yyyy' = gamma'

}

mat betaall = beta1976, beta1977, beta1978, beta1979, beta1980, beta1981, beta1982, beta1983, beta1984, beta1985, beta1986, beta1987, beta1988, beta1989, beta1990, beta1991, beta1992, beta1993, beta1994, beta1995, beta1996, beta1997, beta1998, beta1999, beta2000, beta2001, beta2002, beta2003, beta2004, beta2005, beta2006, beta2007, beta2008, beta2009, beta2010, beta2011, beta2012, beta2013, beta2014, beta2015, beta2016, beta2017, beta2018
mat gammaall = gamma1976, gamma1977, gamma1978, gamma1979, gamma1980, gamma1981, gamma1982, gamma1983, gamma1984, gamma1985, gamma1986, gamma1987, gamma1988, gamma1989, gamma1990, gamma1991, gamma1992, gamma1993, gamma1994, gamma1995, gamma1996, gamma1997, gamma1998, gamma1999, gamma2000, gamma2001, gamma2002, gamma2003, gamma2004, gamma2005, gamma2006, gamma2007, gamma2008, gamma2009, gamma2010, gamma2011, gamma2012, gamma2013, gamma2014, gamma2015, gamma2016, gamma2017, gamma2018

mat betaallm = betaall * J(colsof(betaall),1,1) / colsof(betaall)
mat gammaallm = gammaall * J(colsof(gammaall),1,1) / colsof(gammaall)

mat gammabetam = J(179,1,0)
forvalues i = 1/179 {
		 matrix gammabetam[`i',1]= gammaallm[`i',1]/betaallm[`i',1]
}

keep bea
svmat gammabetam
rename gammabetam gamma_beta

tostring bea, generate(bea_char)
gen bea_id = "BEA ID " + bea_char

merge 1:1 bea using "Connectedness.dta"

*** TABLE 9 ***;

egen gamma_beta_min = min(gamma_beta)
gen gamma_beta_norm = gamma_beta/gamma_beta_min

*Columns (1)-(2);
 
sum gamma_beta_norm, detail

sort connectedness
pctile pct_c = connectedness, nq(10) genp(percent_c)
xtile decile_connect = connectedness, cutpoints(pct_c)

*Columns (3)-(4);
 
by decile_connect, sort: sum gamma_beta_norm
corr gamma_beta_norm connectedness

*** TABLE 10 ***;

*Left-hand panel;

gsort -gamma_beta
list bea_id in 1/10 /* top 10 */

gsort -gamma_beta
list bea_id in 170/179 /* bottom 10 */

save "wedges.dta", replace

use "Size.dta", clear

tostring bea, generate(bea_char)
gen bea_id = "BEA ID " + bea_char

*Right-hand panel;

gsort -minv
list bea_id in 1/10 /* top 10 (size) */

gsort -minv
list bea_id in 170/179 /* bottom 10 (size) */

*** Counterfactual ***;

use "S.dta", clear
keep if year == 1976
mkmat _1-_179, mat(S)

mat S = S*1.1
forvalues i = 1/179 {
	mat S[`i',`i'] = 1
}

*algorithm;

forvalues yyyy = 1976/2018 {

use "S.dta", clear
keep if year == `yyyy'
mkmat _1-_179, mat(S)

mat S = S*1.1
forvalues i = 1/179 {
	mat S[`i',`i'] = 1
}

use "Omega.dta", clear
keep if year == `yyyy'
mkmat _1-_179, mat(Omega)

use "R.dta", clear
keep if year == `yyyy'
mkmat rtvs, mat(R)

mat id = I(179)

mat omegaS = I(179)
forvalues i = 1/179 {
	forvalues j = 1/179 {
		mat omegaS[`i',`j'] = Omega[`i',`j']*S[`i',`j']
	}
}

mat beta = R' * omegaS

mat gamma = beta * inv(id - (0.076*omegaS))

mat gammabeta = J(1,179,0)
forvalues i = 1/179 {
		 matrix gammabeta[1,`i']= gamma[1,`i']/beta[1,`i']
}

mat gb = gammabeta'

mat beta`yyyy' = beta'
mat gamma`yyyy' = gamma'

}

mat betaall = beta1976, beta1977, beta1978, beta1979, beta1980, beta1981, beta1982, beta1983, beta1984, beta1985, beta1986, beta1987, beta1988, beta1989, beta1990, beta1991, beta1992, beta1993, beta1994, beta1995, beta1996, beta1997, beta1998, beta1999, beta2000, beta2001, beta2002, beta2003, beta2004, beta2005, beta2006, beta2007, beta2008, beta2009, beta2010, beta2011, beta2012, beta2013, beta2014, beta2015, beta2016, beta2017, beta2018
mat gammaall = gamma1976, gamma1977, gamma1978, gamma1979, gamma1980, gamma1981, gamma1982, gamma1983, gamma1984, gamma1985, gamma1986, gamma1987, gamma1988, gamma1989, gamma1990, gamma1991, gamma1992, gamma1993, gamma1994, gamma1995, gamma1996, gamma1997, gamma1998, gamma1999, gamma2000, gamma2001, gamma2002, gamma2003, gamma2004, gamma2005, gamma2006, gamma2007, gamma2008, gamma2009, gamma2010, gamma2011, gamma2012, gamma2013, gamma2014, gamma2015, gamma2016, gamma2017, gamma2018

mat betaallm = betaall * J(colsof(betaall),1,1) / colsof(betaall)

mat gammaallm = gammaall * J(colsof(gammaall),1,1) / colsof(gammaall)

mat gammabetam = J(179,1,0)
forvalues i = 1/179 {
		 matrix gammabetam[`i',1]= gammaallm[`i',1]/betaallm[`i',1]
}

keep bea
svmat gammabetam
rename gammabetam gamma_beta_counter

merge 1:1 bea using "wedges.dta", generate(_merge2)

gen d_gamma_beta = (gamma_beta_counter - gamma_beta)/gamma_beta

*** TABLE 11 ***;

*Left-hand panel;

gsort -d_gamma_beta
list bea_id d_gamma_beta in 1/10 /* top 10 */

gsort -d_gamma_beta
list bea_id d_gamma_beta in 170/179 /* bottom 10 */

use "Size.dta", clear

tostring bea, generate(bea_char)
gen bea_id = "BEA ID " + bea_char

*Right-hand panel;

gsort -minv
list bea_id in 1/10 /* top 10 (size) */

gsort -minv
list bea_id in 170/179 /* bottom 10 (size) */

log close

*******************;
