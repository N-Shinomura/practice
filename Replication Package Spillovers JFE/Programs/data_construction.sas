************************************;
************************************;
*** 2. Prepare data for analysis ***;
************************************;
************************************;

/* This program takes the raw plant-level (datasets.cmf) and cluster-level
   (datasets.cluster) panels from simulate.sas and constructs the analysis
   datasets needed for each regression table in the paper:
     t2.dta  - firm-level summary statistics           (Table 2)
     t3a.dta - local spillovers, innovative plants     (Table 3, cols 1-4)
     t3b.dta - local spillovers, non-innovative plants (Table 3, col 5)
     t4.dta  - global (across-cluster) spillovers      (Table 4)
     t5a.dta - placebo test                            (Table 5, cols 1-2)
     t5b.dta - non-innovating plants, adjusted cluster (Table 5, col 3)
     t5c.dta - non-innovating plants, global spillover (Table 5, col 4)
     t6.dta  - IV regressions                          (Table 6)
     t7a/b/c - distance-based spillovers at 100/250/500 mi (Table 7)
     S.dta, Omega.dta, R.dta - sufficient-statistics matrices (Tables 9-11)
     Size.dta, Connectedness.dta - cluster characteristics   (Tables 9-11) */

%let path = C:\Users\xg2285\Dropbox\Replication Package Spillovers JFE;

libname datasets "&&path\Datasets\";

*0 auxiliary datasets;

/* -- firmfield: each firm's "main" research field per year --
   Among innovative plants (inv > 0), sum patents by firm x field x year.
   The field with the most patents is flagged as the firm's primary field (ffield).
   This is used later to assign a research field to non-innovative plants. */

data c1; set datasets.cmf; if inv ~= 0; run;
proc sort data=c1; by year firmid field; run;
proc means data=c1 noprint; by year firmid field; var pat; output out=c2 sum=spat; run;
proc sort data=c2; by year firmid descending spat; run;
data c2; set c2; by year firmid; if first.firmid = 1 then main = 1; run;
data c2 (rename=(field=ffield)); set c2; if main = 1; run;
data firmfield (keep=firmid year ffield); set c2; run;

/* -- firmbeafieldyear: total inventors per firm x BEA x field x year --
   Used to subtract a firm's own inventors when computing "leave-out" cluster
   measures (so a plant's own firm doesn't count toward its spillover exposure). */

data c3; set datasets.cmf; if inv ~= 0; run;
proc sort data=c3; by firmid bea field year; run;
proc means data=c3 noprint; var inv; by firmid bea field year; output out=c4 sum=inv_fbfy; run;
data firmbeafieldyear (keep=firmid bea field year inv_fbfy); set c4; run;

*1. local spillovers (Table 3 columns 1-4);

/* Keep only innovative plants, merge with firm-level inventor counts and
   cluster totals. cluster_local = total cluster inventors minus the focal
   firm's own inventors in that cluster (leave-one-out measure). */

data b1; set datasets.cmf; if inv ~= 0; run;
proc sql; create table b2 as select * from b1 as a, firmbeafieldyear as b
	where a.firmid=b.firmid and a.bea=b.bea and a.field=b.field and a.year=b.year; run;
proc sql; create table b3 as select * from b2 as a, datasets.cluster as b
	where a.bea=b.bea and a.field=b.field and a.year=b.year; run;

data b4; set b3; cluster_local = cluster - inv_fbfy; run;

data table3a; set b4; run;

proc export data = table3a
            outfile = "&&path\Datasets\t3a.dta" 
            dbms=Stata replace;
run;

*2. local spillovers (Table 3 column 5, non-innovating plants);

/* Same local-spillover measure but for plants with zero inventors.
   These plants are assigned their firm's primary field (ffield) so they
   can still be linked to a technology cluster. */

data d1; set datasets.cmf; if inv = 0; run;
proc sql; create table d2 as select * from d1 (drop=field) as a, firmfield as b where a.firmid=b.firmid and a.year=b.year; run;
proc sql; create table d3 as select * from d2 as a left join firmbeafieldyear as b
	 on a.firmid=b.firmid and a.bea=b.bea and a.ffield=b.field and a.year=b.year; run;
