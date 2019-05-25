USE Softuni

--Problem 1.	Employee Address

SELECT TOP(5) *
FROM Addresses

SELECT TOP(5) *
FROM Employees

SELECT TOP(5) e.EmployeeID, e.JobTitle,e.AddressID, a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY e.AddressID

--Problem 2.	Addresses with Towns

SELECT * FROM Towns

SELECT TOP(50) e.FirstName, e.LastName, t.[Name],a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON t.TownID = a.TownID
ORDER BY FirstName, LastName

--Problem 3.	Sales Employee

SELECT TOP(5) *
FROM Employees

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name]  = 'Sales'
ORDER BY e.EmployeeID

--Problem 4.	Employee Departments

SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID

--Problem 5.	Employees Without Project

SELECT TOP(3) e.EmployeeID, e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID

--Problem 6.	Employees Hired After

SELECT e.FirstName, e.LastName, e.HireDate, d.[Name]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '01-01-1999' AND d.[Name] IN ('Sales','Finance')
ORDER BY e.HireDate

--Problem 7.	Employees with Project

SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] 
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

--Problem 8.	Employee 24

SELECT e.EmployeeID, e.FirstName,
CASE
	WHEN YEAR(p.StartDate) >= 2005 THEN NULL
	ELSE p.[Name]
	END AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

--Problem 9.	Employee Manager

SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS ManagerName
FROM Employees AS e
INNER JOIN Employees AS m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID

--Problem 10.	Employee Summary

SELECT TOP(50) e.EmployeeID,
			(e.FirstName + ' ' + e.LastName) AS EmployeeName,
			(m.FirstName + ' ' + m.LastName) AS ManagerName,
			d.[Name] AS DepartmentName
FROM Employees AS e
INNER JOIN Employees AS m ON e.ManagerID = m.EmployeeID
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

--Problem 11.	Min Average Salary

SELECT TOP(1) AVG(Salary) AS MinAverageSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY MinAverageSalary

--Problem 12.	Highest Peaks in Bulgaria

USE Geography

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON mc.MountainId = m.Id
JOIN Peaks AS p ON m.Id = p.MountainId
WHERE c.CountryName = 'Bulgaria' AND p.Elevation > 2835
ORDER BY p.Elevation DESC


--Problem 13.	Count Mountain Ranges

SELECT c.CountryCode, COUNT(m.MountainRange) AS MountainRanges
FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON m.Id = mc.MountainId
WHERE c.CountryName IN ('United States','Russia','Bulgaria')
GROUP BY c.CountryCode


--Problem 14.	Countries with Rivers

SELECT TOP(5) c.CountryName,r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
LEFT JOIN Continents AS co ON c.ContinentCode = co.ContinentCode
WHERE co.ContinentName = 'Africa'
ORDER BY c.CountryName


--Problem 15.	*Continents and Currencies

SELECT secondQuery.ContinentCode,
	   secondQuery.CurrencyCode,
	   secondQuery.UsageCounter AS [CurrencyUsage]
FROM
	(SELECT *, DENSE_RANK() OVER(PARTITION BY ContinentCode ORDER BY firstQuery.UsageCounter DESC) AS DenseRank
	FROM
		(SELECT ContinentCode, CurrencyCode, COUNT(*) AS UsageCounter
		FROM Countries
		GROUP BY ContinentCode, CurrencyCode) AS firstQuery) AS secondQuery
WHERE secondQuery.DenseRank = 1
AND secondQuery.UsageCounter <> 1
ORDER BY secondQuery.ContinentCode, secondQuery.CurrencyCode

--Problem 16.	Countries without any Mountains

SELECT COUNT(c.CountryCode) AS CountryCode
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL

--Problem 17.	Highest Peak and Longest River by Country

WITH CTE_AllTablesJoined(CountryName, HighestPeakElevation, LongestRiverLength, dRank) AS 
(
	SELECT 
		c.CountryName,  
		p.Elevation AS [HighestPeakElevation],
		r.[Length] AS [LongestRiverLength],
		DENSE_RANK() OVER 
		(PARTITION BY c.CountryName ORDER BY p.Elevation DESC, r.[Length] DESC) AS [dRank]
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc
		ON mc.CountryCode = c.CountryCode
	LEFT JOIN Peaks AS p
		ON p.MountainId = mc.MountainId
	LEFT JOIN CountriesRivers AS cr
		ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r
		ON r.Id = cr.RiverId
)

SELECT TOP(5) 
	CountryName, HighestPeakElevation, LongestRiverLength
FROM CTE_AllTablesJoined
WHERE dRank = 1
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName


--Problem 18.	* Highest Peak Name and Elevation by Country

WITH CTE_AllCountriesInfo(CountryName, [Highest Peak Name], [Highest Peak Elevation], Mountain, [dRank]) AS 
(
	SELECT 
		c.CountryName,
		ISNULL(p.PeakName, '(no highest peak)'),
		ISNULL(p.Elevation, 0), 
		ISNULL(m.MountainRange, '(no mountain)'),
		DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC)
	FROM Countries AS c
	LEFT OUTER JOIN MountainsCountries AS mc
		ON mc.CountryCode = c.CountryCode
	LEFT OUTER JOIN Peaks AS p
		ON p.MountainId = mc.MountainId
	LEFT OUTER JOIN Mountains AS m
		ON m.Id = mc.MountainId
)

SELECT TOP(5)
   CountryName, [Highest Peak Name], [Highest Peak Elevation], Mountain
FROM CTE_AllCountriesInfo
WHERE dRank = 1
ORDER BY CountryName, [Highest Peak Name]