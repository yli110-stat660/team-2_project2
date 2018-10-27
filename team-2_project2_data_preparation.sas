*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

* 
[Dataset 1 Name] bank_nonsubscribe

[Dataset Description] This is a subset of the bank-full dataset with which the clients did not subscribe a term deposit. The bank-full dataset can be found at http://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank.zip

[Experimental Unit Description] Each client in the Protuguese bank who didn't subscribe a term deposit.

[Number of Observations] 39922                    

[Number of Features] 17

[Data Source]  A subset of bank-full with y variable being "no". 

[Data Dictionary] http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#

[Unique ID Schema] The columns "age", "job", "marital", "education", "default", "housing" and "load" compose an unique ID (hopefully).

--

[Dataset 2 Name] bank_subscribe

[Dataset Description] This is a subset of the bank-full dataset with which the clients subscribed a term deposit.

[Experimental Unit Description]  Each client in the Protuguese bank who subscribed a term deposit.

[Number of Observations] 5289                    

[Number of Features] 17

[Data Source] A subset of bank-full with y variable being "yes".

[Data Dictionary] http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#

[Unique ID Schema] The columns "age", "job", "marital", "education", "default", "housing" and "load" compose an unique ID (hopefully).

--

[Dataset 3 Name] bank_se

[Dataset Description] This dataset contains additional attributes which was wiped out in the original bank-full dataset due to privacy reasons.

[Experimental Unit Description] Each client in the Protuguese bank.

[Number of Observations] 41188                    

[Number of Features] 12

[Data Source] This is a subset of the bank-additional-full dataset which can be found at http://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zipThis dataset only contains the client informations which serve as unique ID, and five new attributes.

[Data Dictionary] http://archive.ics.uci.edu/ml/datasets/Bank+Marketing#

[Unique ID Schema] The columns "age", "job", "marital", "education", "default", "housing" and "load" compose an unique ID (hopefully).

;


* environmental setup;

* create output formats;

/****proc format;
 
    ;
run;****/


* setup environmental parameters;
%let inputDataset1URL =
https://github.com/stat660/team-2_project2/blob/master/data/bank_nonsubsriber.csv?raw=true
;
%let inputDataset1Type = XLS;
%let inputDataset1DSN = bank_nonsubsriber_raw;

%let inputDataset2URL =
https://github.com/stat660/team-2_project2/blob/master/data/bank_subsriber.csv?raw=true
;
%let inputDataset2Type = XLS;
%let inputDataset2DSN = bank_subsriber_raw;

%let inputDataset3URL =
https://github.com/stat660/team-2_project2/blob/master/data/bank_se.csv?raw=true
;
%let inputDataset3Type = XLS;
%let inputDataset3DSN = bank_se_raw;



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
        noduprecs
        data=bank_nonsubsriber_raw
        dupout=bank_nonsubsriber_raw_dups
        out=bank_nonsubsriber_raw_sorted
    ;
    by
        age
        job
        marital
        education
        default
        housing
        load
    ;
run;
proc sort
        data=bank_subsriber_raw
        dupout=bank_subsriber_raw_dups
        out=bank_subsriber_raw_sorted
    ;
    by
        age
        job
        marital
        education
        default
        housing
        load
    ;
run;
proc sort
        noduprecs
        data=bank_se_raw
        dupout=bank_se_raw_dups
        out=bank_se_raw_sorted
    ;
    by
        age
        job
        marital
        education
        default
        housing
        load
    ;
run;


* combine FRPM data vertically, combine composite key values into a primary key
  key, and compute year-over-year change in Percent_Eligible_FRPM_K12,
  retaining all AY2014-15 fields and y-o-y Percent_Eligible_FRPM_K12 change;
data frpm1415_raw_with_yoy_change;
    retain
        CDS_Code
    ;
    length
        CDS_Code $14.
    ;
    set
        frpm1516_raw_sorted(in=ay2015_data_row)
        frpm1415_raw_sorted(in=ay2014_data_row)
    ;
    retain
        Percent_Eligible_FRPM_K12_1516
    ;
    by
        County_Code
        District_Code
        School_Code
    ;
    if
        ay2015_data_row=1
    then
        do;
            Percent_Eligible_FRPM_K12_1516 = Percent_Eligible_FRPM_K12;
        end;
    else if
        ay2014_data_row=1
        and
        Percent_Eligible_FRPM_K12 > 0
        and
        substr(School_Code,1,6) ne "000000"
    then
        do;
            CDS_Code = cats(County_Code,District_Code,School_Code);
            frpm_rate_change_2014_to_2015 =
                Percent_Eligible_FRPM_K12
                -
                Percent_Eligible_FRPM_K12_1516
            ;
            output;
        end;
run;


* build analytic dataset from raw datasets with the least number of columns and
minimal cleaning/transformation needed to address research questions in
corresponding data-analysis files;
data bank_analytic_file;
    retain
        CDS_Code
        School_Name
        Percent_Eligible_FRPM_K12
        frpm_rate_change_2014_to_2015
        PCTGE1500
        excess_sat_takers
    ;
    keep
        CDS_Code
        School_Name
        Percent_Eligible_FRPM_K12
        frpm_rate_change_2014_to_2015
        PCTGE1500
        excess_sat_takers
    ;
    merge
        frpm1415_raw_with_yoy_change
        gradaf15_raw
        sat15_raw(rename=(CDS=CDS_Code PCTGE1500=PCTGE1500_character))
    ;
    by
        CDS_Code
    ;
    if
        not(missing(compress(PCTGE1500_character,'.','kd')))
    then
        do;
            PCTGE1500 = input(PCTGE1500_character,best12.2);
        end;
    else
        do;
            call missing(PCTGE1500);
        end;
    excess_sat_takers = input(NUMTSTTAKR,best12.) - input(TOTAL,best12.);
    if
        not(missing(CDS_Code))
        and
        not(missing(School_Name))
        and
        not(missing(School_Name))
    ;
run;


* use proc sort to create a temporary sorted table in descending by
frpm_rate_change_2014_to_2015;
proc sort
        data=cde_2014_analytic_file
        out=cde_2014_analytic_file_sort_frpm
    ;
    by descending frpm_rate_change_2014_to_2015;
run;


* use proc sort to create a temporary sorted table in descending by
excess_sat_takers;
proc sort
        data=cde_2014_analytic_file
        out=cde_2014_analytic_file_sort_sat
    ;
    by descending excess_sat_takers;
run;