data d3; set d3; if inv_fbfy = . then inv_fbfy = 0; run;
proc sql; create table d4 as select * from d3 (drop=field) as a left join datasets.cluster as b
	 on a.bea=b.bea and a.ffield=b.field and a.year=b.year; run;

data d4; set d4; cluster_local = cluster - inv_fbfy; run;

data table3b; set d4; run;

proc export data = table3b
            outfile = "&&path\Datasets\t3b.dta" 
            dbms=Stata replace;
run;

*3. global spillovers (Table 4);

data g1; set table3a; run;

proc sort data=g1; by firmid year field bea; run;
proc sort data=g1 nodupkey; by firmid year field bea; run;
proc sort data=g1; by firmid year field; run;
proc means data=g1 noprint; by firmid year field; var bea; output out=g2 n=nbea; run;
data g2; set g2; if nbea > 1; run;
data g2 (keep=firmid year field); set g2; run;

proc sql; create table g3 as select * from table3a as a, g2 as b
	where a.firmid=b.firmid and a.field=b.field and a.year=b.year; run;

data g4; set g3; run;
proc sort data=g4; by firmid field year bea; run;
proc sort data=g4 nodupkey; by firmid field year bea; run;
proc means data=g4 noprint; var cluster_local; by firmid field year; output out=g5 sum=fcluster; run;
data g5 (rename=(_FREQ_=ncl)); set g5; run;
proc sql; create table g6 as select * from g3 as a, g5 as b where
	a.firmid=b.firmid and a.field=b.field and a.year=b.year; run;
data g7; set g6; cluster_global = fcluster - cluster_local; nclusters = ncl - 1; run;

data table4; set g7; run;

proc export data = table4
            outfile = "&&path\Datasets\t4.dta" 
            dbms=Stata replace;
run;

*4. global spillovers (Table 5 columns 1-2, placebo);

data h1; set datasets.cmf; run;
proc sql; create table h2 as select * from h1 as a, firmfield as b where a.firmid=b.firmid and a.year=b.year; run; *firms with at least one inventor;

proc sort data=h2; by firmid year bea; run;
proc means data=h2 noprint; by firmid year bea; var inv; output out=h3 sum=sinv; run;
data h3; set h3; if sinv = 0; run;
data h3 (keep=firmid year bea); set h3; run; *BEAs where firms have no inventors;
proc sql; create table h4 as select * from h3 as a, datasets.cluster as b where a.year=b.year and a.bea=b.bea; run;
proc sort data=h4; by firmid year field; run;
proc means data=h4 noprint; var cluster; by firmid year field; output out=h5 sum=clusterplacebo; run;

proc sql; create table h6 as select * from table3a as a, h5 as b where a.firmid=b.firmid and a.year=b.year and a.field=b.field; run;

data table5a; set h6; run;

proc export data = table5a
            outfile = "&&path\Datasets\t5a.dta" 
            dbms=Stata replace;
run;

*5. global spillovers (Table 5 column 3, non-innovating plants);

data d1; set datasets.cmf; if inv = 0; run;
proc sql; create table d2 as select * from d1 as a, firmfield as b
	where a.firmid=b.firmid and a.year=b.year; run;

data d3; set firmbeafieldyear; run; 
proc sql; create table d4 as select * from d3 as a, datasets.cluster as b
	where a.bea=b.bea and a.field=b.field and a.year=b.year; run;
data d4; set d4; clusteradj = cluster - inv_fbfy; run;

proc sql; create table d5 as select * from d2 as a, d4 as b
	where a.bea~=b.bea and a.ffield=b.field and a.year=b.year and a.firmid=b.firmid; run;
proc sort data=d5; by lbdnum year; run;
proc means data=d5 noprint; by lbdnum year; var clusteradj; output out=d6 sum=sclusteradj; run;

proc sql; create table d7 as select * from d2 as a, d6 as b where
	a.lbdnum=b.lbdnum and a.year=b.year; run;

