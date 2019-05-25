--Problem 1.	Records’ Count

USE Gringotts

SELECT COUNT(*) AS [Count] FROM WizzardDeposits

--Problem 2.	Longest Magic Wand

SELECT * FROM WizzardDeposits

SELECT MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits

--Problem 3.	Longest Magic Wand per Deposit Groups

SELECT * FROM WizzardDeposits

SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand 
FROM WizzardDeposits
GROUP BY DepositGroup

--Problem 4.	* Smallest Deposit Group per Magic Wand Size

SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--Problem 5.	Deposits Sum

SELECT * FROM WizzardDeposits

SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup

--Problem 6.	Deposits Sum for Ollivander Family

SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

--Problem 7.	Deposits Filter

SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--Problem 8.	 Deposit Charge

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge	
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup


--Problem 9.	Age Groups

SELECT AgeGroupTable.AgeGroup, COUNT(AgeGroupTable.AgeGroup)
FROM(
SELECT
CASE
	WHEN Age <= 10 THEN '[0-10]'
	WHEN Age >= 11 AND  Age <=20 THEN '[11-20]'
	WHEN Age >= 21 AND  Age <=30 THEN '[21-30]'
	WHEN Age >= 31 AND  Age <=40 THEN '[31-40]'
	WHEN Age >= 41 AND  Age <=50 THEN '[41-50]'
	WHEN Age >= 51 AND  Age <=60 THEN '[51-60]'
	WHEN Age >= 61 THEN '[61+]'
	END AS AgeGroup
FROM WizzardDeposits) AS AgeGroupTable
GROUP BY AgeGroupTable.AgeGroup

--Problem 10.	First Letter

SELECT LEFT(FirstName,1)
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName,1)

--Problem 11.	Average Interest 

SELECT * FROM WizzardDeposits

SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS [AverageInterest]
FROM WizzardDeposits
WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired


--Problem 12.	* Rich Wizard, Poor Wizard

SELECT SUM(k.Diff) AS SumDifference
FROM (
SELECT wd.DepositAmount - (SELECT w.DepositAmount FROM WizzardDeposits AS w WHERE w.Id = wd.Id+1) AS Diff
FROM WizzardDeposits AS wd ) AS k


SELECT SUM(k.SumDiff) AS SumDifference
FROM (
SELECT DepositAmount - LEAD(DepositAmount,1) OVER (ORDER BY Id) AS SumDiff
FROM WizzardDeposits) AS k

--Problem 13.	Departments Total Salaries

USE SoftUni

SELECT * FROM Employees

SELECT DepartmentID, SUM(Salary) AS TotalSalary FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--Problem 14.	Employees Minimum Salaries

SELECT DepartmentID, MIN(Salary) AS MinimumSalary FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '01-01-2000'
GROUP BY DepartmentID

--Problem 15.	Employees Average Salaries

SELECT * INTO NewEmployeeTable
FROM Employees
WHERE Salary > 30000

DELETE FROM NewEmployeeTable
WHERE ManagerID = 42

UPDATE NewEmployeeTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary)
FROM NewEmployeeTable
GROUP BY DepartmentID

--Problem 16.	Employees Maximum Salaries

SELECT DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--Problem 17.	Employees Count Salaries

SELECT COUNT(EmployeeID) AS [Count]
FROM Employees
WHERE ManagerID IS NULL


--Problem 18.	*3rd Highest Salary

SELECT * FROM Employees

SELECT DISTINCT k.DepartmentID, k.Salary
FROM(
SELECT DepartmentID, Salary, DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
FROM Employees) AS k
WHERE SalaryRank = 3

---Problem 19.	**Salary Challenge

SELECT TOP(10) FirstName, LastName, DepartmentID
FROM Employees AS e
WHERE Salary > (SELECT AVG(Salary) FROM Employees AS em WHERE em.DepartmentID = e.DepartmentID)


