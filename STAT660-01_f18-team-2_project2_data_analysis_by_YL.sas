*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding bank clients' decisions to subscribe a term deposit at a 
Portuguese banking institution.

Dataset Name: bank_analysis created in external file 
team-2_project2_data_preparation.sas, which is assumed to be in the same 
directory as this file

See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic datasets cde_2014_analytic_file,
  cde_2014_analytic_file_sort_frpm, and cde_2014_analytic_file_sort_sat;
%include '.\team-2_project2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: How was the last phone call duration distributed compared to the outcome of subscription?'
;

title2
"Rationale: According to the data dictionary, this duration attribute highly affects the response variable, which is the outcome of subscription."
;

footnote1
"The Boxplot showing the distributions of phone call duration by the subscription outcome is highly skewed."
;

footnote2
"Besides, it is hard to tell the significant difference by only eyeballing the boxplot"
;
*
Note: This is essentially trying to take a look at the response variable y in 
the original bank_subscriber and bank_nonsubscriber datasets.

Methodology: Adopte a boxplot to take a look at the distribution of 
interested attribute, and to visually compare the attribute's difference
between two subgroups.

Limitations: Eyeballing the difference is sometimes hard.

Followup Steps: Run a statistical test between two subgroups for the same
attribute.
;

proc sort 
        data=bank_analysis
    ;
    by 
        y
    ;
run;

proc univariate 
        data = bank_analysis
        plot
    ;
    var duration
    ;
    by
        y
    ; 
run;

title2
"To compare the duration for different subsription outcome statistically, use t test"
;

footnote1
"t test reveals a very small p value, indicating that the two durations for different subsriptions are significantly different"
;

footnote2
"That is to say, last phone call's duraion does affect the outcome of subsription, as stated by the data dictionary"
;

proc ttest
        data = bank_analysis
    ;
    var 
        duration
    ;
    class 
        y 
    ;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: How do the social and economic attributes affect the outcome of subscription?'
;

title2
'Rationale: This would help to determine how important the social and economic attributes are to the response variable'
;

footnote1
"A logistic regression model reveals that 4 out of 5 social/economics attributes are significant."
;

footnote2
"That is to say, the quarterly employment variation rate, the montly consumer price index, the monthly consumer confidence index and the quarterly number of employees are affecting the clients' decision to subsribe a term deposit."
;

footnote3
"In other words, the society's financial environments are highly affecting citizens' decision whether to put their money in the bank."
;

*
Note: This compares the columns of social/economics attributes in the bank_se
to the outcome of subscription colume y in data_subscriber and 
data_nonsubscriber datasets.

Methodology: The outcome/response varialbe is binary, thus a logistic 
regression model was used to see which of the social/economics attributes are 
affecting the subscription of bank clients.

Limitations: This model only takes the social/economic attributes into 
consideration to prove their affects. A combined model with the bank's campaign
activities and the clients' own info might affect the signficance of these SE
attributes.

Followup Steps: A full model with all the possible attributes should be 
incorporated.
;

proc logistic
        data = bank_analysis
    ;
    model
        y = emp_var_rate cons_price_idx cons_conf_idx euribor3m nr_employed
    ;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: How do the compaign activities of the bank affect the customers decision of subscription?'
;

title2
'Rationale: This would help to determine the efficiency of the bank campaigns'
;

footnote1
"A logistic regression model was built to check how the previous campaigns and contacts affect the decision of subscription"
;

footnote2
"Small p values indicate that these attributes are significant"
;

footnote3
"In other words, the campaign acitivites of the bank do influence the clients decision to subscribe a term deposit"
;

*
Note: This compares bank's campaign activites with the response varaible.

Methodology: A logtistic regression method is used as the response variable is
binary.

Limitations: Even though logistic regression has less assumptions, it does have
some assumptions for the model to be properly used. On the other hands, many 
machine learning algorithsms has less assumptions and predict accurate results.
For example, kNN for numeric predicting variables, and neutral networks et al.

Followup Steps: Different machine learning predicting tools might be help to 
predict easy, and accurate results.
;

proc logistic
        data=bank_analysis
    ;
    class
        poutcome
    ;
    model
        y = campaign previous poutcome
    ;   
run;

title;
footnote;
