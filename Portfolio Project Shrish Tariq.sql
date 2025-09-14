---- SQL Portfolio Project----

CREATE database virginiapatients;

Use virginiapatients;

--- Basic SQL & Data Retrieval
--- 1. Retrieve all columns from the Appointments table.
--- Solution:
SELECT * FROM virginia_patients;
---- 2. List the first 10 appointments where the patient is older than 60.
-- Solution:
SELECT AppointmentID FROM virginia_patients
WHERE Age > 60 limit 10;
--- 3. Show the unique neighborhoods from which patients came.
-- Solution:
SELECT Distinct Neighbourhood From virginia_patients;
SELECT * FROM virginia_patients;
---- 4. Find all female patients who received an SMS reminder. Give count of them
-- Solution:
SELECT Count(*) AS female_sms_received
FROM virginia_patients WHERE Gender = 'Female' AND SMS_received = 1;

SELECT * FROM virginia_patients;

-- Data Modification & Filtering
-- 5. Update the dates in ScheduledDay and AppointmentDay columns to the correct date format
--- (hint: str_to_date() is a very helpful function to sort out dates)
-- Solution:
SELECT * FROM virginia_patients;
SET sql_safe_updates = 0;

ALTER TABLE virginia_patients
ADD PRIMARY key (PatientId);

UPDATE virginia_patients
SET ScheduledDay = str_to_date(ScheduledDay, '%m/%d/%Y'),
AppointmentDay = str_to_date(AppointmentDay, '%m/%d/%Y')
WHERE PatientId is not NULL;
--- To verify our updates--
SELECT ScheduledDay, AppointmentDay FROM virginia_patients LIMIT 5;

--- 6. Modify the datatypes of the ScheduledDay and AppointmentDay columns to DATE
-- Solution:
ALTER TABLE virginia_patients
modify column ScheduledDay DATE,
modify column AppointmentDay DATE;
SELECT * FROM virginia_patients;

---- 7. Update the 'Showed_up' status to 'Yes' where it is null or empty
-- Solution:
UPDATE virginia_patients
SET Showed_up = 'Yes'
WHERE Showed_up IS NULL OR Showed_up = '';
SELECT * FROM virginia_patients;

--- 8. Add a new column AppointmentStatus using a CASE statement:
--- 'No Show' if Showed_up = 'No'
--- 'Attended' otherwise
--- Solution:
ALTER TABLE virginia_patients
ADD Column AppointmentStatus TEXT;
SELECT * FROM virginia_patients;
UPDATE virginia_patients
SET AppointmentStatus = Case
WHEN Showed_up = 'No' THEN 'No Show' ELSE 'Attended'
END;
SELECT * FROM virginia_patients;
SELECT PatientId, Showed_up,
CASE WHEN Showed_up = 'No' THEN 'No Show' ELSE 'Attended' END AS AppointmentStatus 
FROM virginia_patients LIMIT 10;

--- 9. Filter appointments for diabetic patients with hypertension.
-- Solution:
select * FROM virginia_patients;
SELECT * FROM virginia_patients
WHERE Diabetes = 1 AND Hypertension = 1;

--- 10. Order the records by Age in descending order and show only the top 5 oldest patients.
-- Solution:
SELECT * FROM virginia_patients
ORDER BY Age DESC LIMIT 5;
SELECT * FROM virginia_patients;

--- 11. Limit results to the first 5 appointments for patients under age 18.
-- Solution:
SELECT * FROM virginia_patients
WHERE Age < 18
LIMIT 5;
SELECT * FROM virginia_patients;
--- 12. Display all appointments scheduled on or after '2023-05-01' and before '2023-06-01'.
-- Solution:
SELECT * FROM virginia_patients
WHERE ScheduledDay >= '2023-05-01' AND ScheduledDay < '2023-06-01';
SELECT * FROM virginia_patients;

--- Aggregation And CASE---
-- 13 Find the average age of patients for each gender.---
-- Solution--
SELECT Gender, AVG(Age) as average_age FROM virginia_patients GROUP BY Gender;

SELECT * FROM virginia_patients;
-- 14. Count how many patients received SMS reminders, grouped by Showed_up status.
-- Solution:
SELECT Showed_up, Count(*) as SMS_reminders FROM virginia_patients WHERE SMS_received = 1 GROUP BY Showed_up;
SELECT * FROM virginia_patients;
-- 15. Count no show appointments in each neighbourhood using Group by.
-- Solution:
SELECT Neighbourhood, COUNT(*) AS no_show_count FROM virginia_patients WHERE Showed_up = 'No' GROUP BY Neighbourhood;
SELECT * FROM virginia_patients;
-- 16. Show neighbourhoods with more than 100 total appointments (HAVING CLAUSE) 
-- Solution: 
SELECT Neighbourhood, COUNT(PatientId) as total_appointments FROM virginia_patients GROUP BY Neighbourhood Having COUNT(PatientId) > 100;
--- 17. Use case to calculate the total number of: 
-- Children age < 12 
-- Adults (Age between 12 AND 60) 
-- Seniors (Age > 60) 
-- Solution: 
SELECT COUNT(Case WHEN Age < 12 THEN 1 END) AS Children, 
COUNT(Case WHEN Age BETWEEN 12 AND 60 THEN 1 END) AS Adults, 
COUNT(Case WHEN Age > 60 THEN 1 END) AS Seniors 
FROM virginia_patients;
-- 18. Show whether patients are more likely to miss appointments on certain days of the week.
-- (This can reveal patterns like more no-shows on Mondays or weekends, helping clinics to adjust scheduling.)
 -- Steps to follow for question # 20 (You can use any approach to solve this question):  (Use the AppointmentDay column in function dayname() to extract the day name (like
