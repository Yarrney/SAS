**********************************************************
Date Converter - SAS and Teradata
Author: Alex Arney
Created: 2015-03-05
Last update: 2015-03-05
**********************************************************
This macro code requires two inputs:
      1. The date in either SAS format or Teradata format,
      depending on which way you would like to convert the date. 
      2. The name of the converted date variable. Note this
      output is as global macro variable.
 
These inputs should be in the following format:
 
%ConvertSASDate(*yourSASdate*,*ConvertedDateName*)
%ConvertTeradataDate(*yourTeradatadate*,*ConvertedDateName*)
 
NOTES:
      1.    The macro variable name cannot start with a number,
            and cannot contain any spaces.
      2.    The assumption used here is that the date format used
            for the teradata date is of the following:
            1YYMMDD (So Jan 7 2015 is 1150107).
**********************************************************;
 
/*Macro variable debugging*/
options symbolgen mlogic ;
 
**********************************************************
CONVERT SAS DATE TO TERADATA DATE
**********************************************************;
%macro ConvertSASDate(date,name);
 
data _null_;
/*    Get date variables separated */
      day = day(&date.);
      month = month(&date.);
      year = year(&date.);
 
/*    Convert variables to character*/
      if day > 9 then day_char = put(day,2.); /*Determines if you need one or two digits*/
      else day_char = cats('0',put(day,2.));
 
      if month > 9 then month_char = put(month,2.);
      else month_char = cats('0',put(month,2.));
     
      year_char = substr(put(year,4.),3); /*Converts it to a two digit date*/
     
/*    Concatenate the date into one string (and remove any blanks)*/
      teradate = cats('1',year_char,month_char,day_char);
 
/*    Create a global macro variable with corresponding name so that it can be used/referenced later */
      call symputx("&name.",teradate,'G');
 
run;       
 
%mend ConvertSASDate;
 
**********************************************************
CONVERT TERADATA DATE TO SAS DATE
**********************************************************;
 
%macro ConvertTeradataDate(date,name);
 
data _null_;
/*    Get date variables separated (convert from text (macro) to numeric)*/
      year = substr(strip(&date.),2,2);
      month = substr(strip(&date.),4,2);
      day = substr(strip(&date.),6,2);
      put day= month= year=;
     
/*    Concatenate the date into one string adding ''d bounding for SAS date format*/
/*    sasdate_char = cats("'",month,day,year,"'d");*/
      sasdate = mdy(month,day,year);
/*    Create a global macro variable with corresponding name so that it can be used/referenced in later code */
      call symputx("&name",sasdate,'G');
 
run;       
 
%mend ConvertTeradataDate;
 
%ConvertTeradataDate(1150107,Test)
%ConvertSASDate(&Test.,ReverseTest)