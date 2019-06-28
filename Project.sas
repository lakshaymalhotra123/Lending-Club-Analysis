/* Data Set Cleaning SAS Code */
Proc contents data=Sasdata.Loans_Accepted; run;


proc freq data=Sasdata.Loans_Accepted;
   tables loan_status / out=Sasdata.FreqCount outexpect;
   title 'Loan Status';
run;


data Sasdata.Loans_Accepted_Less_Current; set Sasdata.Loans_Accepted;
                if loan_status ^= 'Current' & loan_status ^= 'Does not me';
run;

/* Dropping unncessary Variables */
data Sasdata.Loans_Accepted_Less_NAVAR; set Sasdata.Loans_Accepted_Less_Current;
                drop desc emp_title member_id policy_code title url next_pymnt_d revol_bal_joint sec_app_fico_range_low sec_app_fico_range_high sec_app_earliest_cr_line sec_app_inq_last_6mths sec_app_mort_acc sec_app_open_acc sec_app_revol_util sec_app_open_act_il sec_app_num_rev_accts sec_app_chargeoff_within_12_mths sec_app_collections_12_mths_ex_m sec_app_mths_since_last_major_de sub_grade issue_d zip_code fico_range_low initial_list_status last_pymnt_amnt last_credit_pull_d last_fico_range_low
         next_pymnt_d
open_acc_6m
open_acc_24m
bc_open_to_buy  
mo_sin_old_rev_tl_op
mo_sin_rcnt_rev_tl_op
mo_sin_rcnt_tl
mths_since_recent_bc_dlq
mths_since_recent_inq
mths_since_recent_revol_delinq
next_pymnt_d
mths_since_recent_revol_delinq
mths_since_last_delinq
tot_coll_amt
acc_open_past_24mths
avg_cur_bal
bc_util
mo_sin_old_il_acct
mort_acc
mths_since_recent_bc
num_actv_bc_tl
num_actv_rev_tl
total_bal_ex_mort
total_il_high_credit_limit
num_bc_sats
num_bc_tl
num_il_tl
num_op_rev_tl
num_rev_accts
num_rev_tl_bal_gt_0
num_sats
num_tl_90g_dpd_24m
pct_tl_nvr_dlq
percent_bc_gt_75
tot_hi_cred_lim
total_bc_limit
total_cu_tl
hardship_type
hardship_reason
hardship_status
deferral_term
hardship_amount
hardship_start_date
hardship_end_date
payment_plan_start_date
hardship_length
hardship_dpd
hardship_loan_status
orig_projected_additional_accrue
hardship_payoff_balance_amount
hardship_last_payment_amount
debt_settlement_flag_date
settlement_status
settlement_date
settlement_amount
settlement_percentage
settlement_term
mths_since_last_record
mths_since_last_major_derog
tot_cur_bal
total_rev_hi_lim
verification_status_joint
dti_joint
annual_inc_joint
open_act_il
open_il_24m
mths_since_rcnt_il
total_bal_il
il_util
open_rv_24m
max_bal_bc
all_util
inq_fi
emp_length
issue_d
purpose
addr_state
earliest_cr_line
last_pymnt_d
;

run;

proc means data=Sasdata.Loans_Accepted_Less_NAVAR NMISS N;
run;

PROC SQL;
	select distinct debt_settle_flag from Sasdata.Loans_Accepted_Less_NAVAR;
run;

