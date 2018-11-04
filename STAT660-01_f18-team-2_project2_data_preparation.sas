*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] bank_nonsubscribe

[Dataset Description] This is a subset of the bank-additional dataset with 
which the clients did not subscribe a term deposit.
The bank-additional dataset can be found at the following website
http://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank.zip


[Experimental Unit Description] Each client in the Protuguese bank who didn't 
subscribe a term deposit.

[Number of Observations] 36548      

[Number of Features] 17

[Data Source] A subset of bank-full with y variable being "no". 

[Data Dictionary] http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#

[Unique ID Schema] A variable named "ID" was created to identify each client.

--

[Dataset 2 Name] bank_subscribe

[Dataset Description] This is a subset of the bank-full dataset with which 
the clients subscribed a term deposit.

[Experimental Unit Description] Each client in the Protuguese bank who 
subscribed a term deposit.

[Number of Observations] 4640     

[Number of Features] 17

[Data Source] A subset of bank-full with y variable being "yes".

[Data Dictionary] http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#

[Unique ID Schema] A variable named "ID" was created to identify each client.

--

[Dataset 3 Name] bank_se

[Dataset Description] This dataset contains additional attributes which 
wasn't included in the original bank-full dataset.

[Experimental Unit Description] Each client in the Protuguese bank who 
subscribed a term deposit.

[Number of Observations] 41188

[Number of Features] 6

[Data Source] This is a subset of the bank-additional-full dataset which can 
be found at 
http://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip
This dataset only contains ID column and five new socioeconomics attributes.

[Data Dictionary] http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#

[Unique ID Schema] The column ID is a unique id.
;


* environmental setup;

* create output formats;
proc format;
    value $y
        "no"  = "Client did not subscribe a term deposit"
        "yes" = "Client subscribed a term deposit"
    ;
	value age
		17-27 = "17-27"
		28-38 = "28-38"
		39-48 = "39-48"
		49-59 = "49-59"
		60-98 = "over 60"
	;
run;

* setup environmental parameters;
%let inputDataset1URL =
https://github.com/stat660/team-2_project2/blob/master/data/bank_nonsubsriber.csv?raw=true
;
%let inputDataset1Type = CSV;
%let inputDataset1DSN = bank_nonsubscriber;

%let inputDataset2URL =
https://github.com/stat660/team-2_project2/blob/master/data/bank_subsriber.csv?raw=true
;
%let inputDataset2Type = CSV;
%let inputDataset2DSN = bank_subscriber;

%let inputDataset3URL =
https://github.com/stat660/team-2_project2/blob/master/data/bank_se.csv?raw=true
;
%let inputDataset3Type = CSV;
%let inputDataset3DSN = bank_se;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename tempfile "%sysfunc(getoption(work))/tempfile.xlsx";
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%loadDataIfNotAlreadyAvailable(
    &inputDataset1DSN.,
    &inputDataset1URL.,
    &inputDataset1Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset2DSN.,
    &inputDataset2URL.,
    &inputDataset2Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset3DSN.,
    &inputDataset3URL.,
    &inputDataset3Type.
)


* sort and check raw datasets for duplicates with respect to their unique ids,
  removing blank rows, if needed;

proc sort
        nodupkey
        data = bank_nonsubscriber
        dupout = bank_nonsubscriber_dups
        out = bank_nonsubscriber_sorted
    ;
    by
        id
    ;
run;

proc sort
        nodupkey
        data = bank_subscriber
        dupout = bank_subscriber_dups
        out = bank_subscriber_sorted
    ;
    by
        id
    ;
run;

proc sort
        nodupkey
        data = bank_se
        dupout = bank_se_dups
        out = bank_se_sorted
    ;
    by
        id
    ;
run;

* combine the bank_nonsubsriber and bank_subscriber datasets vertically. Both
datasets have identical column names;

data bank_client;
    retain
        id
        age
        job
        marital
        education
        default
        housing
        loan
        contact
        duration
        campaign
        pdays
        previous
        poutcome
        y
    ;
    keep
        id
        age
        job
        marital
        education
        default
        housing
        loan
        contact
        duration
        campaign
        pdays
        previous
        poutcome
        y
    ;
    length
        job       $20.
        education $20.
        y         $3.
    ;
    format /*HAD TO SPECIFY THE FORMAT, THE LENGTH ALONE STILL TRUNCATES DATA*/
        y         $3.
        education $20.
        job       $20.
    ;
    set
        bank_nonsubscriber_sorted
        bank_subscriber_sorted
    ;
    by
        id
    ;
run;

* build analytic dataset from combining bank_client and bank_se horizontally,
the matching column is ID.;
data bank_analysis;
    retain
        id
        age
        job
        marital
        education
        default
        housing
        loan
        contact
        duration
        campaign
        pdays
        previous
        poutcome
        y
		emp_var_rate
		cons_price_idx
		cons_conf_idx
		euribor3m
		nr_employed
    ;
    keep
        id
        age
        job
        marital
        education
        default
        housing
        loan
        contact
        duration
        campaign
        pdays
        previous
        poutcome
        y
		emp_var_rate
		cons_price_idx
		cons_conf_idx
		euribor3m
		nr_employed
    ;
    merge
        bank_client
        bank_se_sorted
    ;
    by
        ID
    ;
run;