data table5b; set d7; run;

proc export data = table5b
            outfile = "&&path\Datasets\t5b.dta" 
            dbms=Stata replace;
run;

*6. global spillovers (Table 5 column 4, non-innovating plants);

data d1; set datasets.cmf; if inv = 0; run;
proc sql; create table d2 as select * from d1 as a, firmfield as b
	where a.firmid=b.firmid and a.year=b.year; run;

data d2a (keep=firmid bea year ffield); set d2; run;
proc sort data=d2a; by firmid bea year; run;
proc sort data=d2a nodupkey; by firmid bea year; run;

data d3; set firmbeafieldyear; run; 
proc sql; create table d4 as select * from d3 as a, datasets.cluster as b
	where a.bea=b.bea and a.field=b.field and a.year=b.year; run;
data d4; set d4; clusteradj = cluster - inv_fbfy; run;

proc sql; create table d5 as select * from d2a as a left join d4 as b
	on a.firmid=b.firmid and a.bea=b.bea and a.ffield=b.field and a.year=b.year; run;
data d5 (drop=cluster); set d5; run;
proc sql; create table d6 as select * from d5 as a, datasets.cluster as b
	where a.bea=b.bea and a.ffield=b.field and a.year=b.year; run;
data d6; set d6; if clusteradj = . then clusteradj = cluster; run;
data d6; set d6; clusterff = clusteradj; run;
data d6 (keep=firmid year bea ffield clusterff); set d6; run;

proc sql; create table d7 as select * from d2 as a, d6 as b
	where a.firmid=b.firmid and a.year=b.year and a.bea=b.bea and a.ffield=b.ffield; run;

data d8; set d7; run;
proc sort data=d8; by firmid year bea; run;
proc sort data=d8 nodupkey; by firmid year bea; run;
proc means data=d8 noprint; var clusterff; by firmid year; output out=d9 sum=fclusterff; run;
data d9 (rename=(_FREQ_=fncl)); set d9; run;
proc sql; create table d10 as select * from d7 as a, d9 as b where
	a.firmid=b.firmid and a.year=b.year; run;
data d11; set d10; cluster_nip = fclusterff - clusterff; nclusters_nip = fncl - 1; run;
data d11; set d11; if cluster_nip ~= 0; run;

data table5c; set d11; run;

proc export data = table5c
            outfile = "&&path\Datasets\t5c.dta" 
            dbms=Stata replace;
run;

*7. IV (Table 6);

data g1; set table3a; run;
proc sort data=g1; by firmid year field bea; run;
proc sort data=g1 nodupkey; by firmid year field bea; run;
proc sort data=g1; by firmid year field; run;
proc means data=g1 noprint; by firmid year field; var bea; output out=g2 n=nbea; run;
data g2; set g2; if nbea > 1; run;
data g2 (keep=firmid year field); set g2; run;

proc sql; create table g3 as select * from table3a as a, g2 as b
	where a.firmid=b.firmid and a.field=b.field and a.year=b.year; run;

*Z calculation;

data g4; set g3; run;

data g7 (keep=firmid year bea); set g4; run;
proc sort data=g7 nodupkey; by firmid year bea; run; 
data g7; set g7; focalfirmbea = 1; run;

data g7a (keep=firmid year bea field); set g4; run;
proc sort data=g7a nodupkey; by firmid year bea field; run; 
data g7a (rename=(bea=otherbea)); set g7a; run;

proc sql; create table g8 as select * from g3 as a, g7a as b
	where a.firmid=b.firmid and a.year=b.year and a.field=b.field and a.bea~=b.otherbea; run;

data g8a (rename=(otherbea=otherbea2 bea=bea2 firmid=firmid2 inv=inv2)); set g8; run;
data g8a (keep=year field otherbea2 bea2 firmid2 inv2); set g8a; run;

proc sql; create table g9 as select * from g8 as a, g8a as b
	where a.firmid~=b.firmid2 and a.year=b.year and a.field=b.field and a.otherbea=b.bea2; run;
