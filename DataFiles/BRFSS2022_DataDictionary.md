BRFSS 2022 Data Dictionary
=========
This dictionary is for the portion of modified [BRFSS 2022](https://www.cdc.gov/brfss/annual_data/annual_2022.html) data that is provided in the file brfss2022_cleaned.rds.


| Variable Name | Original BRFSS Variable   | Description | Variable Label |
|---------------|---------------------------|-------------|----------------|
|sex            |_SEX                       |Calculated sex variable |  1=Male; 2=Female|
|race           |_RACE1                | Computed race-ethnicity grouping | 1=White only, non-Hispanic; 2=Black only, non-Hispanic; 3=American Indian or Alaskan Native only, Non-Hispanic; 4=Asian only, non-Hispanic; 5=Native Hawaiian or other Pacific Islander only, Non-Hispanic; 7=Multiracial, non-Hispanic; 8=Hispanic; All else=Missing|
|age            |_AGE_G      | Imputed age in six groups | 1=18 to 24; 2=25 to 34; 3=35 to 44; 4=45 to 54; 5=55 to 64; 6=65 or older| 
|genhealth      |GENHLTH        | Response to "Would you say that in general your health is:"| 1=Excellent; 2=Very good; 3=Good; 4=Fair; 5=Poor;All else=Missing |
|exercise       |EXERANY2 | During the past month, other than your regular job, did you participate in any physical activities or exercises such as running, calisthenics, golf, gardening, or walking for exercise? | 1=Yes; 2=No; All else=Missing |
|sleep          |SLEPTIM1 | On average, how many hours of sleep do you get in a 24-hour period? | 1 - 24 number of hours; All else=Missing |
|income | INCOME3        | Annual household income from all sources | 1=Less than $10,000; 2=$10,000 to < $15,000; 3=$15,000 to < $20,000; 4=$20,000 to < $25,000; 5=$25,000 to < $35,000; 6=$35,000 to < $50,000; 7=$50,000 to < $75,000; 8=$75,000 to < $100,000; 9=$100,000 to < $150,000; 10=$150,000 to < $200,000; 11=$200,000 or more; All else=Missing |
|covidpos | COVIDPOS        | Have you ever been told you tested positive for COVID 19? | 1=Yes; 2=No; All else=Missing |
|depression | ADDEPEV3       | (Ever told) (you had) a depressive disorder (including depression, major depression, dysthymia, or minor depression)? | 1=Yes; 2=No; All else=Missing |