/*  Removing null values and Converting Categorical variable into 0 and 1 */
data Sasdata.Loans_Accepted_Less_NAVAR;
	set Sasdata.Loans_Accepted_Less_NAVAR;
	if nmiss(of _numeric_) + cmiss(of _character_) > 0 then delete;

	if loan_status='Fully Paid' then risk = 0;
	if loan_status='In Grace Pe' then risk =0;
	if loan_status='Late (16-30' then risk =1;
	if loan_status='Late (31-12' then risk =1;
	if loan_status='Charged Off' then risk =1;
	if loan_status='Default' then risk =1;
	drop loan_status;


		if term = '36 months' then loan_term = 30;
	if term = '60 months' then loan_term = 60;
	drop term;

	if grade ='A' then cust_grade = 0;
	if grade ='B' then cust_grade = 1;
	if grade ='C' then cust_grade = 2;
	if grade ='D' then cust_grade = 3;
	if grade ='E' then cust_grade = 4;
	if grade ='F' then cust_grade = 5;
	if grade ='G' then cust_grade = 6;
	drop grade;

	if home_ownership = 'NONE' 	then h_ownership = 0;
	if home_ownership = 'MORTGAGE' 	then h_ownership = 1;
	if home_ownership = 'ANY' 	then h_ownership = 2;
	if home_ownership = 'OTHER' 	then h_ownership = 3; 
	if home_ownership = 'OWN' 	then h_ownership = 4;
	if home_ownership = 'RENT' 	then h_ownership = 5;
	drop home_ownership;


	if verification_status = 'Not Verified' 	then verif_status = 0;
	if verification_status = 'Source Verified' 	then verif_status = 1;
	if verification_status = 'Verified' 		then verif_status = 2;
	drop verification_status;

	if pymnt_plan = 'n' then payment_plan = 0;
	if pymnt_plan = 'y' then payment_plan = 1;
	drop pymnt_plan;

	if application_type = 'Individual' then applicat_type = 0;
	if application_type = 'Joint App'  then applicat_type = 1;
	drop application_type;

	if hardship_flag = 'N' then hardship_fl = 0;
	if hardship_flag = 'Y' then hardship_fl = 1;
	drop hardship_flag;

	if disbursement_method = 'Cash' then disburse_method = 0;
	if disbursement_method = 'Dire' then disburse_method = 1;
	drop disbursement_method;

	if debt_settlement_flag = 'N' then debt_settle_flag = 0;
	if debt_settlement_flag = 'Y' then debt_settle_flag = 1;
	drop debt_settlement_flag;

run; 

proc means data=Sasdata.Loans_Accepted_Less_NAVAR NMISS N;
run;

/* To find out duplicate values */
proc sql;
   title 'Lending club data analysis';
   select *, count(*) as Count
      from Sasdata.Loans_Accepted_Less_NAVAR
      group by id
      having count(*) > 1;
	run;

/*what numeric varables impact loan status */
proc means data=Sasdata.Loans_Accepted_Less_NAVAR;
class risk;
var installment funded_amnt  funded_amnt_inv loan_amnt annual_inc dti revol_util delinq_2yrs inq_last_6mths pub_rec int_rate;
run;

ods graphics on;
/* Frequency distribution by Loan Purpose, Term and Loan status */
proc freq data=Sasdata.Loans_Accepted_Less_NAVAR order=freq;
     tables loan_term cust_grade risk  ;      
run;

/* Frequency distribution Loan status by Purpose */
proc freq data=Sasdata.Loans_Accepted_Less_NAVAR order=freq;
     tables  cust_grade*risk  /nocol nofreq nopercent;
    /* suppresses row %, frequency values and cumulative % */ 
run;

/* To find corelation between related numeric variable */
proc corr data= Sasdata.Loans_Accepted_Less_NAVAR;
var funded_amnt  funded_amnt_inv loan_amnt;
run;



ods graphics off;

ods graphics on;
/* To find corelation between related numeric value */
proc corr data= Sasdata.Loans_Accepted_Less_NAVAR;
var revol_util delinq_2yrs inq_last_6mths pub_rec ;
run;
ods graphics off;

/* Frequency distribution Loan status by grade */
proc freq data=Sasdata.Loans_Accepted_Less_NAVAR order=freq;
      tables cust_grade* risk /norow nofreq nopercent;
    /* suppresses row %, frequency values and cumulative % */ 
run;

/* does grade term home_ownership emp_length affect status*/
proc freq data= Sasdata.Loans_Accepted_Less_NAVAR;
table cust_grade*risk / nocol nofreq nocum nopercent chisq;
table loan_term*risk / nocol nofreq nocum nopercent chisq;
table h_ownership*risk/nocol nofreq nocum nopercent chisq;
run;

proc SGSCATTER DAta=Sasdata.Loans_Accepted_Less_NAVAR;
	MATRIX annual_inc dti int_rate delinq_2yrs 
		/ 
		DIAGONAL=(HISTOGRAM  )
		START=TOPLEFT
		ELLIPSE=(ALPHA=0.05 TYPE=PREDICTED)
		NOLEGEND;
RUN;

ods graphics off;
/* Plot a bar chart of grades */
proc gchart data=Sasdata.Loans_Accepted_Less_NAVAR;
	vbar cust_grade /discrete percent;
