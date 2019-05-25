USE master

CREATE DATABASE ReportService

USE ReportService

EXEC sp_changedbowner 'sa'

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username NVARCHAR(30) NOT NULL UNIQUE,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50),
	Gender CHAR(1) CHECK(Gender IN ('M','F')),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	Firstname NVARCHAR(25),
	Lastname NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN ('M','F')),
	Birthdate DATETIME,
	Age INT,
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE [Status](
	Id INT PRIMARY KEY IDENTITY,
	Label VARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	StatusId INT NOT NULL FOREIGN KEY REFERENCES [Status](Id),
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] VARCHAR(200),
	UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

--2.	Insert

SELECT * FROM Departments
SELECT * FROM Employees
SELECT * FROM Reports
SELECT * FROM Categories
SELECT * FROM Status

INSERT INTO Employees (Firstname,Lastname,Gender,Birthdate,DepartmentId) VALUES
('Marlo',	'O’Malley',	'M',	'9/21/1958',	1),
('Niki',	'Stanaghan',	'F',	'11/26/1969',	4),
('Ayrton',	'Senna',	'M',	'03/21/1960', 	9),
('Ronnie',	'Peterson',	'M',	'02/14/1944',	9),
('Giovanna',	'Amati',	'F',	'07/20/1959',	5)


INSERT INTO Reports VALUES
(1,	1,	'04/13/2017', NULL,		'Stuck Road on Str.133',	6,	2),
(6,	3,	'09/05/2015',	'12/06/2015',	'Charity trail running',	3,	5),
(14,	2,	'09/07/2015', NULL,		'Falling bricks on Str.58',	5,	2),
(4,	3,	'07/03/2017',	'07/06/2017',	'Cut off streetlight on Str.11',	1,	1)


--3.	Update

UPDATE Reports
SET StatusId = 2
WHERE CategoryId = 4 AND StatusId = 1


--4.	Delete

DELETE FROM Reports
WHERE StatusId = 4

--5.	Users by Age

SELECT Username, Age
FROM Users
ORDER BY Age, Username DESC


--6.	Unassigned Reports

SELECT [Description], OpenDate 
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]


--7.	Employees & Reports

	SELECT e.Firstname, e.Lastname, r.Description, FORMAT(r.OpenDate,'yyyy-MM-dd') AS [OpenDate]
	FROM Employees AS e
	JOIN Reports AS r ON e.Id = r.EmployeeId
	ORDER BY e.Id, OpenDate, r.Id

--8.	Most reported Category

SELECT c.Name, COUNT(c.Name) AS ReportsNumber
FROM Reports AS r
JOIN Categories AS c ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, c.Name

--9.	Employees in Category

SELECT c.Name AS CategoryName, COUNT(*) AS [Employees Number]
FROM Employees AS e
JOIN Departments AS d ON d.Id = e.DepartmentId
JOIN Categories AS c ON c.DepartmentId = d.Id
GROUP BY c.Name
ORDER BY c.Name

--10.	Users per Employee 

SELECT e.Firstname + ' ' + e.Lastname AS [Name], COUNT(r.UserId) AS [Users Number]
FROM Employees AS e
LEFT JOIN Reports AS r ON r.EmployeeId = e.Id
GROUP BY e.Firstname, e.Lastname
ORDER BY [Users Number] DESC, [Name]


--11.	Emergency Patrol

SELECT r.OpenDate, r.Description, u.Email AS [Reporter Email]
FROM Reports AS r
JOIN Users AS u ON u.Id = r.UserId
JOIN Categories AS c ON c.Id = r.CategoryId
JOIN Departments AS d ON d.Id = c.DepartmentId
WHERE r.CloseDate IS NULL AND
	( LEN(r.Description) > 20 AND r.Description LIKE '%str%') AND 
	d.Name IN ('Infrastructure', 'Emergency', 'Roads Maintenance')
ORDER BY r.OpenDate, u.Email, r.Id


--12.	Birthday Report

SELECT DISTINCT c.Name AS [Category Name]
FROM Reports AS r
JOIN Users AS u ON u.Id = r.UserId
JOIN Categories AS c ON c.Id = r.CategoryId
WHERE (DATEPART(DAY,r.OpenDate) = DATEPART(DAY,u.Birthdate)) AND (DATEPART(MONTH,r.OpenDate) = DATEPART(MONTH,u.Birthdate))
ORDER BY c.Name

--13.	Numbers Coincidence

SELECT DISTINCT u.Username
FROM Users AS u
JOIN Reports AS r ON r.UserId = u.Id
WHERE ((SUBSTRING(u.Username,1,1) LIKE '[0-9]') AND CAST(r.CategoryId AS VARCHAR) = SUBSTRING(u.Username,1,1)) OR
		((SUBSTRING(u.Username,LEN(u.Username),1) LIKE '[0-9]') AND CAST(r.CategoryId AS VARCHAR) = SUBSTRING(u.Username,LEN(u.Username),1))
