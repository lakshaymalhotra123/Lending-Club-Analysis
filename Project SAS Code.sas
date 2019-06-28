/* Data Set Cleaning SAS Code */
Proc contents data=LoansAccepted; run;

proc means data=LoansAccepted NMISS N;
run;


proc freq data=LoansAccepted;
   tables loan_status / out=Sasdata.FreqCount outexpect;
   title 'Loan Status';
run;

Proc freq data=LoansAccepted;
tables loan_status / out=FreqCount outexpect;
title 'Loan Status';
run;

Proc freq data=LoansAccepted;
tables desc / out=FreqCount outexpect;
title 'Loan Description';
run;

Proc freq data=LoansAccepted;
tables earliest_cr_line / out=FreqCount outexpect;
title 'Earliest Credit Line';
run;


Proc freq data=LoansAccepted;
tables emp_length / out=FreqCount outexpect;
title 'Employment Length';
run;


data Loans_Accepted_Less_Current; set LoansAccepted;
                if loan_status ^= 'Current' & loan_status ^= 'Does not me';
run;

data Loans_Accepted_Less_NAVAR; set Loans_Accepted_Less_Current;
drop addr_state
collection_recovery_fee
desc
emp_title
funded_amnt_inv
grade
il_util
initial_list_status
inq_last_12m
issue_d
last_credit_pull_d
last_fico_range_high
last_fico_range_low
last_pymnt_amnt
last_pymnt_d
member_id
mo_sin_old_rev_tl_op
mo_sin_rcnt_rev_tl_op
mo_sin_rcnt_tl
mths_since_recent_inq
mths_since_recent_revol_delinq
next_pymnt_d
num_actv_bc_tl
num_bc_sats
num_bc_tl
num_il_tl
num_op_rev_tl
num_rev_accts
num_rev_tl_bal_gt_0
num_sats
num_tl_120dpd_2m
num_tl_30dpd
num_tl_90g_dpd_24m
num_tl_op_past_12m
open_acc_6m
open_il_12m
open_il_24m
open_act_il
open_rv_12m
open_rv_24m
out_prncp
out_prncp_inv
policy_code
pub_rec
pymnt_plan
revol_bal
revol_util
sub_grade
title
tot_cur_bal
tot_hi_cred_lim
total_acc
total_bal_ex_mort
total_bal_il
total_bc_limit
total_cu_tl
total_il_high_credit_limit
total_pymnt
total_pymnt_inv
total_rec_int
total_rec_late_fee
total_rec_prncp
total_rev_hi_lim
url
revol_bal_joint 
sec_app_fico_range_high 
sec_app_earliest_cr_line 
sec_app_open_acc 
sec_app_open_act_il
sec_app_num_rev_accts 
sec_app_chargeoff_within_12_mths 
sec_app_collections_12_mths_ex_m 
hardship_payoff_balance_amount
hardship_last_payment_amount
debt_settlement_flag_date
settlement_status
settlement_date
settlement_amount
settlement_percentage
settlement_term
;

run;

/* Data removed due to missing huge number of observations */
data Loans_Accepted_Less_NAVAR; set Loans_Accepted_Less_NAVAR;
drop
mths_since_last_delinq
mths_since_last_record
mths_since_last_major_derog
mths_since_recent_bc_dlq
;
run;

proc means data=Loans_Accepted_Less_NAVAR NMISS N;
run;

data Loans_Accepted_Less_NAVAR_No_Mis; set Loans_Accepted_Less_NAVAR;
if tot_coll_amt =. then delete;
if acc_open_past_24mths =. then delete;
if avg_cur_bal =. then delete;
if bc_open_to_buy =. then delete;
if bc_util =. then delete;
if mo_sin_old_il_acct =. then delete;
if mort_acc =. then delete;
if mths_since_recent_bc =. then delete;
if num_accts_ever_120_pd =. then delete;
if num_actv_rev_tl =. then delete;
if pct_tl_nvr_dlq =. then delete;
if percent_bc_gt_75 =. then delete;
if dti =. then delete;

run;

proc means data=Loans_Accepted_Less_NAVAR_No_Mis NMISS N;
run;

