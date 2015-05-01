**********************************************************
Date Converter - SAS and Teradata
Author: Alex Arney
Created: 2015-03-05
Last update: 2015-05-01
**********************************************************
This macro code requires two inputs: 
	1. The date in either any SAS format or Teradata format (1YYYYMMDD), 
	depending on which way you would like to convert the date.  
	2. The name of the converted date variable. Note this 
	output is as global macro variable.

These inputs should be in the following format:

%ConvertSASDate(*yourSASdate*,*ConvertedDateName*)
%ConvertTeradataDate(*yourTeradatadate*,*ConvertedDateName*)

*Type=A by default type A is used in the teradata date converter, but you can
specify type B if required.

A = CYYMMDD
B = 'YYYY-MM-DD'

NOTES: 
	1.	The macro variable name cannot start with a number, 
	   	and cannot contain any spaces.
	2.	The assumption used here is that the date format used
		for the teradata date is of the following: 
		CYYMMDD (So Jan 7 2015 is 1150107 - C stands for Century
		with 1=20th century).
**********************************************************;

/*Macro variable debugging*/
options symbolgen mlogic ;

**********************************************************
CONVERT SAS DATE TO TERADATA DATE
**********************************************************;
%macro ConvertSASDate(date,name,type=A);

data _null_;
/*	Get date variables separated */
	day = day(&date.);
	month = month(&date.);
	year = year(&date.);

/*	Convert variables to character (except year)*/
		if day > 9 then day_char = put(day,2.); /*Determines if you need one or two digits*/
		else day_char = cats('0',put(day,2.));

		if month > 9 then month_char = put(month,2.);
		else month_char = cats('0',put(month,2.));
		
		year_char = put(year,4.);

		if (substr(year_char,1,1)=2) then
			century = '1'; /*This refers to the 21st century*/
		else if (substr(year_char,1,1)<2) then
			century = '0'; /*assuming that we won't be going back to BC times, but you may want to look at things from the 20th century */
		else
			century = '2'; /*maybe this code and SAS will last until the 22nd century, who knows!??!*/

		
/*Determine what teradata type to use*/
	%if (&type=A) %then %do;
		/*	Convert year to a two digit character variable for concatenation*/
		year_char = substr(year_char,3,2);
		/*	Concatenate the date into one string (and remove any blanks)*/
		teradate = cats(century,year_char,month_char,day_char);
	%end;
	%else %if (&type=B) %then %do;
		/*	Concatenate the date into one string (and remove any blanks)*/
		teradate = cats("'",year_char,"-",month_char,"-",day_char,"'");
	%end;

/*	Create a global macro variable with corresponding name so that it can be used/referenced later */
	call symputx("&name.",teradate,'G');

run;		

%mend ConvertSASDate;

**********************************************************
CONVERT TERADATA DATE TO SAS DATE
**********************************************************;

%macro ConvertTeradataDate(date,name);

data _null_;

/*	Get date variables separated (convert from text (macro) to numeric)*/
	year = substr(strip(&date.),2,2);
	month = substr(strip(&date.),4,2);
	day = substr(strip(&date.),6,2);
	put day= month= year=;
	
/*	Concatenate the date into one string adding ''d bounding for SAS date format*/
/*	sasdate_char = cats("'",month,day,year,"'d");*/
	sasdate = mdy(month,day,year);
/*	Create a global macro variable with corresponding name so that it can be used/referenced in later code */
	call symputx("&name",sasdate,'G');

run;		

%mend ConvertTeradataDate;

%ConvertTeradataDate(1150107,Test)
%ConvertSASDate(&Test.,ReverseTestA)
%ConvertSASDate(&Test.,ReverseTestB,type=B)

/* Verify results - delete if you don't mind */
%put &Test;
%put &ReverseTestA;
%put &ReverseTestB;