run;
/* Plot a bar chart of loan status */
proc gchart data=Sasdata.Loans_Accepted_Less_NAVAR;
title 'Frequency of Risk ';
	vbar risk /discrete percent;
run;
ods graphics on;

/* Splitting the Dataset */


proc contents data=Sasdata.Loans_Accepted_Training varnum;
run;


proc sql;
select risk,avg(loan_amnt) from Sasdata.Loans_Accepted_Training group by risk;
run;

proc ttest DATA= Sasdata.Loans_Accepted_Less_NAVAR;
var loan_amnt;
by risk;
run;

PROC SQL;
	select distinct risk from Sasdata.Loan_3;
run;
/*-------------------------------------------------Spliting the Data -----------------------------------------------------------*/
proc surveyselect data=Sasdata.Loans_Accepted_Less_NAVAR out=Sasdata.Loans_Accepted_Sampled outall samprate=0.7 seed=2;
run;

data Sasdata.Loans_Accepted_Training Sasdata.Loans_Accepted_Test;
set Sasdata.Loans_Accepted_Sampled;
if selected then output Sasdata.Loans_Accepted_Training;
else output Sasdata.Loans_Accepted_Test;
run;

/*---------------------------------------------------Logistic Model --------------------------------------------------------------------*/

/*ASE in train vs. test data */
/* Forward selection with significant level of coefficients as criteria */

/*ASE in train vs. test data */

proc logistic data=Sasdata.Loans_Accepted_Training plots=all;
logit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /nofit; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

proc logistic data=Sasdata.Loans_Accepted_Training plots=all;
probit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /link=NORMIT; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

/* Decision Tree */ 
proc hpsplit data=Sasdata.Loans_Accepted_Training vmethod=random(5) intervalbins=10 mincatsize=15
minleafsize=35 plots=all cvmodelfit;
	class loan_term cust_grade h_ownership verif_status  payment_plan  applicat_type hardship_fl  disburse_method debt_settle_flag risk;
 	model risk = loan_amnt loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl debt_settle_flag disburse_method funded_amnt_inv int_rate 
		     installment annual_inc annual_inc dti delinq_2yrs fico_range_high fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp 
		     out_prncp_inv total_pymnt total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		     collections_12_mths_ex_med  acc_now_delinq pub_rec_bankruptcies tax_liens;	
	grow entropy;
	prune costcomplexity;
	code file = 'H:\Predictive Analytics using SAS\lbwtTree.sas';
run;

 

/* Implementing Random Forest */

PROC HPFOREST DATA= Sasdata.Loans_Accepted_Training;
	TARGET risk /LEVEL=nominal;
	INPUT loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl disburse_method 
		  debt_settle_flag /LEVEL=nominal;
	INPUT loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /LEVEL=interval;
	ods output FitStatistics=fitstats(rename=(Ntrees=Trees));
RUN;
data fitstats;
   set fitstats;
   label Trees = 'Number of Trees';
   label MiscAll = 'Full Data';
   label Miscoob = 'OOB';
run;

proc sgplot data=fitstats;
   title "OOB vs Training";
   series x=Trees y=MiscAll;
   series x=Trees y=MiscOob/lineattrs=(pattern=shortdash thickness=2);
   yaxis label='Misclassification Rate';
run;
title;

/* ----------------------------------------------------- Clustering ----------------------------------------------------------------------- */

data Sasdata.Loan_1;
set Sasdata.Proj_loans;
if cluster =0;
if risk = 1 then risk =1;
if risk = 2 then risk =1;
run;
data Sasdata.Loan_2;
set Sasdata.Proj_loans;
if cluster =1;
if risk = 1 then risk =1;
if risk = 2 then risk =1;
run;
data Sasdata.Loan_3;
set Sasdata.Proj_loans;
if cluster =2;
if risk = 1 then risk =1;
if risk = 2 then risk =1;
run;


PROC SQL;
	select distinct risk from Sasdata.Loan_1_risk_Training;
run;
/*--------------------------------------------------------- Cluster 1 --------------------------------------------------------------------*/   
 
proc surveyselect data=Sasdata.Loan_1 out=Sasdata.Loan_1_Sampled outall samprate=0.7 seed=2;
run;