proc sql; create table g10 as select * from g9 as a left join g7 as b
	on a.firmid=b.firmid and a.year=b.year and a.otherbea2=b.bea; run;
data g10; set g10; if focalfirmbea ~= 1; run;

data g11 (keep=lbdnum year field firmid2 otherbea2); set g10; run;
proc sort data=g11 nodupkey; by lbdnum year field firmid2 otherbea2; run;

data g12; set g3; run;
proc sort data=g12; by year field firmid bea; run;
proc means data=g12 noprint; by year field firmid bea; var inv; output out=g13 sum=zinv; run;
proc sql; create table g14 as select * from g11 as a, g13 as b
	where a.year=b.year and a.field=b.field and a.firmid2=b.firmid and a.otherbea2=b.bea; run;
proc sort data=g14; by lbdnum year; run;
proc means data=g14 noprint; by lbdnum year; var zinv; output out=g15 sum=z; run;

proc sql; create table table6 as select * from table4 as a, g15 as b where a.lbdnum=b.lbdnum and a.year=b.year; run;

proc export data = table6
            outfile = "&&path\Datasets\t6.dta" 
            dbms=Stata replace;
run;

*8. Distance (Table 7);

data j0; set datasets.geo; run;
proc sort data=j0; by bea; run;
proc means data=j0 noprint; by bea; var x y; output out=j1 mean=bea_x bea_y; run;
data j1 (drop=_FREQ_ _TYPE_); set j1; run;

data g1; set table3a; run;
proc sort data=g1; by firmid year field bea; run;
proc sort data=g1 nodupkey; by firmid year field bea; run;
proc sort data=g1; by firmid year field; run;
proc means data=g1 noprint; by firmid year field; var bea; output out=g2 n=nbea; run;
data g2; set g2; if nbea > 1; run;
data g2 (keep=firmid year field); set g2; run;

proc sql; create table g3 as select * from table3a as a, g2 as b
	where a.firmid=b.firmid and a.field=b.field and a.year=b.year; run;

data g4; set g3; run;
proc sort data=g4; by firmid field year bea; run;
proc sort data=g4 nodupkey; by firmid field year bea; run;
data g4 (keep=firmid field year bea cluster_local); set g4; run;
data g4 (rename=(bea=bea_far cluster_local=cluster_far)); set g4; run;
proc sql; create table g5 as select * from g4 as a, j1 as b where a.bea_far = b.bea; run;
data g5 (drop=bea); set g5; run;

proc sql; create table g6 as select * from g3 as a, g5 as b where
	a.firmid=b.firmid and a.field=b.field and a.year=b.year; run;
data g6; set g6; if bea ~= bea_far; run;

data g6; set g6;
	beax_rad = atan(1)/45 * bea_x;
	beay_rad = atan(1)/45 * bea_y;
	x_rad = atan(1)/45 * x;
	y_rad = atan(1)/45 * y;
	label beax_rad = "Longitude in radian (BEA far)";
	label x_rad = "Longitude in radian";
	label beay_rad = "Latitude in radian (BEA far)";
	label y_rad = "Latitude in radian";
run;

data g6; set g6; *compute great-circle distance (GCD);
	gcd = 3949.99 * arcos(sin(y_rad) * sin(beay_rad) + cos(y_rad) * cos(beay_rad) * cos(x_rad - beax_rad)); *r = 3949.99 is the approximate radius of Earth (in miles);
run;

proc sort data=g6; by gcd; run;

*100 miles;

data g7; set g6; if gcd >= 100; run;
proc sort data=g7; by lbdnum year; run;
proc means data=g7 noprint; by lbdnum year; var cluster_far; output out=g8 sum=scluster_far; run;

proc sql; create table g9 as select * from g3 as a, g8 as b
	where a.lbdnum = b.lbdnum and a.year = b.year; run;
data g9; set g9; cluster_global_dist = scluster_far; run;

data table7a; set g9; run;

proc export data = table7a
            outfile = "&&path\Datasets\t7a.dta" 
            dbms=Stata replace;
run;

*250 miles;