-- Monday, Tuesday, etc.).  Count how many appointments were scheduled, how many showed up (showed_up = "yes") and how many were missed (Showed_up = 'No') on each day.  Calculate the percentage of shows and no-shows for better comparison between days.  Formula: (count of Showed_up = 'yes' / total appointment count ) * 100, Use round
-- function to show upto two decimal points  Sort the result by No_Show_Percent in descending order to see the worst-performing days first.

--- Solution: 
SELECT * FROM virginia_patients;
SELECT DAYNAME(AppointmentDay) as Appointment_Day, COUNT(*) AS Total_Appointments, 
COUNT(CASE WHEN Showed_up = 'Yes' THEN 1 END) AS Showed_up,
COUNT(CASE WHEN Showed_up = 'No' THEN 1 END) AS No_Show, 
ROUND((COUNT(CASE WHEN Showed_up = 'No' THEN 1 END) * 100.0) / COUNT(*), 2) AS No_Show_Percent FROM virginia_patients
GROUP BY DAYNAME(AppointmentDay)
ORDER BY No_Show_Percent DESC;
SELECT * FROM virginia_patients;
-- Window Functions--
-- 19. Track how appointments accumulate over time in each neighbourhood. 
--- (Running Total of Appointments per Day) 
---- In simple words: How many appointments were there each day and how do the total appointments keep adding up over time in each neighborhood?
-- Solution:
SELECT Neighbourhood, AppointmentDay, COUNT(*) AS daily_appointments,
SUM(COUNT(*)) OVER(PARTITION BY Neighbourhood
ORDER BY AppointmentDay ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS Running_total 
FROM virginia_patients
GROUP BY Neighbourhood, AppointmentDay 
ORDER BY Neighbourhood, AppointmentDay;
SELECT * FROM virginia_patients;
--- 20. Use Dense_Rank() to rank patients by age within each gender group--
--- Solution: 
SELECT PatientId, Gender, Age, DENSE_RANK() OVER(PARTITION BY Gender
ORDER BY Age DESC) AS age_rank FROM virginia_patients;
SELECT * FROM virginia_patients;
--- 21. How many days have passed since the last appointment in the same neighborhood?
--- (Hint: DATEDIFF and Lag)
---- (This helps to see how frequently appointments are happening in each neighborhood.)
--- Solution:
SELECT PatientID, Neighbourhood, AppointmentDay, 
LAG(AppointmentDay) OVER(PARTITION BY Neighbourhood 
ORDER BY AppointmentDay) 
AS Previous_Appointment, DATEDIFF(AppointmentDay, LAG(AppointmentDay) 
OVER(PARTITION BY Neighbourhood ORDER BY AppointmentDay)) AS Since_Last_Appointment 
FROM virginia_patients ORDER BY Neighbourhood, AppointmentDay;
SELECT * FROM virginia_patients;
--- 22 Which neighbourhoods have the highest number of missed appointments?
--- Use DENSE_RANK() to rank neighbourhoods based on the number of no-show appointments. 
--- Solution: 
SELECT Neighbourhood, COUNT(*) AS missed_appointments, 
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) 
AS Missed_rank FROM virginia_patients WHERE Showed_up = 'No' 
GROUP BY Neighbourhood ORDER BY Missed_rank;
SELECT * FROM virginia_patients; 
--- Subqueries and CTEs---
--- 23. Continuing from Q 21. Show the neighbourhoods with the second and third highest no show counts
--- Solution:
WITH Noshow_counts AS(SELECT Neighbourhood, COUNT(*) AS Missed_appointments, 
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS missed_rank 
FROM virginia_patients 
WHERE Showed_up = 'No' 
GROUP BY Neighbourhood) 
SELECT * FROM Noshow_counts WHERE missed_rank IN (2, 3);
SELECT * FROM virginia_patients;
--- 24. Find out all female patients that have an age higher than the average age of all female patients. 
--- Solution: 
SELECT * FROM virginia_patients 
WHERE Gender = 'Female' 
AND Age > (SELECT AVG(Age) 
FROM virginia_patients 
WHERE Gender = 'Female');
SELECT * FROM virginia_patients;
--- Q 25. Find out all details of the most recent appointment in each neighbourhood based on appointmentday.
--- Hint: First, find out what the most recent appointmentday in each neighbourhood is. 
-- Then, you can simply join this result (think CTE) to your main table to get details of the latest appointment within each neighbourhood
--- Solution: 
WITH Latest_appointments AS(SELECT Neighbourhood,
MAX(AppointmentDay) AS Most_recent_day
FROM virginia_patients
GROUP BY Neighbourhood)
SELECT vp.* FROM virginia_patients vp
JOIN Latest_appointments la ON vp.Neighbourhood = la.Neighbourhood 
AND vp.AppointmentDay = la.Most_recent_day;
SELECT * FROM virginia_patients;