data Sasdata.Loan_1_Training Sasdata.Loan_1_Test;
set Sasdata.Loan_1_Sampled;
if selected then output Sasdata.Loan_1_Training;
else output Sasdata.Loan_1_Test;
run;

/*Logistic Model */

/*ASE in train vs. test data */
/* Forward selection with significant level of coefficients as criteria */


/*ASE in train vs. test data */
/* Score selection with log-likelihood ratio test */
proc logistic data=Sasdata.Loan_1_Training plots=all;
logit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /nofit; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

proc logistic data=Sasdata.Loan_1_Training plots=all;
probit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /link=NORMIT; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;


/* Implementing Decsion Tree*/

proc hpsplit data=Sasdata.Loan_1_Training vmethod=random(5) intervalbins=10 mincatsize=15
minleafsize=35 plots=all cvmodelfit;
	class loan_term cust_grade h_ownership verif_status  payment_plan  applicat_type hardship_fl  disburse_method debt_settle_flag risk;
 	model risk = loan_amnt loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl debt_settle_flag disburse_method funded_amnt_inv int_rate 
		     installment annual_inc annual_inc dti delinq_2yrs fico_range_high fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp 
		     out_prncp_inv total_pymnt total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		     collections_12_mths_ex_med  acc_now_delinq pub_rec_bankruptcies tax_liens;	
	grow entropy;
	prune costcomplexity;
	code file = 'H:\Predictive Analytics using SAS\lbwtTree.sas';
run;


/* Implementing Random Forest */

PROC HPFOREST DATA= Sasdata.Loan_1_Training;
	TARGET risk /LEVEL=nominal;
	INPUT loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl disburse_method 
		  debt_settle_flag /LEVEL=nominal;
	INPUT loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /LEVEL=interval;
	ods output FitStatistics=fitstats(rename=(Ntrees=Trees));
RUN;
data fitstats;
   set fitstats;
   label Trees = 'Number of Trees';
   label MiscAll = 'Full Data';
   label Miscoob = 'OOB';
run;

proc sgplot data=fitstats;
   title "OOB vs Training";
   series x=Trees y=MiscAll;
   series x=Trees y=MiscOob/lineattrs=(pattern=shortdash thickness=2);
   yaxis label='Misclassification Rate';
run;
title;


/*--------------------------------------------------------- Cluster 2 --------------------------------------------------------------------*/ 

proc surveyselect data=Sasdata.Loan_2 out=Sasdata.Loan_2_Sampled outall samprate=0.7 seed=2;
run;

data Sasdata.Loan_2_Training Sasdata.Loan_2_Test;
set Sasdata.Loan_2_Sampled;
if selected then output Sasdata.Loan_2_Training;
else output Sasdata.Loan_2_Test;
run;
/*Logistic Model */

/*ASE in train vs. test data */
/* Forward selection with significant level of coefficients as criteria */

proc logistic data=Sasdata.Loan_2_Training  plots=all;
 class loan_term(ref='0') cust_grade(ref='0') h_ownership(ref='0') verif_status(ref='0') payment_plan(ref='0') applicat_type(ref='0') hardship_fl(ref='0')
		disburse_method(ref='0')debt_settle_flag(ref='0') risk(ref='0');
model risk(ref='0')= loan_amnt|funded_amnt_inv|int_rate|installment|annual_inc|annual_inc|dti|delinq_2yrs|fico_range_high|
		fico_range_high|inq_last_6mths|open_acc|pub_rec|revol_bal|revol_util|total_acc|out_prncp|out_prncp_inv|total_pymnt|
		total_pymnt_inv|total_rec_prncp|total_rec_int|total_rec_late_fee|recoveries|collection_recovery_fee|last_fico_range_high|
		collections_12_mths_ex_med|acc_now_delinq|pub_rec_bankruptcies|tax_liens @2
   /selection=forward slentry=0.35 slstay=0.3 best= 1 details ; 
   ROC 'Logistic Model ROC Curve' pred=linear_predictions;
run;

proc logistic data=Sasdata.Loan_2_Training plots=all;
logit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /nofit; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

proc logistic data=Sasdata.Loan_2_Training plots=all;
probit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /link=NORMIT; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