ORDER BY u.Username

--14.	Open/Closed Statistics

SELECT E.Firstname+' '+E.Lastname AS FullName, 
	   ISNULL(CONVERT(varchar, CC.ReportSum), '0') + '/' +        
       ISNULL(CONVERT(varchar, OC.ReportSum), '0') AS [Stats]
FROM Employees AS E
JOIN (SELECT EmployeeId,  COUNT(1) AS ReportSum
	  FROM Reports R
	  WHERE  YEAR(OpenDate) = 2016
	  GROUP BY EmployeeId) AS OC ON OC.Employeeid = E.Id
LEFT JOIN (SELECT EmployeeId,  COUNT(1) AS ReportSum
	       FROM Reports R
	       WHERE  YEAR(CloseDate) = 2016
	       GROUP BY EmployeeId) AS CC ON CC.Employeeid = E.Id
ORDER BY FullName

--15.	Average Closing Time

SELECT D.Name AS Departmentname,
       ISNULL(
	          CONVERT(
			          VARCHAR, AVG(DATEDIFF(DAY, R.Opendate, R.Closedate))
					 ), 'no info'
			 ) AS AverageTime
FROM Departments AS D
     JOIN Categories AS C ON C.DepartmentId = D.Id
     LEFT JOIN Reports AS R ON R.CategoryId = C.Id
GROUP BY D.Name
ORDER BY D.Name

--16.	Favorite Categories

SELECT Department,
       Category,
       Percentage
FROM
    (SELECT D.Name AS Department,
		    C.Name AS Category,
		    CAST(
			     ROUND(
				       COUNT(1) OVER(PARTITION BY C.Id) * 100.00 / COUNT(1) OVER(PARTITION BY D.Id), 0
					  ) as int
				) AS Percentage
     FROM Categories AS C
		  JOIN Reports AS R ON R.Categoryid = C.Id
		  JOIN Departments AS D ON D.Id = C.Departmentid) AS Stats
GROUP BY Department,
         Category,
         Percentage
ORDER BY Department,
         Category,
         Percentage;

--17.	Employee’s Load

CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT) 
RETURNS INT
AS
BEGIN
    DECLARE @num INT= (SELECT COUNT(*)
                       FROM reports
                       WHERE Employeeid = @employeeId
                             AND Statusid = @statusId);
    RETURN @num;
END;


SELECT Id,
       Firstname,
       Lastname,
       dbo.udf_GetReportsCount(Id, 2)
FROM Employees;

--18.	Assign Employee

CREATE PROCEDURE usp_AssignEmployeeToReport(@employeeId INT, @reportId INT)
AS
BEGIN
    BEGIN TRANSACTION
		DECLARE @categoryId INT= (
								 SELECT Categoryid
								 FROM Reports
								 WHERE Id = @reportId);

		DECLARE @employeeDepId INT= (
									SELECT Departmentid
									FROM Employees
									WHERE Id = @employeeId);

		DECLARE @categoryDepId INT= (
									SELECT Departmentid
									FROM Categories
									WHERE Id = @categoryId);

		UPDATE Reports
		SET EmployeeId = @employeeId
		WHERE Id = @reportId

		IF @employeeId IS NOT NULL
		   AND @categoryDepId <> @employeeDepId
		BEGIN 
			ROLLBACK;
			THROW 50013,'Employee doesn''t belong to the appropriate department!', 1;
		END;   
    COMMIT; 
END;


EXEC usp_AssignEmployeeToReport 17, 2;
SELECT EmployeeId FROM Reports WHERE id = 17


--20.	Categories Revision

SELECT c.Name,
	  COUNT(r.Id) AS ReportsNumber,
	  CASE 
	      WHEN InProgressCount > WaitingCount THEN 'in progress'
		  WHEN InProgressCount < WaitingCount THEN 'waiting'
		  ELSE 'equal'
	  END AS MainStatus
FROM Reports AS r
    JOIN Categories AS c ON c.Id = r.CategoryId
    JOIN Status AS s ON s.Id = r.StatusId
    JOIN (SELECT r.CategoryId, 
		         SUM(CASE WHEN s.Label = 'in progress' THEN 1 ELSE 0 END) as InProgressCount,
		         SUM(CASE WHEN s.Label = 'waiting' THEN 1 ELSE 0 END) as WaitingCount
		  FROM Reports AS r
		  JOIN Status AS s on s.Id = r.StatusId
		  WHERE s.Label IN ('waiting','in progress')
		  GROUP BY r.CategoryId
		 ) AS sc ON sc.CategoryId = c.Id
WHERE s.Label IN ('waiting','in progress') 
GROUP BY C.Name,
	     CASE 
		     WHEN InProgressCount > WaitingCount THEN 'in progress'
		     WHEN InProgressCount < WaitingCount THEN 'waiting'
		     ELSE 'equal'
	     END
ORDER BY C.Name, 
		 ReportsNumber, 
		 MainStatus;

