*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding the effectness of a direct marketing campaigns of a 
Portuguese banking institution.
Dataset Name: bank_analytical created in external file
STAT660_s17-team-2_project2_data_preparation.sas, which is assumed to be
in the same directory as this file.
See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that generates analytic dataset FRPM1516_analytic_file;
%include '.\STAT660-02_s17-team-2_project1_data_preparation.sas'

;

title1
'Research Question: Who were the clients of this bank?'

;

title2
'Rationale: This would help to identify the client of this bank, helping to understand who would be the target clients.'

;

footnote1


;

footnote2


;

*
Methodology: Used proc freq to find the frequency of custmoer demographic
data, using the result to draw a picture of the customers of the bank.
Limitations: Since there are limited demographic variables in the dataset,
it would be better to include more attributes for more accurate results.
Follow-up Steps: Add more client demographic data into the data set or combine
with other data results of bank clients analysis.

proc freq 
    data =bank_analytic_file
     ;
     table 
        age 
     /nocum
     ;
run;

proc freq 
    data =bank_analytic_file
     ;
     table 
        job 
     /nocum
     ;
run;

proc freq 
    data =bank_analytic_file
     ;
     table 
        marital
     /nocum
     ;
run;

proc freq 
    data =bank_analytic_file
     ;
     table 
        education
     /nocum
     ;
run;

proc freq 
    data =bank_analytic_file
     ;
     table 
        housing
     /nocum
     ;
run;

proc freq 
    data =bank_analytic_file
     ;
     table 
        loan
     /nocum
     ;
run;


proc means 
     data =bank_analytic_file 
     mean median maxdec=2
     ;
     var 
        age,balance
     ;
run;
title;
footnote;

title1
'Research Question:What's the relationship between previous campaign outcome and this campaign result?'

;

title2
'Rationale: This would help find out how the previous campaign outcome affected this campaign result, meanwhile, we are able to indentify who were the customer easily affected by campaigns.'
;

footnote1
''

;

footnote2
''

;

footnote3
'' 

;
*
Methodology: Use PROC glm to run the logistic regression to find out the
exact relationship and whether this is significant in reality.
Limitations: There are many'unkonwn' and 'other' values in the data set.
This will effect the accurace of the result because of the poor data quality.
Follow-up Steps: Find out a propriate value instead of using 'unknown' value
;

proc logistic 
    data=bank_analytic_file
    ;
    model y = poutcome
    ;
run;

proc glm 
    ;
    model y = poutcome
    ;
run;

title;
footnote;

title1
'Research Question: Is the comsumer price related to the campaign result?'

;

title2
'Rationale: This would help to find out whether there is a relationship among them. Moreover how did social economic affect the marketing campaign result if there is a relationship.'

;

footnote1
''

;

footnote2
''

;

footnote3
''

;

*
Methodology: Use proc glm to build a regression model to find out the relationship. 

Limitations:Since consumer price is only one of the social and economic context 
attributes.This analysis result may not be enough to undersatand how would the 
social and economic context affect the marketing campaign.
Follow-up Steps:Include more social and economic context attributes in the model.
;

proc glm 
    ;
    model y = cons.price
    ;
run;


run;
title;
footnote;