data g7; set g6; if gcd >= 250; run;
proc sort data=g7; by lbdnum year; run;
proc means data=g7 noprint; by lbdnum year; var cluster_far; output out=g8 sum=scluster_far; run;

proc sql; create table g9 as select * from g3 as a, g8 as b
	where a.lbdnum = b.lbdnum and a.year = b.year; run;
data g9; set g9; cluster_global_dist = scluster_far; run;

data table7b; set g9; run;

proc export data = table7b
            outfile = "&&path\Datasets\t7b.dta" 
            dbms=Stata replace;
run;

*500 miles;

data g7; set g6; if gcd >= 500; run;
proc sort data=g7; by lbdnum year; run;
proc means data=g7 noprint; by lbdnum year; var cluster_far; output out=g8 sum=scluster_far; run;

proc sql; create table g9 as select * from g3 as a, g8 as b
	where a.lbdnum = b.lbdnum and a.year = b.year; run;
data g9; set g9; cluster_global_dist = scluster_far; run;

data table7c; set g9; run;

proc export data = table7c
            outfile = "&&path\Datasets\t7c.dta" 
            dbms=Stata replace;
run;

*9. Summary Statistics;

*a) plant level;

data v1; set table4; run;
proc means data=v1; var emp tvs inv pat nclusters cluster_global; run;

*b) firm level;

data v2 (keep=firmid year); set table4; run;
proc sort data=v2 nodupkey; by firmid year; run;
proc sql; create table v3 as select * from datasets.cmf as a, v2 as b
	where a.firmid=b.firmid and a.year=b.year; run;

proc sort data=v3; by firmid year; run;
proc means data=v3 noprint; by firmid year; var emp tvs ip; output out=v4 sum=femp ftvs fip; run;
data v4 (rename=(_FREQ_=nplants)); set v4; run;

data v5; set v3; run;
proc sort data=v5 nodupkey; by firmid year bea; run;
proc means data=v5 noprint; by firmid year; output out=v5a n=ncities; run;

data v5; set v3; run;
proc sort data=v5 nodupkey; by firmid year fips; run;
proc means data=v5 noprint; by firmid year; output out=v5b n=ncounties; run;

data v5; set v3; state = int(fips/1000); run;
proc sort data=v5 nodupkey; by firmid year state; run;
proc means data=v5 noprint; by firmid year; output out=v5c n=nstates; run;

data v5; set v3; if inv > 0; run;
proc sort data=v5 nodupkey; by firmid year bea; run;
proc means data=v5 noprint; by firmid year; output out=v5d n=nicities; run;

data v5; set v3; if inv > 0; run;
proc sort data=v5 nodupkey; by firmid year fips; run;
proc means data=v5 noprint; by firmid year; output out=v5e n=nicounties; run;

data v5; set v3; state = int(fips/1000); if inv > 0; run;
proc sort data=v5 nodupkey; by firmid year state; run;
proc means data=v5 noprint; by firmid year; output out=v5f n=nistates; run;

proc sql; create table v6 as select * from v4 as a, v5a as b where a.firmid=b.firmid and a.year=b.year; run;
proc sql; create table v7 as select * from v6 as a, v5b as b where a.firmid=b.firmid and a.year=b.year; run;
proc sql; create table v8 as select * from v7 as a, v5c as b where a.firmid=b.firmid and a.year=b.year; run;
proc sql; create table v9 as select * from v8 as a, v5d as b where a.firmid=b.firmid and a.year=b.year; run;
proc sql; create table v10 as select * from v9 as a, v5e as b where a.firmid=b.firmid and a.year=b.year; run;
proc sql; create table v11 as select * from v10 as a, v5f as b where a.firmid=b.firmid and a.year=b.year; run;

data v12; set v11;
	share_iplants = fip/nplants;
	share_icounties = nicounties/ncounties;
	share_icities = nicities/ncities;
	share_istates = nistates/nstates;
run;

proc means data=v12;
	var femp ftvs nplants ncounties ncities nstates share_iplants share_icounties share_icities share_istates;
run;

data table2; set v12; run;

proc export data = table2
            outfile = "&&path\Datasets\t2.dta" 
            dbms=Stata replace;
