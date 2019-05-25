EXEC sp_changedbowner 'sa'

--Problem 1. Employees with Salary Above 35000

USE SoftUni

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
  SELECT FirstName, LastName 
  FROM Employees
  WHERE Salary > 35000
GO

EXECUTE dbo.usp_GetEmployeesSalaryAbove35000


--Problem 2. Employees with Salary Above Number

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@SalaryToCompare DECIMAL(18,4))
AS
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary >= @SalaryToCompare
	
EXECUTE dbo.usp_GetEmployeesSalaryAboveNumber 48100

--Problem 3. Town Names Starting With

CREATE PROCEDURE usp_GetTownsStartingWith (@TownsStartingWith nvarchar(50))
AS
	SELECT [Name] AS Town
	FROM Towns
	WHERE [Name] LIKE (@TownsStartingWith +'%')

EXECUTE dbo.usp_GetTownsStartingWith 'b'

--Problem 4. Employees from Town

CREATE PROCEDURE usp_GetEmployeesFromTown (@TownName nvarchar(50))
AS
	SELECT e.FirstName, e.LastName
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON t.TownID = a.TownID
	WHERE t.[Name] = @TownName

EXECUTE dbo.usp_GetEmployeesFromTown 'Sofia'

--Problem 5. Salary Level Function

CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @SalaryLevel NVARCHAR(10)
	IF(@Salary < 30000)
		SET @SalaryLevel = 'Low'
	ELSE IF(@Salary >= 30000 AND @Salary <=50000)
		SET @SalaryLevel = 'Average'
	ELSE
		SET @SalaryLevel = 'High'
	RETURN @SalaryLevel
END

SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
FROM Employees


--Problem 6. Employees by Salary Level

CREATE PROCEDURE usp_EmployeesBySalaryLevel(@SalaryLevel nvarchar(10))
AS
	SELECT FirstSelect.FirstName, FirstSelect.LastName FROM
		(SELECT FirstName, LastName, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
		FROM Employees) AS FirstSelect
		WHERE FirstSelect.[Salary Level] = @SalaryLevel

EXECUTE usp_EmployeesBySalaryLevel 'High'

--Problem 7. Define Function

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(50), @word NVARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @isComprised BIT = 0;
	DECLARE @currentIndex INT = 1;
	DECLARE @currentChar CHAR;

	WHILE(@currentIndex <= LEN(@word))
	BEGIN

		SET @currentChar = SUBSTRING(@word, @currentIndex,1);
		IF(CHARINDEX(@currentChar,@setOfLetters) = 0)
			RETURN @isComprised;
		SET @currentIndex += 1;

	END

	RETURN @isComprised + 1;

END
SELECT dbo.ufn_IsWordComprised ('bo', 'bobboooa')

--Problem 8. * Delete Employees and Departments

USE SoftUni

BACKUP DATABASE SoftUni
TO DISK = 'C:\Users\StefanLB\Downloads\testDB.bak'

CREATE PROCEDURE usp_DeleteEmployeesFromDepartment(@departmentId INT) 
AS 
BEGIN 
	ALTER TABLE EmployeesProjects NOCHECK CONSTRAINT ALL
	ALTER TABLE Departments NOCHECK CONSTRAINT ALL
	ALTER TABLE Employees NOCHECK CONSTRAINT ALL

	DELETE 
	FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE 
	FROM Departments 
	WHERE DepartmentID = @departmentId

	ALTER TABLE EmployeesProjects CHECK CONSTRAINT ALL 
	ALTER TABLE Departments CHECK CONSTRAINT ALL
	ALTER TABLE Employees CHECK CONSTRAINT ALL

	SELECT COUNT(*) 
	FROM Employees AS e
	WHERE e.DepartmentID = @departmentId
END

--Testing
EXECUTE dbo.usp_DeleteEmployeesFromDepartment 10
RESTORE DATABASE SoftUni
FROM DISK = 'C:\Users\StefanLB\Downloads\testDB.bak' 
GO

--Problem 9. Find Full Name

USE BankDBProgrammability

EXEC sp_changedbowner 'sa'

SELECT * FROM 

CREATE PROCEDURE usp_GetHoldersFullName
AS
BEGIN
	SELECT ah.FirstName + ' ' + ah.LastName AS [Full Name] 
	FROM AccountHolders AS ah
