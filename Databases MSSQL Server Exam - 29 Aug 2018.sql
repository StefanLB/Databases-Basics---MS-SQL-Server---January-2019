CREATE DATABASE Supermarket

USE Supermarket

EXEC sp_changedbowner 'sa'

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Items(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	Price DECIMAL(15,2) NOT NULL,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id)
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL,
	Salary DECIMAL(15,2) NOT NULL
)

CREATE TABLE Orders(
	Id INT PRIMARY KEY IDENTITY,
	[DateTime] DATETIME NOT NULL,
	EmployeeId INT NOT NULL FOREIGN KEY REFERENCES Employees(Id)
)

CREATE TABLE OrderItems(
	OrderId INT NOT NULL FOREIGN KEY REFERENCES Orders(Id),
	ItemId INT NOT NULL FOREIGN KEY REFERENCES Items(Id),
	Quantity INT NOT NULL CHECK(Quantity>=1)

	CONSTRAINT PK_OrderItems PRIMARY KEY (OrderId, ItemId)
)

CREATE TABLE Shifts(
	Id INT NOT NULL UNIQUE IDENTITY,
	EmployeeId INT NOT NULL FOREIGN KEY REFERENCES Employees(Id),
	CheckIn DATETIME NOT NULL,
	CheckOut DATETIME NOT NULL,
	CHECK(CheckOut>CheckIn),
	CONSTRAINT PK_Id_EmpID PRIMARY KEY (Id,EmployeeId)
)

--2. Insert

INSERT INTO Employees VALUES
('Stoyan',	'Petrov',	'888-785-8573',	500.25),
('Stamat',	'Nikolov',	'789-613-1122',	999995.25),
('Evgeni',	'Petkov',	'645-369-9517',	1234.51),
('Krasimir',	'Vidolov',	'321-471-9982',	50.25)

INSERT INTO Items VALUES
('Tesla battery',	154.25,	8),
('Chess',	30.25,	8),
('Juice',	5.32,	1),
('Glasses',	10,	8),
('Bottle of water',	1,	1)


--3. Update

UPDATE Items
SET Price *= 1.27
WHERE CategoryId IN (1,2,3)

--4. Delete

DELETE FROM OrderItems
WHERE OrderId = 48

--5. Richest People

SELECT Id, FirstName FROM
Employees
WHERE Salary > 6500
ORDER BY FirstName, Id

--6. Cool Phone Numbers

SELECT FirstName + ' ' + LastName AS FullName, Phone
FROM Employees
WHERE Phone LIKE '3%'
ORDER BY FirstName, Phone DESC

--7. Employee Statistics

SELECT e.FirstName, e.LastName, COUNT(o.Id) AS [Count]
FROM Orders AS o
JOIN Employees AS e ON e.Id = o.EmployeeId
GROUP BY e.FirstName, e.LastName
ORDER BY [Count] DESC, e.FirstName

--08. Hard Workers Club 

SELECT e.FirstName, e.LastName, AVG(DATEDIFF(HOUR,s.CheckIn, s.CheckOut)) AS [Work hours]
FROM Employees AS e
JOIN Shifts AS s ON e.Id = s.EmployeeId
GROUP BY e.FirstName, e.LastName, e.Id
HAVING AVG(DATEDIFF(HOUR,s.CheckIn, s.CheckOut)) > 7
ORDER BY [Work hours] DESC, e.Id

--09. The Most Expensive Order

SELECT TOP(1) o.Id AS OrderId, SUM(oi.Quantity*i.Price) AS [TotalPrice]
FROM Orders AS o
JOIN OrderItems AS oi ON o.Id = oi.OrderId
JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY o.Id
ORDER BY TotalPrice DESC


--10. Rich Item, Poor Item

SELECT TOP(10) o.Id, MAX(i.Price) AS ExpensivePrice, MIN(i.Price) AS CheapPrice
FROM Orders AS o
JOIN OrderItems AS oi ON o.Id = oi.OrderId
JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY o.Id
ORDER BY ExpensivePrice DESC, o.Id