run;

***** Sufficient Statistics *****;

data t1 (keep=tvs bea firmid);
    set datasets.cmf;
    if inv ~= 0 and year = 1976;
run;

proc sort data=t1; by firmid bea; run;
proc means data=t1 noprint; by firmid bea; var tvs; output out=t2 sum=tvs_fb; run;
data t2 (drop=_TYPE_ _FREQ_); set t2; run;
proc sort data=t2; by firmid bea; run;

data t0 (keep=bea); set t1; run;
proc sort data=t0 nodupkey; by bea; run;
data t0a (rename=(bea=bea2)); set t0; run;
proc sql; create table t0b as select * from t0 as a, t0a as b; run;

proc sql; create table t0c as select * from t0b as a, t2 as b
	where a.bea=b.bea; run;
proc sql; create table t0d as select * from t0c as a, t2 (rename=(tvs_fb=tvs_fb2)) as b
	where a.bea2=b.bea and a.firmid=b.firmid; run;
proc sort data=t0d; by bea bea2; run;
proc means data=t0d noprint; by bea bea2; var tvs_fb; output out=t0e (drop=_FREQ_ _TYPE_) sum=num_tvs_fb; run;

proc sort data=t2; by bea; run;
proc means data=t2 noprint; by bea; var tvs_fb; output out=t0f (drop=_FREQ_ _TYPE_) sum=denom_tvs_fb; run;

proc sql; create table t0g as select * from t0e as a, t0f as b where a.bea=b.bea; run;
data t0g; set t0g; svalue = num_tvs_fb/denom_tvs_fb; run;

proc sql; create table t0h as select * from t0b as a left join t0g as b
	on a.bea=b.bea and a.bea2=b.bea2; run;
data smat (drop=num_tvs_fb denom_tvs_fb rename=(bea=bea1)); set t0h; if svalue = . then svalue = 0; run;

data omegamat; set smat;
	omega = (0.021/0.076)/3.22;
	if svalue = 0 then omega = 0;
	if bea1 = bea2 then omega = 1;
run;

	/* cross-cluster elasticity from Table 4 (0.021);
	within-cluster elasticity from Table 3 (0.076);
	number of connected clusters from Table 1 (3.22) */

data omegamat (drop=svalue); set omegamat; run;

data r1; set t2; run;
proc sort data=r1; by bea; run;
proc means data=r1 noprint; by bea; var tvs_fb; output out=rmat (drop=_TYPE_ _FREQ_) sum=rtvs; run;

proc transpose data=smat out=s_matrix (drop=_NAME_);
    by bea1;
    id bea2;
    var svalue;
run;

proc transpose data=omegamat out=omega_matrix (drop=_NAME_);
    by bea1;
    id bea2;
    var omega;
run;

data r_matrix; set rmat; run;

data s_matrix1976; set s_matrix; year = 1976; run;
data r_matrix1976; set r_matrix; year = 1976; run;
data omega_matrix1976; set omega_matrix; year = 1976; run;

%macro wedges(yyyy);

data t1 (keep=tvs bea firmid);
    set datasets.cmf;
    if inv ~= 0 and year = &yyyy;
run;

proc sort data=t1; by firmid bea; run;
proc means data=t1 noprint; by firmid bea; var tvs; output out=t2 sum=tvs_fb; run;
data t2 (drop=_TYPE_ _FREQ_); set t2; run;
proc sort data=t2; by firmid bea; run;

data t0 (keep=bea); set t1; run;
proc sort data=t0 nodupkey; by bea; run;
data t0a (rename=(bea=bea2)); set t0; run;
proc sql; create table t0b as select * from t0 as a, t0a as b; run;

proc sql; create table t0c as select * from t0b as a, t2 as b
	where a.bea=b.bea; run;
proc sql; create table t0d as select * from t0c as a, t2 (rename=(tvs_fb=tvs_fb2)) as b
	where a.bea2=b.bea and a.firmid=b.firmid; run;
