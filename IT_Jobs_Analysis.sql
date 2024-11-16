--1 Highest paying job per city
Select * from (SELECT 
    jc.Location,
    jc.Company,
    j.JobTitle,
    s.AvgSalary,
    ROW_NUMBER() OVER (PARTITION BY jc.Location ORDER BY s.AvgSalary DESC) AS RowNum
FROM Job_Country jc
JOIN IT_Salaries s ON jc.JobID = s.JobID
JOIN IT_Jobs j ON jc.JobID = j.JobID) query
WHERE ROWNum = 1;

--2 Running total of the average salary for each job category
SELECT 
    j.Category,
	j.JobTitle,
	j.level,
    s.AvgSalary,
    SUM(s.AvgSalary) OVER (PARTITION BY j.Category ORDER BY s.AvgSalary) AS RunningTotal
FROM IT_Jobs j
JOIN IT_Salaries s ON j.JobID = s.JobID
ORDER BY j.Category, s.AvgSalary;




--3 Percentage of Job offers that are remote per city
SELECT 
    Location,
    cast(COUNT(CASE WHEN Remote = 1 THEN 1 END) * 100 / COUNT(*) as varchar) + '%' AS [Remote %]
FROM Job_Country
GROUP BY Location;

--4 Average Salary gap between job levels
WITH SalariesByExperience AS (
    SELECT j.JobTitle,j.Level,s.AvgSalary,
      LEAD(s.AvgSalary) OVER (PARTITION BY j.JobTitle ORDER BY j.Level) AS HigherExperienceSalary
    FROM IT_Jobs j
    JOIN IT_Salaries s ON j.JobID = s.JobID)
SELECT 
    JobTitle,Level,AvgSalary,HigherExperienceSalary,
    HigherExperienceSalary- AvgSalary AS SalaryGap
FROM SalariesByExperience
WHERE HigherExperienceSalary IS NOT NULL;
