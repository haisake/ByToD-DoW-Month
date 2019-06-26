/*
-- Do not calculate weekly number like this, because it counts the weekly number of census nights by all ALC patients
-- Not the number of patients, for the number of patients, either count the average number of patients per day, or the average number of census on a Thursday
-- ALC Categories, weekly average census night by ALC patients
Select FacilityLongName
        , PatientServiceCode
        , PatientServiceDescription
        , count(PatientID) as TotalALCDays  
		, (datediff(day, '2017-04-01', '2019-01-31') + 1)/7 as NumOfWeeks
		, count(PatientID)*1.0/((datediff(day, '2017-04-01', '2019-01-31') + 1)*1.0/7) AverageALCbyWeek
From [ADTCMart].[ADTC].[vwCensusFact]
Where FacilityLongName in ('Powell River General Hospital')
        and CensusDate between '2017-04-01' and '2019-01-31' 
		and AccountType = 'Inpatient'
        and (PatientServiceCode like '%ALC%' or PatientServiceDescription like '%ALC%')
		and NursingUnitDesc not in ('Inpatient Psychiatry')
Group by FacilityLongName
        , PatientServiceCode
        , PatientServiceDescription
*/

-- ALC Categories, daily average census night by ALC patients
Select FacilityLongName
        , PatientServiceCode
        , PatientServiceDescription
        , count(PatientID) as TotalALCDays  
		, (datediff(day, '2017-04-01', '2019-01-31') + 1) as NumOfDays
		, count(PatientID)*1.0/((datediff(day, '2017-04-01', '2019-01-31') + 1)) AverageALCbyDay
From [ADTCMart].[ADTC].[vwCensusFact]
Where FacilityLongName in ('Powell River General Hospital')
        and CensusDate between '2017-04-01' and '2019-01-31' 
		and AccountType = 'Inpatient'
        and (PatientServiceCode like '%ALC%' or PatientServiceDescription like '%ALC%')
		and NursingUnitDesc not in ('Inpatient Psychiatry')
Group by FacilityLongName
        , PatientServiceCode
        , PatientServiceDescription



-- ALC Categories, daily average census night by ALC patients
Select a.FacilityLongName
	    , b.FiscalYear
		, b.FiscalPeriod
        , a.PatientServiceCode
        , a.PatientServiceDescription
        , count(a.PatientID) as TotalALCDays  
		, AVG(b.FPDay) as DayCount
		, count(PatientID)*1.0/AVG(b.FPDay) AverageALCbyDay
From [ADTCMart].[ADTC].[vwCensusFact] a
Left join (SELECT ShortDate
				, FiscalYear
				, FiscalPeriod
				, cast (FiscalPeriodDayCount as int) as FPDay
			FROM [ADTCMart].[dim].[Date]
			Where ShortDate between '2016-04-01' and '2019-02-07') b on a.CensusDate = b.ShortDate
Where a.FacilityLongName in ('Powell River General Hospital')
        and a.CensusDate between '2016-04-01' and '2019-02-07'
		and a.AccountType = 'Inpatient'
        and (a.PatientServiceCode like '%ALC%' or a.PatientServiceDescription like '%ALC%')
		and a.NursingUnitDesc not in ('Inpatient Psychiatry')
Group by a.FacilityLongName
	    , b.FiscalYear
		, b.FiscalPeriod
        , a.PatientServiceCode
        , a.PatientServiceDescription
Order by a.FacilityLongName
	    , b.FiscalYear
		, b.FiscalPeriod
        , a.PatientServiceCode
        , a.PatientServiceDescription