END

EXECUTE dbo.usp_GetHoldersFullName

--Problem 10. People with Balance Higher Than

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan(@amount DECIMAL(16,2))
AS
BEGIN

	SELECT ah.FirstName, ah.LastName
	FROM AccountHolders AS ah
	JOIN Accounts AS a
	ON a.AccountHolderId = ah.Id
	GROUP BY a.AccountHolderId, ah.FirstName, ah.LastName
	HAVING SUM(a.Balance) > @amount
	ORDER BY ah.FirstName, ah.LastName

END

EXECUTE usp_GetHoldersWithBalanceHigherThan 5000

--Problem 11. Future Value Function

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL (16,2),@yearlyInterest FLOAT, @numberOfYears INT)
RETURNS DECIMAL (16,4)
AS
BEGIN
	DECLARE @result DECIMAL(16,4);

	SET @result = @sum*POWER((1+@yearlyInterest),@numberOfYears);

	RETURN @result;

END

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

--Problem 12. Calculating Interest

CREATE PROCEDURE usp_CalculateFutureValueForAccount(@accId INT, @yearlyInterest FLOAT)
AS
BEGIN

	SELECT TOP(1) a.AccountHolderId, ah.FirstName, ah.LastName
	,a.Balance AS CurrentBalance
	,dbo.ufn_CalculateFutureValue(a.Balance,@yearlyInterest,5) AS [Balance in 5 years]
	FROM AccountHolders AS ah
	JOIN Accounts AS a
	ON a.AccountHolderId = ah.Id
	WHERE ah.Id = @accID

END

EXECUTE usp_CalculateFutureValueForAccount 1,0.1

--Problem 13. *Scalar Function: Cash in User Games Odd Rows

USE Diablo

EXEC sp_changedbowner 'sa'

SELECT * FROM UsersGames
SELECT * FROM Games

CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN	(SELECT SUM(fQuery.Cash) AS SumCash
		FROM
			(
			SELECT
			ug.Cash AS Cash,
			ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS [Row Number]
			FROM UsersGames AS ug
			JOIN Games AS g
			ON g.Id = ug.GameId
			WHERE g.[Name] = @gameName
			)
			AS fQuery
		WHERE fQuery.[Row Number] % 2 = 1)
	
SELECT * FROM dbo.ufn_CashInUsersGames('Love in a mist')


--Problem 14. Create Table Logs

USE BankDBProgrammability

CREATE TABLE Logs
(
LogId INT PRIMARY KEY IDENTITY,
AccountId INT NOT NULL,
OldSum DECIMAL(16,2) NOT NULL,
NewSum DECIMAL (16,2) NOT NULL
)

ALTER TABLE Logs
ADD CONSTRAINT FK_Logs_Accounts FOREIGN KEY (AccountID) REFERENCES Accounts(Id)

SELECT * FROM Accounts

CREATE TRIGGER tr_ChangeBalance ON Accounts AFTER UPDATE
AS
BEGIN
	INSERT INTO Logs
	SELECT inserted.Id, deleted.Balance, inserted.Balance
	FROM inserted
	JOIN deleted
	ON inserted.Id = deleted.Id
END

UPDATE Accounts 
SET Balance += 555
WHERE Id = 2

SELECT * FROM Logs

--Problem 15. Create Table Emails

CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT NOT NULL,
	[Subject] NVARCHAR(MAX) NOT NULL,
	Body NVARCHAR(MAX) NOT NULL
)

CREATE TRIGGER tr_EmailsNewRecords ON Logs AFTER INSERT
AS
BEGIN

	INSERT INTO NotificationEmails
	SELECT inserted.AccountId,
	CONCAT('Balance change for account: ', inserted.AccountId),
	CONCAT('On ', GETDATE(), ' your balance was changed from ', inserted.OldSum, ' to ', inserted.NewSum)
	FROM inserted

END

--DROP TRIGGER tr_EmailsNewRecords

UPDATE Accounts 
SET Balance += 177
WHERE Id = 1

SELECT * FROM Logs
SELECT * FROM NotificationEmails

--Problem 16. Deposit Money