--11. Cashiers

SELECT DISTINCT e.Id, e.FirstName, e.LastName
FROM Employees AS e
JOIN Orders AS o ON o.EmployeeId = e.Id
ORDER BY e.Id


--12. Lazy Employees

WITH CTE AS (
SELECT e.Id, FirstName + ' ' + LastName AS [Full Name], MIN(DATEDIFF(HOUR,s.CheckIn,s.CheckOut)) AS WorkHours
FROM Employees AS e
JOIN Shifts AS s ON e.Id = s.EmployeeId
GROUP BY e.Id, e.FirstName, e.LastName)

SELECT Id, [Full Name] FROM CTE
WHERE WorkHours < 4
ORDER BY Id

--13. Sellers

SELECT TOP(10) (e.FirstName + ' ' + e.LastName) AS [Full Name], SUM(oi.Quantity*i.Price) AS [Total Price], SUM(oi.Quantity) AS [Items]
FROM Employees AS e
JOIN Orders AS o ON e.Id = o.EmployeeId
JOIN OrderItems AS oi ON oi.OrderId = o.Id
JOIN Items AS i ON i.Id = oi.ItemId
WHERE o.[DateTime] < '2018-06-15'
GROUP BY e.FirstName, e.LastName
ORDER BY [Total Price] DESC, [Items] DESC

--14. Tough Days 

SELECT e.FirstName + ' ' + e.LastName AS [Full Name], DATENAME(WEEKDAY,s.CheckIn) AS [Day of week]
FROM Employees AS e
LEFT JOIN Orders AS o ON o.EmployeeId = e.Id
JOIN Shifts AS s ON s.EmployeeId = e.Id
WHERE DATEDIFF(HOUR,s.CheckIn,s.CheckOut) > 12 AND o.Id IS NULL
ORDER BY e.Id

-- 15. Top Order per Employee

SELECT emp.FirstName + ' ' + emp.LastName AS FullName, DATEDIFF(HOUR, s.CheckIn, s.CheckOut) AS WorkHours, e.TotalPrice AS TotalPrice FROM 
 (
    SELECT o.EmployeeId, SUM(oi.Quantity * i.Price) AS TotalPrice, o.DateTime,
	ROW_NUMBER() OVER (PARTITION BY o.EmployeeId ORDER BY o.EmployeeId, SUM(i.Price * oi.Quantity) DESC ) AS Rank
    FROM Orders AS o
    JOIN OrderItems AS oi ON oi.OrderId = o.Id
    JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY o.EmployeeId, o.Id, o.DateTime
) AS e 
JOIN Employees AS emp ON emp.Id = e.EmployeeId
JOIN Shifts AS s ON s.EmployeeId = e.EmployeeId
WHERE e.Rank = 1 AND e.DateTime BETWEEN s.CheckIn AND s.CheckOut
ORDER BY FullName, WorkHours DESC, TotalPrice DESC

--16. Average Profit per Day

SELECT
DATEPART(DAY, o.DateTime)  AS [DayOfMonth],
CAST(AVG(i.Price * oi.Quantity)  AS decimal(15, 2)) AS TotalPrice
FROM Orders AS o
JOIN OrderItems AS oi ON oi.OrderId = o.Id
JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY DATEPART(DAY, o.DateTime)
ORDER BY DayOfMonth ASC

--17. Top Products 

SELECT i.Name, c.Name, SUM(oi.Quantity) AS [Count], SUM(oi.Quantity*i.Price) AS [TotalPrice]
FROM Categories AS c
JOIN Items AS i ON i.CategoryId = c.Id
LEFT JOIN OrderItems AS oi ON i.Id = oi.ItemId
GROUP BY i.Name, c.Name
ORDER BY TotalPrice DESC

--18. Promotion Days 