proc hpsplit data=Sasdata.Loan_2_Training vmethod=random(5) intervalbins=10 mincatsize=15
minleafsize=35 plots=all cvmodelfit;
	class loan_term cust_grade h_ownership verif_status  payment_plan  applicat_type hardship_fl  disburse_method debt_settle_flag risk;
 	model risk = loan_amnt loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl debt_settle_flag disburse_method funded_amnt_inv int_rate 
		     installment annual_inc annual_inc dti delinq_2yrs fico_range_high fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp 
		     out_prncp_inv total_pymnt total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		     collections_12_mths_ex_med  acc_now_delinq pub_rec_bankruptcies tax_liens;	
	grow entropy;
	prune costcomplexity;
	code file = 'H:\Predictive Analytics using SAS\lbwtTree.sas';
run;



PROC HPFOREST DATA= Sasdata.Loan_2_Training;
	TARGET risk /LEVEL=nominal;
	INPUT loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl disburse_method 
		  debt_settle_flag /LEVEL=nominal;
	INPUT loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /LEVEL=interval;
	ods output FitStatistics=fitstats(rename=(Ntrees=Trees));
RUN;
data fitstats;
   set fitstats;
   label Trees = 'Number of Trees';
   label MiscAll = 'Full Data';
   label Miscoob = 'OOB';
run;

proc sgplot data=fitstats;
   title "OOB vs Training";
   series x=Trees y=MiscAll;
   series x=Trees y=MiscOob/lineattrs=(pattern=shortdash thickness=2);
   yaxis label='Misclassification Rate';
run;
title;

/*--------------------------------------------------------- Cluster 3 --------------------------------------------------------------------*/

proc surveyselect data=Sasdata.Loan_3 out=Sasdata.Loan_3_Sampled outall samprate=0.7 seed=2;
run;

data Sasdata.Loan_3_Training Sasdata.Loan_3_Test;
set Sasdata.Loan_3_Sampled;
if selected then output Sasdata.Loan_3_Training;
else output Sasdata.Loan_3_Test;
run;

/*Logistic Model */

proc logistic data=Sasdata.Loan_3_Training plots=all;
logit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /nofit; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

proc logistic data=Sasdata.Loan_3_Training plots=all;
probit:model risk(event='1')= loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /link=NORMIT; 
  ROC 'Logistic Model ROC Curve' loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens ;
run;

proc hpsplit data=Sasdata.Loan_3_Training vmethod=random(5) intervalbins=10 mincatsize=15
minleafsize=35 plots=all cvmodelfit;
	class loan_term cust_grade h_ownership verif_status  payment_plan  applicat_type hardship_fl  disburse_method debt_settle_flag risk;
 	model risk = loan_amnt loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl debt_settle_flag disburse_method funded_amnt_inv int_rate 
		     installment annual_inc annual_inc dti delinq_2yrs fico_range_high fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp 
		     out_prncp_inv total_pymnt total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		     collections_12_mths_ex_med  acc_now_delinq pub_rec_bankruptcies tax_liens;	
	grow entropy;
	prune costcomplexity;
	code file = 'H:\Predictive Analytics using SAS\lbwtTree.sas';
run;

PROC HPFOREST DATA= Sasdata.Loan_3_Training;
	TARGET risk /LEVEL=nominal;
	INPUT loan_term cust_grade h_ownership verif_status payment_plan applicat_type hardship_fl disburse_method 
		  debt_settle_flag /LEVEL=nominal;
	INPUT loan_amnt funded_amnt_inv int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc pub_rec revol_bal revol_util total_acc out_prncp out_prncp_inv total_pymnt 
		total_pymnt_inv total_rec_prncp total_rec_int total_rec_late_fee recoveries collection_recovery_fee last_fico_range_high 
		collections_12_mths_ex_med acc_now_delinq pub_rec_bankruptcies tax_liens /LEVEL=interval;
	ods output FitStatistics=fitstats(rename=(Ntrees=Trees));
RUN;
data fitstats;
   set fitstats;
   label Trees = 'Number of Trees';
   label MiscAll = 'Full Data';
   label Miscoob = 'OOB';
run;

proc sgplot data=fitstats;
   title "OOB vs Training";
   series x=Trees y=MiscAll;
   series x=Trees y=MiscOob/lineattrs=(pattern=shortdash thickness=2);
   yaxis label='Misclassification Rate';
run;
title;

/*------------------------------------------------------- End ---------------------------------------------------------------------*/