CREATE PROCEDURE usp_DepositMoney(@accountID INT, @moneyAmount DECIMAL (16,4))
AS
BEGIN
	BEGIN TRANSACTION 

	UPDATE Accounts
	SET Balance += @moneyAmount
	WHERE Id = @accountID
	
	IF @moneyAmount < 0
	BEGIN
		ROLLBACK; 
		RETURN;  
	END
		COMMIT
END

EXECUTE dbo.usp_DepositMoney 1, 100000
SELECT * FROM Accounts
GO

--Problem 17. Withdraw Money

CREATE PROCEDURE usp_WithdrawMoney (@accountId INT, @moneyAmount DECIMAL (16,4)) 
AS
BEGIN
	BEGIN TRANSACTION

	UPDATE Accounts
	SET Balance -= @moneyAmount
	WHERE Id = @accountId

	IF @moneyAmount <0
	BEGIN
		ROLLBACK;
		RETURN;
	END
		COMMIT
END

EXECUTE dbo.usp_WithdrawMoney 1, 50000
SELECT * FROM Accounts

--Problem 18. Money Transfer

CREATE PROCEDURE usp_TransferMoney(@senderId INT, @receiverId INT, @amount DECIMAL (16,4))
AS
BEGIN
	BEGIN TRANSACTION
	EXECUTE dbo.usp_DepositMoney @receiverId, @amount
	EXECUTE dbo.usp_WithdrawMoney @senderId, @amount
	COMMIT
END

--DROP PROCEDURE dbo.usp_TransferMoney

EXECUTE dbo.usp_TransferMoney 1, 2, 10000
SELECT * FROM Accounts

--Problem 19. Trigger

--BACKUP DATABASE Diablo
--TO DISK = 'C:\Users\StefanLB\Downloads\diablo.bak'

CREATE TRIGGER tr_BuyItem ON UserGameItems AFTER INSERT
AS
BEGIN
	DECLARE @userLevel INT; 
	DECLARE @itemLevel INT;  

	SET @userLevel = (SELECT ug.[Level] 
	FROM inserted
	JOIN UsersGames AS ug
	ON ug.Id = inserted.UserGameId)

	SET @itemLevel = (SELECT i.MinLevel
	FROM inserted
	JOIN Items AS i
	ON i.Id = inserted.ItemId)

	IF(@userLevel < @itemLevel)
	BEGIN 
		RAISERROR('User can not buy this item!', 16, 1);
		ROLLBACK;
		RETURN;  
	END
END 

INSERT INTO UserGameItems
VALUES 
(4, 1)

UPDATE UsersGames
SET Cash += 50000
FROM UsersGames AS ug
JOIN Users AS u
ON u.Id = ug.UserId
JOIN Games AS g
ON g.Id = ug.GameId
WHERE g.Name = 'Bali' 
AND u.Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
GO

CREATE PROCEDURE udp_BuyItems(@username NVARCHAR(MAX))
AS 
BEGIN 
	DECLARE @counter INT = 251;
	DECLARE @userId INT = (SELECT u.Id FROM Users AS u WHERE u.Username = @username);
	
	WHILE(@counter <= 539)
	BEGIN 
		DECLARE @itemValue DECIMAL(16,2) = (SELECT TOP(1) i.Price FROM Items AS i WHERE i.Id = @counter);
		DECLARE @UserCash DECIMAL(16,2) = (SELECT TOP(1) u.Cash FROM UsersGames AS u WHERE u.UserId = @userId);

		IF(@itemValue <= @UserCash)
		BEGIN 
			INSERT INTO UserGameItems 
			VALUES 
			(@counter, @userId)

			UPDATE UsersGames
			SET Cash -= @itemValue
			WHERE UserId = @userId
		END

		SET @counter += 1; 
		IF(@counter = 300)
		BEGIN
			SET @counter = 501; 
		END
	END
END

--DROP PROCEDURE udp_BuyItems

EXECUTE udp_BuyItems 'baleremuda'
EXECUTE udp_BuyItems 'loosenoise'
EXECUTE udp_BuyItems 'inguinalself'
EXECUTE udp_BuyItems 'buildingdeltoid'
EXECUTE udp_BuyItems 'monoxidecos'

SELECT * FROM UsersGames
WHERE Cash > 50000

--Problem 20. *Massive Shopping