proc sort data=t0d; by bea bea2; run;
proc means data=t0d noprint; by bea bea2; var tvs_fb; output out=t0e (drop=_FREQ_ _TYPE_) sum=num_tvs_fb; run;

proc sort data=t2; by bea; run;
proc means data=t2 noprint; by bea; var tvs_fb; output out=t0f (drop=_FREQ_ _TYPE_) sum=denom_tvs_fb; run;

proc sql; create table t0g as select * from t0e as a, t0f as b where a.bea=b.bea; run;
data t0g; set t0g; svalue = num_tvs_fb/denom_tvs_fb; run;

proc sql; create table t0h as select * from t0b as a left join t0g as b
	on a.bea=b.bea and a.bea2=b.bea2; run;
data smat (drop=num_tvs_fb denom_tvs_fb rename=(bea=bea1)); set t0h; if svalue = . then svalue = 0; run;

data omegamat; set smat;
	omega = (0.021/0.076)/3.22;
	if svalue = 0 then omega = 0;
	if bea1 = bea2 then omega = 1;
run;

data omegamat (drop=svalue); set omegamat; run;

data r1; set t2; run;
proc sort data=r1; by bea; run;
proc means data=r1 noprint; by bea; var tvs_fb; output out=rmat (drop=_TYPE_ _FREQ_) sum=rtvs; run;

proc transpose data=smat out=s_matrix (drop=_NAME_);
    by bea1;
    id bea2;
    var svalue;
run;

proc transpose data=omegamat out=omega_matrix (drop=_NAME_);
    by bea1;
    id bea2;
    var omega;
run;

data r_matrix; set rmat; run;

data s_matrix&yyyy; set s_matrix; year = &yyyy; run;
data r_matrix&yyyy; set r_matrix; year = &yyyy; run;
data omega_matrix&yyyy; set omega_matrix; year = &yyyy; run;

%mend wedges;

%macro loop;
    %do i = 1976 %to 2018;
      %wedges(&i);
    %end; 
%mend;

%loop;

%macro build1;
    %do i = 1976 %to 2018;
      s_matrix&i
    %end; 
%mend;

%macro build2;
    %do i = 1976 %to 2018;
      r_matrix&i
    %end; 
%mend;

%macro build3;
    %do i = 1976 %to 2018;
      omega_matrix&i
    %end; 
%mend;

data s_matrix; set %build1; run;
data r_matrix; set %build2; run;
data omega_matrix; set %build3; run;

proc export data = s_matrix
            outfile = "&&path\Datasets\S.dta" 
            dbms=Stata replace;
run;

proc export data = r_matrix
            outfile = "&&path\Datasets\R.dta" 
            dbms=Stata replace;
run;

proc export data = omega_matrix
            outfile = "&&path\Datasets\Omega.dta" 
            dbms=Stata replace;
run;

*cluster size;

data m1; set datasets.cmf; if inv ~= 0; run;
proc sort data=m1; by bea year; run;
proc means data=m1 noprint; var inv; by bea year; output out=m2 (drop=_FREQ_ _TYPE_) sum=sinv; run;

proc sort data=m2; by bea year; run;
proc means data=m2 noprint; var sinv; by bea; output out=m3 (drop=_FREQ_ _TYPE_) mean=minv; run;

proc export data = m3
            outfile = "&&path\Datasets\Size.dta" 
            dbms=Stata replace;
run;

*connectedness;

data n1; set table4; run;
data n2 (keep=lbdnum year bea); set table3a; run;

proc sql; create table n3 as select * from n2 as a left join n1 as b on a.lbdnum=b.lbdnum and a.year=b.year; run;
data n3; set n3; if nclusters = . then nclusters = 0; run;

proc sort data=n3; by bea year; run;
proc means data=n3 noprint; by bea year; var nclusters; output out=n4 mean=connectyear; run;

proc sort data=n4; by bea; run;
proc means data=n4 noprint; by bea; var connectyear; output out=n5 mean=connectedness; run;
data n5 (keep=bea connectedness); set n5; run;

proc export data = n5
            outfile = "&&path\Datasets\Connectedness.dta" 
            dbms=Stata replace;
run;

******************************;