CREATE FUNCTION udf_GetPromotedProducts(@CurrentDate DATE,
 @StartDate DATE, @EndDate DATE, @Discount INT, @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
		DECLARE @FirstId INT = (SELECT TOP(1) i.Id FROM Items AS i WHERE i.Id = @FirstItemId)
		DECLARE @SecondId INT = (SELECT TOP(1) i.Id FROM Items AS i WHERE i.Id = @SecondItemId)
		DECLARE @ThirdId INT = (SELECT TOP(1) i.Id FROM Items AS i WHERE i.Id = @ThirdItemId)

	IF((@FirstId IS NULL) OR (@SecondId IS NULL) OR (@ThirdId IS NULL))
		BEGIN 
			RETURN 'One of the items does not exists!'
		END

	IF(@CurrentDate NOT BETWEEN @StartDate AND @EndDate)
		BEGIN
			RETURN 'The current date is not within the promotion dates!'
		END

		DECLARE @FirstItemName NVARCHAR(50) = (SELECT TOP(1) i.Name FROM Items AS i WHERE i.Id = @FirstItemId)
		DECLARE @SecondItemName NVARCHAR(50) = (SELECT TOP(1) i.Name FROM Items AS i WHERE i.Id = @SecondItemId)
		DECLARE @ThirdItemName NVARCHAR(50) = (SELECT TOP(1) i.Name FROM Items AS i WHERE i.Id = @ThirdItemId)

		DECLARE @FirstItemPrice DECIMAL(15,2) = (SELECT TOP(1) CAST((i.Price*(1.00 - @Discount/100.00)) AS DECIMAL(15,2)) FROM Items AS i WHERE i.Id = @FirstItemId)
		DECLARE @SecondItemPrice DECIMAL(15,2) = (SELECT TOP(1) CAST((i.Price*(1.00 - @Discount/100.00)) AS DECIMAL(15,2)) FROM Items AS i WHERE i.Id = @SecondItemId)
		DECLARE @ThridItemPrice DECIMAL(15,2) = (SELECT TOP(1) CAST((i.Price*(1.00 - @Discount/100.00)) AS DECIMAL(15,2)) FROM Items AS i WHERE i.Id = @ThirdItemId)

		RETURN @FirstItemName + ' price: ' + CAST(ROUND(@FirstItemPrice,2) as varchar) + ' <-> ' +
			   @SecondItemName + ' price: ' + CAST(ROUND(@SecondItemPrice,2) as varchar)+ ' <-> ' +
			   @ThirdItemName + ' price: ' + CAST(ROUND(@ThridItemPrice,2) as varchar)
END

DROP FUNCTION dbo.udf_GetPromotedProducts

SELECT dbo.udf_GetPromotedProducts('2018-08-02', '2018-08-01', '2018-08-03',13, 3,4,5)

--19. Cancel Order 

CREATE PROCEDURE usp_CancelOrder(@OrderId INT, @CancelDate DATETIME)
AS
BEGIN
	DECLARE @order INT = (SELECT Id FROM Orders WHERE Id = @OrderId)

	IF (@order IS NULL)
	BEGIN
		;THROW 51000, 'The order does not exist!', 1
	END

	DECLARE @OrderDate DATETIME = (SELECT [DateTime] FROM Orders WHERE Id = @OrderId)
	DECLARE @DateDiff INT = (SELECT DATEDIFF(DAY, @OrderDate, @CancelDate))

	IF (@DateDiff > 3)
	BEGIN
		;THROW 51000, 'You cannot cancel the order!', 2
	END

	DELETE FROM OrderItems
	WHERE OrderId = @OrderId

	DELETE FROM Orders
	WHERE Id = @OrderId
END


--20. Deleted Orders 

CREATE TABLE DeletedOrders
(
	OrderId INT,
	ItemId INT,
	ItemQuantity INT
)

CREATE TRIGGER t_DeleteOrders
    ON OrderItems AFTER DELETE
    AS
    BEGIN
	  INSERT INTO DeletedOrders (OrderId, ItemId, ItemQuantity)
	  SELECT d.OrderId, d.ItemId, d.Quantity
	    FROM deleted AS d
    END