DECLARE @gameId INT = (SELECT Id FROM Games AS g WHERE g.[Name] = 'Safflower'); 
DECLARE @userId INT = (SELECT u.Id FROM Users AS u WHERE u.Username = 'Stamat');	
DECLARE @userGameId INT = (SELECT ug.Id FROM UsersGames AS ug WHERE ug.GameId = @gameId AND ug.UserId = @userId);
DECLARE @userCash DECIMAL(15, 2) = (SELECT ug.Cash FROM UsersGames AS ug WHERE ug.Id = @userGameId);  
DECLARE @itemsPricesSummed DECIMAL(15, 2) = (SELECT SUM(i.Price) FROM Items AS i WHERE i.MinLevel BETWEEN 11 AND 12); 

IF(@userCash >= @itemsPricesSummed)
BEGIN
	BEGIN TRANSACTION
		INSERT UserGameItems
		SELECT i.Id, @UserGameId
		FROM Items AS i
		WHERE i.MinLevel BETWEEN 11 AND 12

		UPDATE UsersGames 
		SET Cash -= @itemsPricesSummed
		WHERE Id = @UserGameId 
	COMMIT
END

SET @itemsPricesSummed = (SELECT SUM(i.Price) FROM Items AS i WHERE i.MinLevel BETWEEN 19 AND 21); 
SET @UserCash = (SELECT ug.Cash FROM UsersGames AS ug WHERE ug.Id = @UserGameId);  

IF(@UserCash >= @itemsPricesSummed)
BEGIN 	
	BEGIN TRANSACTION
		INSERT UserGameItems
		SELECT i.Id, @UserGameId
		FROM Items AS i
		WHERE i.MinLevel BETWEEN 19 AND 21

		UPDATE UsersGames 
		SET Cash -= @itemsPricesSummed
		WHERE Id = @UserGameId 
	COMMIT TRANSACTION 
END

SELECT i.[Name] 
FROM UsersGames AS ug
JOIN Users AS u
ON u.Id = ug.UserId
JOIN Games AS g
ON g.Id = ug.GameId
JOIN UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
JOIN Items AS i
ON i.Id = ugi.ItemId
WHERE (u.Username = 'Stamat' 
AND g.[Name] = 'Safflower')
ORDER BY i.[Name]


--Problem 21. Employees with Three Projects

SELECT * FROM Employees
SELECT * FROM Projects
SELECT * FROM EmployeesProjects

CREATE PROCEDURE usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN 
	DECLARE @maxProjectsAllowed INT = 3; 
	DECLARE @currentProjects INT;

	SET @currentProjects = 
	(SELECT COUNT(*) 
	FROM Employees AS e
	JOIN EmployeesProjects AS ep
	ON ep.EmployeeID = e.EmployeeID
	WHERE ep.EmployeeID = @emloyeeId)

BEGIN TRANSACTION 	
	IF(@currentProjects >= @maxProjectsAllowed)
	BEGIN 
		RAISERROR('The employee has too many projects!', 16, 1);
		ROLLBACK;
		RETURN;
	END

	INSERT INTO EmployeesProjects
	VALUES
	(@emloyeeId, @projectID)

COMMIT	
END 


--Problem 22. Delete Employees

CREATE TABLE Deleted_Employees
(
	EmployeeId INT NOT NULL IDENTITY, 
	FirstName NVARCHAR(64) NOT NULL, 
	LastName NVARCHAR(64) NOT NULL, 
	MiddleName NVARCHAR(64), 
	JobTitle NVARCHAR(64) NOT NULL, 
	DepartmentID INT NOT NULL, 
	Salary DECIMAL(15, 2) NOT NULL

	CONSTRAINT PK_Deleted_Emp
	PRIMARY KEY (EmployeeId), 

	CONSTRAINT FK_DeletedEmp_Departments
	FOREIGN KEY (DepartmentID)
	REFERENCES Departments(DepartmentID)
)
GO

CREATE TRIGGER tr_DeletedEmp 
ON Employees 
AFTER DELETE 
AS
	INSERT INTO Deleted_Employees
	SELECT 	
		d.FirstName, 
		d.LastName, 
		d.MiddleName, 
		d.JobTitle, 
		d.DepartmentID, 
		d.Salary
	FROM deleted as d