/*  Removing null values and Converting Categorical variable into 0 and 1 */
data Loans_Accepted_Less_NAVAR_Corrct;
	set Loans_Accepted_Less_NAVAR_No_Mis;

	if loan_status='Fully Paid' then risk = 0;
	if loan_status='In Grace Pe' then risk =0;
	if loan_status='Late (16-30' then risk =1;
	if loan_status='Late (31-12' then risk =1;
	if loan_status='Charged Off' then risk =2;
	if loan_status='Default' then risk =2;
	drop loan_status;


    if term = '36 months' then loan_term = 30;
	if term = '60 months' then loan_term = 60;
	drop term;

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

proc means data=Loans_Accepted_Less_NAVAR_Corrct NMISS N;
run;

/* To find out duplicate values */
proc sql;
   title 'Lending club data analysis';
   select *, count(*) as Count
      from Loans_Accepted_Less_NAVAR_Corrct
      group by id
      having count(*) > 1;
	run;

/*what numeric varables impact loan status */
proc means data=Loans_Accepted_Less_NAVAR_Corrct;
class risk;
var installment funded_amnt loan_amnt annual_inc dti delinq_2yrs inq_last_6mths int_rate;
run;

ods graphics on;
/* Frequency distribution by Loan Purpose, Term and Loan status */
proc freq data=Loans_Accepted_Less_NAVAR_Corrct order=freq;
     tables loan_term  risk  ;      
run;

ods graphics off;

ods graphics on;
/* To find corelation between related numeric value */
proc corr data= Loans_Accepted_Less_NAVAR_Corrct;
var  delinq_2yrs inq_last_6mths ;
run;
ods graphics off;

/* does  term home_ownership emp_length affect status*/
proc freq data= Loans_Accepted_Less_NAVAR_Corrct;
table loan_term*risk / nocol nofreq nocum nopercent chisq;
table h_ownership*risk/nocol nofreq nocum nopercent chisq;
run;

proc SGSCATTER DAta=Loans_Accepted_Less_NAVAR_Corrct;
	MATRIX annual_inc dti int_rate delinq_2yrs 
		/ 
		DIAGONAL=(HISTOGRAM  )
		START=TOPLEFT
		ELLIPSE=(ALPHA=0.05 TYPE=PREDICTED)
		NOLEGEND;
RUN;


/* Plot a bar chart of loan status */
proc gchart data=Loans_Accepted_Less_NAVAR_Corrct;
title 'Frequency of Risk ';
	vbar risk /discrete percent;
run;
ods graphics on;

/* Splitting the Dataset */

proc surveyselect data=Loans_Accepted_Less_NAVAR_Corrct out=Loans_Accepted_Sampled outall samprate=0.7 seed=2;
run;

data Loans_Accepted_Training Loans_Accepted_Test;
set Loans_Accepted_Sampled;
if selected then output Loans_Accepted_Training;
else output Loans_Accepted_Test;
run;


proc contents data=Loans_Accepted_Training varnum;
run;


/* Implementing Decsiion Tree*/

proc hpsplit data=Loans_Accepted_Training vmethod=random(5) intervalbins=10 mincatsize=15
minleafsize=35 plots=all cvmodelfit;

class loan_term h_ownership verif_status  applicat_type hardship_fl  disburse_method debt_settle_flag risk;
model risk = loan_amnt loan_term h_ownership verif_status applicat_type hardship_fl debt_settle_flag disburse_method int_rate 
installment annual_inc annual_inc dti delinq_2yrs fico_range_high fico_range_high inq_last_6mths open_acc 
recoveries collections_12_mths_ex_med  acc_now_delinq pub_rec_bankruptcies tax_liens;	
grow entropy;
	prune costcomplexity;
	code file = 'lbwtTree.sas';
run;


/* Implementing Random Forest */

PROC HPFOREST DATA= Loans_Accepted_Training;
	TARGET risk /LEVEL=nominal;
	INPUT loan_term h_ownership verif_status applicat_type hardship_fl disburse_method 
		  debt_settle_flag /LEVEL=nominal;
	INPUT loan_amnt int_rate installment annual_inc annual_inc dti delinq_2yrs fico_range_high 
		fico_range_high inq_last_6mths open_acc 
		recoveries  
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

proc sql;
select avg(loan_amnt) from Loans_Accepted_Training where risk = 2;
run;

