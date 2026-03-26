*************************************;
*************************************;
*** 1. Generate synthetic dataset ***;
*************************************;
*************************************;

%let path = C:\Users\xg2285\Dropbox\Replication Package Spillovers JFE;

libname datasets "&&path\Datasets\";

*a. Plant-level data;

data geo_sas (keep=state county statename countynm zip x y fips);
	set sashelp.zipcode;	/* Import SAS geocodes */
	if state >= 1 and state <= 56;	/* Keep 50 U.S. states and D.C. */
	if zip ~= . and x ~= . and y ~= .; /* ZIP codes, longitude (centroid), and latitudes (centroid) */
	fips = state*1000+county;
run;

proc import out= WORK.bea 
            datafile= "&&path\Datasets\Crosswalk_BEA_FIPS.csv" 
            dbms=CSV REPLACE;
     		getnames=YES;
     		datarow=2; 
     		guessingrows=10000; 
RUN;

proc sort data=bea nodupkey; by Alpha_Census_FIPS_Code; run; /* no duplicates */
data bea (keep=Alpha_Census_FIPS_Code BEA_2004_EA__Code); set bea; run;

proc sql; create table geo as select * from geo_sas as a, bea as b where a.fips = b.Alpha_Census_FIPS_Code; run;
data geo (drop=Alpha_Census_FIPS_Code rename=(BEA_2004_EA__Code=bea)); set geo; run;

data geo1 (keep=state statename); set geo; run;
proc sort data=geo1 nodupkey; by state; run;	/* 50 U.S. states and D.C. */

proc sort data=geo nodupkey; by zip state county; run;	/* no duplicates */
data geo; set geo; zipid = _N_; run;
data datasets.geo; set geo; run;

data a1; /* Simulate data from Census CMF/ASM/LBD */
	call streaminit(123);       	/* set random number seed */
		do lbdnum = 1 to 50000;							/* plant identifiers */
			firmid = 1 + int(5000*rand("Uniform"));     	/* firm identifiers */
			sic = 2000 + int(1999*rand("Uniform"));	 		/* SIC 2000-3999 (manufacturing) */
			zipid = 1 + int(41019*rand("Uniform"));		 	/* 41,019 ZIP codes */
			field = 1 + int(9*rand("Uniform"));				/* 9 research fields */
			ip = (rand("Uniform")<0.2);						/* Innovative plants (IP) */ 
			do year = 1976 to 2018;							/* time range 1976-2018 */
   				emp = 1 + int(10000*rand("Uniform"));   	/* U(0,1), EMP = # employees */
   				pay = 1 + int(100000*rand("Uniform"));		/* U(0,1), PAY = payroll */
   				tvs = 1 + int(100000*rand("Uniform"));		/* U(0,1), TVS = total value of shipments */
				ltfp = rand("Normal");						/* N(0,1), LTPF = total factor productivity */	
				inv = (ip = 1)*(1 + int(20*rand("Uniform")));	/* U(0,1), INV = # inventors */
				pat = (ip = 1)*(1 + int(100*rand("Uniform")));	/* U(0,1), PAT = # patents */
				citshare1 = (ip = 1)*rand("Uniform");			/* U(0,1), CITSHARE = citation share */
				citshare2 = (ip = 1)*rand("Uniform");			/* U(0,1), CITSHARE = citation share */
				citshare3 = (ip = 1)*rand("Uniform");			/* U(0,1), CITSHARE = citation share */
			output;
		end;
	end;
run;

proc sql; create table a2 as select * from a1 as a,
	geo as b where a.zipid = b.zipid; run;
data a2 (drop=zipid); set a2; run;

data datasets.cmf; set a2; run;

*b. Cluster-level data;

data a5; set datasets.cmf; run;
proc sort data=a5; by bea year field; run;
proc means data=a5 noprint; by bea year field; var inv;
	output out=a6 sum=ninv; run;

data a7; 							/* Simulate data for clusters */
	call streaminit(456);       	/* set random number seed */
		do bea = 1 to 179;			/* 179 BEA codes */
			do field = 1 to 9;		/* 9 research fields */
				do year = 1976 to 2018;							/* time range 1976-2018 */
   					cinv = (1 + int(1000*rand("Uniform")));		/* U(0,1), # inventors  */
					output;
				end;
			end;
		end;
run;

proc sql; create table a8 as select * from a7 as a left join a6 as b on a.year=b.year and a.bea = b.bea and a.field=b.field; run;

data a8; set a8; cluster = ninv + cinv; run;
data a8 (keep=cluster bea year field); set a8; run;

data datasets.cluster; set a8; run;

***************************;
***************************;
