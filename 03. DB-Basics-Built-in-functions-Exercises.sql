USE SoftUni;

--Problem 1.	Find Names of All Employees by First Name

SELECT FirstName,LastName
  FROM Employees
 WHERE FirstName LIKE 'SA%'

 --Problem 2.	  Find Names of All employees by Last Name 

 SELECT FirstName, LastName
   FROM Employees
  WHERE LastName LIKE '%ei%'

  --Problem 3.	Find First Names of All Employees

SELECT FirstName
  FROM Employees
 WHERE DepartmentID IN (3,10) AND YEAR(HireDate) BETWEEN 1995 AND 2005

--Problem 4.	Find All Employees Except Engineers

SELECT FirstName,LastName
FROM   Employees
WHERE  JobTitle NOT LIKE '%engineer%'

--Problem 5.	Find Towns with Name Length

SELECT [Name]
FROM   Towns
WHERE  LEN([Name]) IN (5,6)
ORDER BY [Name]

--Problem 6.	 Find Towns Starting With

SELECT *
FROM   Towns
WHERE  [Name] LIKE '[M,K,B,E]%'
ORDER BY [Name]

--Problem 7.	 Find Towns Not Starting With

SELECT *
FROM   Towns
WHERE  [Name] LIKE '[^R,B,D]%' /*Or just use NOT LIKE without the negation in the string ^*/
ORDER BY [Name]

--Problem 8.	Create View Employees Hired After 2000 Year

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE YEAR(HireDate) > 2000

--SELECT * FROM V_EmployeesHiredAfter2000

--Problem 9.	Length of Last Name

SELECT FirstName, LastName
FROM Employees
WHERE LEN(LastName) = 5

--Problem 10.	Rank Employees by Salary

SELECT EmployeeID,FirstName,LastName,Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeId) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

--Problem 11.	Find All Employees with Rank 2 *

SELECT * FROM (
SELECT EmployeeId,FirstName,LastName,Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeId) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000) AS e
WHERE [Rank] = 2
ORDER BY Salary DESC

--Problem 12.	Countries Holding ‘A’ 3 or More Times

USE Geography

SELECT [CountryName],IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode

--Problem 13.	 Mix of Peak and River Names

SELECT PeakName, RiverName, LOWER(PeakName + SUBSTRING(RiverName,2,LEN(RiverName))) AS Mix
FROM Peaks, Rivers
WHERE RIGHT(PeakName,1) = LEFT(RiverName,1)
ORDER BY Mix

--Problem 14.	Games from 2011 and 2012 year

USE Diablo

SELECT TOP(50) [Name],FORMAT([Start],'yyyy-MM-dd') AS [Start]
FROM Games
WHERE YEAR([Start]) BETWEEN 2011 AND 2012
ORDER BY [Start], [Name]

--Problem 15.	 User Email Providers

SELECT Username,SUBSTRING(Email,CHARINDEX('@',Email)+1,LEN(Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username

--Problem 16.	 Get Users with IPAdress Like Pattern

SELECT Username,[IpAddress] AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1_%._%.___'
ORDER BY Username

--Problem 17.	 Show All Games with Duration and Part of the Day

SELECT [Name] AS [Game],
CASE
	WHEN DATEPART(HOUR,([Start])) >= 0 AND DATEPART(HOUR,([Start])) < 12 THEN 'Morning'
	WHEN DATEPART(HOUR,([Start])) >= 12 AND DATEPART(HOUR,([Start])) < 18 THEN 'Afternoon'
	WHEN DATEPART(HOUR,([Start])) >= 18 AND DATEPART(HOUR,([Start])) < 24 THEN 'Evening'
	END AS [Part of the Day],
CASE
	WHEN [Duration] <=3 THEN 'Extra Short'
	WHEN [Duration] >3 AND [Duration] <=6 THEN 'Short'
	WHEN [Duration] >6 THEN 'Long'
	WHEN [Duration] IS NULL THEN 'Extra Long'
	END AS [Duration]
FROM Games
ORDER BY [Name], Duration, [Part of the Day]

--Problem 18.	 Orders Table

USE Orders

SELECT ProductName,OrderDate, DATEADD(DAY,3,OrderDate) AS [Pay Due],DATEADD(MONTH,1,OrderDate) AS [Deliver Due]
FROM Orders

--Problem 19.	 People Table

USE master

CREATE DATABASE DBForEx3BuiltInFunctions

USE DBForEx3BuiltInFunctions

CREATE TABLE People (
	Id INT IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	BirthDate DATE NOT NULL,
	CONSTRAINT PK_PeopleId PRIMARY KEY (Id));

INSERT INTO People VALUES
('Victor','2000-12-07'),
('Steven','1992-09-10'),
('Stephen','1910-09-19'),
('John','2010-01-06')

SELECT * FROM People

SELECT [Name],DATEDIFF(YEAR,BirthDate,GETDATE()) AS [Age in Years],
	DATEDIFF(MONTH,BirthDate,GETDATE()) AS [Age in Months],
	DATEDIFF(DAY,BirthDate,GETDATE()) AS [Age in Days],
	DATEDIFF(MINUTE,BirthDate,GETDATE()) AS [Age in Minutes]
FROM People