CREATE DATABASE Minions;

USE Minions;

CREATE TABLE Minions (
	Id INT PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL,
	Age INT
);

CREATE TABLE Towns (
	Id INT PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL
);

ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id);

INSERT INTO Towns (Id, [Name]) VALUES
(1,'Sofia'),
(2,'Plovdiv'),
(3,'Varna');

INSERT INTO Minions(Id,[Name],Age,TownId) VALUES
(1,'Kevin',22,1),
(2,'Bob',15,3),
(3,'Steward',NULL,2);

TRUNCATE TABLE Minions;

DROP TABLE Minions;
DROP TABLE Towns;

CREATE TABLE People (
	Id INT IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height DECIMAL(15,2),
	[Weight] DECIMAL(15,2),
	Gender CHAR(1) NOT NULL,
	BirthDate DATE NOT NULL,
	Biography NVARCHAR(MAX),
	CONSTRAINT PK_PeopleId PRIMARY KEY (Id),
	CONSTRAINT CK_Picture_Size CHECK (DATALENGTH(Picture) > 1024*1024*2),
	CONSTRAINT CK_Person_Gender CHECK (Gender = 'm' OR Gender = 'f')
);

INSERT INTO People VALUES
('User01',NULL,180,80,'m','1991/09/19',NULL),
('User02',NULL,143.12,42.15,'f','1988/03/14',NULL),
('User03',NULL,184.13,92.55,'m','1944/12/01',NULL),
('User04',NULL,155,47,'f','1989/01/31',NULL),
('User05',NULL,182,63,'f','1999/01/01',NULL);

CREATE TABLE Users(
	Id INT IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime DATETIME,
	IsDeleted BIT NOT NULL,
	CONSTRAINT PK_UserId PRIMARY KEY (Id),
	CONSTRAINT CK_ProfilePicture_Size CHECK (DATALENGTH(ProfilePicture) > 900000)
);

ALTER TABLE Users
ADD CONSTRAINT UQ_Username UNIQUE(Username);

INSERT INTO Users VALUES
('User91','sigurnaparola',NULL,NULL,0),
('User92','sigurnaparola1',NULL,NULL,0),
('User93','sigurnaparola5',NULL,NULL,0),
('User94','sigurnaparola7',NULL,NULL,0),
('User95','sigurnaparola9',NULL,NULL,0);

ALTER TABLE Users
DROP CONSTRAINT PK_UserId;

ALTER TABLE Users
ADD CONSTRAINT PK_ID_USERNAME PRIMARY KEY(Id,Username);

ALTER TABLE Users
ADD CONSTRAINT CK_Password_Length CHECK (DATALENGTH([Password]) >= 5)
--CHECK (LEN([Password])>=5)

ALTER TABLE Users
ADD CONSTRAINT DF_Last_Login DEFAULT GETDATE() FOR LastLoginTime

INSERT INTO Users(Username, Password, ProfilePicture,IsDeleted) VALUES
('TheNewGuy','NaiSigurnataParola',NULL,1)

ALTER TABLE Users
DROP CONSTRAINT PK_ID_USERNAME

ALTER TABLE Users
ADD CONSTRAINT PK_User_Id PRIMARY KEY(Id)

ALTER TABLE Users
ADD CONSTRAINT CK_UserName_Length CHECK (LEN(Username)>=3)

CREATE DATABASE Movies;

USE Movies;

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(300)
);

INSERT INTO Directors VALUES
('Direktor1',NULL),
('Direktor2',NULL),
('Direktor3',NULL),
('Direktor4',NULL),
('Direktor5',NULL);


CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(300)
);

INSERT INTO Genres VALUES
('Comedy',NULL),
('Horror',NULL),
('Sci-Fi',NULL),
('Thriller',NULL),
('Documentary',NULL);

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(300)
);

INSERT INTO Categories VALUES
('A',NULL),
('B',NULL),
('C',NULL),
('D',NULL),
('E',NULL);

CREATE TABLE Movies(
    Id INT IDENTITY, 
    Title NVARCHAR(150) NOT NULL, 
    DirectorId INT NOT NULL, 
    CopyrightYear INT NOT NULL, 
    [Length] INT NOT NULL,  
    GenreId INT NOT NULL, 
    CategoryId INT NOT NULL, 
    Rating NUMERIC(2, 1), 
    Notes NVARCHAR(300), 
    CONSTRAINT PK_Movie PRIMARY KEY (Id), 
    CONSTRAINT FK_Director FOREIGN KEY (DirectorId) REFERENCES Directors (Id), 
    CONSTRAINT FK_Genre FOREIGN KEY (GenreId) REFERENCES Genres (Id), 
    CONSTRAINT FK_Category FOREIGN KEY (CategoryId) REFERENCES Categories (Id), 
    CONSTRAINT CHK_Movie_Length CHECK ([Length] > 0),
    CONSTRAINT CHK_Rating_Value CHECK (Rating <= 10)
);

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes) VALUES
('ComedyCentral',1,1984,87,1,1,5,NULL),
('HorrorCentral',2,1985,88,2,2,6,NULL),
('Sci-FiCentral',3,1986,89,3,3,7,NULL),
('ThrillerCentral',4,1987,90,4,4,8,NULL),
('DocumentaryCentral',5,1988,91,5,5,9,NULL);

SELECT * FROM Movies;

CREATE DATABASE CarRental;

--Use CarRental;

CREATE TABLE Categories(
	Id INT IDENTITY,
	CategoryName NVARCHAR(30) NOT NULL,
	DailyRate DECIMAL (5,2) NOT NULL,
	WeeklyRate DECIMAL (5,2) NOT NULL,
	MonthlyRate DECIMAL (5,2) NOT NULL,
	WeekendRate DECIMAL (5,2) NOT NULL,
	CONSTRAINT PK_Category PRIMARY KEY (Id)
);

INSERT INTO Categories VALUES
('Cat1',1.00,5.00,100.34,7.32),
('Cat2',2.00,7.00,120.31,8.22),
('Cat3',6.00,60.44,177.22,14.28);

CREATE TABLE Cars(
	Id INT IDENTITY,
	PlateNumber VARCHAR(10) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	CarYear INT NOT NULL,
	CategoryId INT NOT NULL,
	Doors INT NOT NULL,
	Picture VARBINARY(MAX),
	Condition VARCHAR(4) NOT NULL,
	Available BIT NOT NULL,
	CONSTRAINT PK_Cars PRIMARY KEY (Id),
    CONSTRAINT FK_CategoryID FOREIGN KEY (CategoryId) REFERENCES Categories (Id),
	CONSTRAINT CK_Doors_Number CHECK (Doors <=5 AND Doors >=3),
	CONSTRAINT CK_Picture_Size CHECK (DATALENGTH(Picture) < 900000),
	CONSTRAINT CK_Condition CHECK (Condition = 'New' OR Condition = 'Used')
);

INSERT INTO Cars VALUES
('1337','Opel','Corsa',1993,1,5,NULL,'New',1),
('A15047','Renault','Megane',2010,2,3,NULL,'Used',0),
('CB9944KA','VW','Passat',2014,3,5,NULL,'New',1);

CREATE TABLE Employees(
	Id INT IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR (30) NOT NULL,
	Title NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(300),
	CONSTRAINT PK_Employees PRIMARY KEY (Id)
);

INSERT INTO Employees VALUES
('Mecho','Mechev','CEO',NULL),
('Doicho','Koichev','Higienist',NULL),
('Koicho','Hoichev','Higienist',NULL)

CREATE TABLE Customers(
	--Id, DriverLicenceNumber, FullName, Address, City, ZIPCode, Notes
	Id INT IDENTITY,
	DriverLicenceNumber INT NOT NULL,
	FullName NVARCHAR(60) NOT NULL,
	[Address] NVARCHAR(60),
	City NVARCHAR(60),
	ZIPCode INT,
	Notes NVARCHAR(300),
	CONSTRAINT PK_Customers PRIMARY KEY (Id)
);

INSERT INTO Customers VALUES
(1235132,'DochkoOmnia',NULL,NULL,NULL,NULL),
(1235133,'DochkoTapia',NULL,NULL,NULL,NULL),
(1235134,'DochkoOmnia-Brat',NULL,NULL,NULL,NULL);

CREATE TABLE RentalOrders(
	Id INT IDENTITY,
	EmployeeId INT NOT NULL,
	CustomerId INT NOT NULL,
	CarId INT NOT NULL,
	TankLevel DECIMAL (5,2) NOT NULL,
	KilometrageStart INT NOT NULL,
	KilometrageEnd INT NOT NULL,
	TotalKilometrage INT,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NOT NULL,
	TotalDays INT,
	RateApplied VARCHAR(30),
	TaxRate INT,
	OrderStatus NVARCHAR(30),
	Notes NVARCHAR(300)
	CONSTRAINT PK_RentalOrders PRIMARY KEY (Id),
    CONSTRAINT FK_EmployeeId FOREIGN KEY (EmployeeId) REFERENCES Employees (Id),
    CONSTRAINT FK_CustomerId FOREIGN KEY (CustomerId) REFERENCES Customers (Id),
    CONSTRAINT FK_CarId FOREIGN KEY (CarId) REFERENCES Cars (Id),
	--CONSTRAINT CK_TankLevel CHECK (TankLevel >=0 AND TankLevel<=100),
	CONSTRAINT CK_KilometrageEnd CHECK (KilometrageEnd >= KilometrageStart),
	--CONSTRAINT DF_TotalKilometrage DEFAULT (KilometrageEnd - KilometrageStart) FOR TotalKilometrage
);

INSERT INTO RentalOrders (EmployeeId,CustomerId,CarId,
 TankLevel,KilometrageStart,KilometrageEnd,StartDate,EndDate ) VALUES
(1,1,1,100.00,300,400,'2019/01/12','2019/01/14'),
(2,2,2,100.00,500,700,'2019/01/12','2019/01/14'),
(3,3,3,100.00,570,1840,'2019/01/12','2019/01/14');


--Problem 15.	Hotel Database

CREATE DATABASE Hotel;

USE Hotel;

CREATE TABLE Employees(
	Id INT IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Title NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(300),
	CONSTRAINT PK_Employees PRIMARY KEY (Id)
);

INSERT INTO Employees VALUES
('Stefan','Stefanov','Mr',NULL),
('Ivan','Ivanov','Mr',NULL),
('Ivanka','Ivanova','Mrs',NULL);

CREATE TABLE Customers(
	AccountNumber INT NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	PhoneNumber INT,
	EmergencyName NVARCHAR(30),
	EmergencyNumber NVARCHAR(30),
	Notes NVARCHAR(300),
	CONSTRAINT PK_Customers PRIMARY KEY (AccountNumber)
);

INSERT INTO Customers (AccountNumber,FirstName,LastName) VALUES
(1235123,'Georgi','Georgiev'),
(9812388,'Petkan','Strahov'),
(9876123,'Choko','Neskov');

CREATE TABLE RoomStatus(
    RoomStatus NVARCHAR(10) UNIQUE NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Status PRIMARY KEY (RoomStatus)
)

INSERT INTO RoomStatus (RoomStatus)
VALUES
	('Booked'),
    ('Occupied'),
    ('Available');

CREATE TABLE RoomTypes(
	RoomType NVARCHAR(50) UNIQUE NOT NULL,
	NOTES NVARCHAR(MAX),
	CONSTRAINT PK_Type PRIMARY KEY (RoomType)
	);

INSERT INTO RoomTypes (RoomType)
VALUES
('Single'),
('Double'),
('Suite');

CREATE TABLE BedTypes(
	BedType NVARCHAR(50) UNIQUE NOT NULL,
	NOTES NVARCHAR(MAX),
	CONSTRAINT PK_BedType PRIMARY KEY (BedType)
	)

INSERT INTO BedTypes (BedType)
VALUES
	('SINGLE'),
	('DOUBLE'),
	('KINGSIZE');

CREATE TABLE Rooms(
	RoomNumber INT IDENTITY NOT NULL,
	RoomType NVARCHAR(50) NOT NULL,
	BedType NVARCHAR(50) NOT NULL,
	Rate MONEY NOT NULL,
	RoomStatus NVARCHAR(10) NOT NULL,
	Notes NVARCHAR(MAX),
	CONSTRAINT PK_Rooms PRIMARY KEY (RoomNumber),
	CONSTRAINT FK_RoomType FOREIGN KEY (RoomType) REFERENCES RoomTypes (RoomType),
	CONSTRAINT FK_BedType FOREIGN KEY (BedType) REFERENCES BedTypes (BedType),
	CONSTRAINT FK_Status FOREIGN KEY (RoomStatus) REFERENCES RoomStatus (RoomStatus)
);

INSERT INTO Rooms (RoomType, BedType,Rate,RoomStatus)
VALUES
('SINGLE','KINGSIZE',100,'Booked'),
('Double','SINGLE',200,'Booked'),
('SINGLE','SINGLE',50,'Booked');

CREATE TABLE Payments(
    Id INT IDENTITY, 
    EmployeeId INT NOT NULL, 
    PaymentDate DATETIME NOT NULL, 
    AccountNumber INT NOT NULL, 
    FirstDateOccupied DATE NOT NULL, 
    LastDateOccupied DATE NOT NULL, 
    TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied),
    AmountCharged DECIMAL(6,2) NOT NULL, 
    TaxRate DECIMAL(6,2) NOT NULL, 
    TaxAmount DECIMAL(6,2) NOT NULL, 
    PaymentTotal AS AmountCharged + TaxRate + TaxAmount, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Payments PRIMARY KEY (Id), 
    CONSTRAINT FK_Employee FOREIGN KEY (EmployeeId) REFERENCES Employees (Id), 
    CONSTRAINT FK_AccountNumber FOREIGN KEY (AccountNumber) REFERENCES Customers (AccountNumber),
    CONSTRAINT CHK_EndDate CHECK (LastDateOccupied >= FirstDateOccupied)
)

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate, TaxAmount)
VALUES
(1, GETDATE(),1235123, CONVERT([datetime], '10-10-2010', 103), CONVERT([datetime], '12-12-2010'), 303, 20,10),
(2, GETDATE(),1235123, CONVERT([datetime], '10-10-2010', 103), CONVERT([datetime], '12-12-2010'), 303, 20,10),
(3, GETDATE(),1235123, CONVERT([datetime], '10-10-2010', 103), CONVERT([datetime], '12-12-2010'), 303, 20,10)

--SELECT * FROM Payments;

CREATE TABLE Occupancies(
    Id INT IDENTITY, 
    EmployeeId INT NOT NULL, 
    DateOccupied DATE NOT NULL, 
    AccountNumber INT NOT NULL, 
    RoomNumber INT NOT NULL, 
    RateApplied DECIMAL(6,2) NOT NULL,
    PhoneCharge DECIMAL(6,2) NOT NULL, 
    NOTES NVARCHAR(MAX),
    CONSTRAINT PK_Occupancies PRIMARY KEY (Id), 
    CONSTRAINT FK_Employees FOREIGN KEY (EmployeeId) REFERENCES Employees (Id), 
    CONSTRAINT FK_Customers FOREIGN KEY (AccountNumber) REFERENCES Customers (AccountNumber), 
    CONSTRAINT FK_RoomNumber FOREIGN KEY (RoomNumber) REFERENCES Rooms (RoomNumber),
    CONSTRAINT CHK_PhoneCharge CHECK (PhoneCharge >= 0) 
);

INSERT INTO Occupancies (EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge)
VALUES
	(1, CONVERT([datetime], '2014-02-10', 103), 1235123, 1, 70, 0),
	(2, CONVERT([datetime], '2014-02-10', 103), 1235123, 2, 70, 0),
	(3, CONVERT([datetime], '2014-02-10', 103), 1235123, 3, 70, 0);

--Problem 16.	Create SoftUni Database

--CREATE DATABASE SoftUni
--USE SoftUni

CREATE TABLE Towns(
    Id INT IDENTITY, 
    Name NVARCHAR(50) NOT NULL, 
    CONSTRAINT PK_Towns PRIMARY KEY (Id)
)

CREATE TABLE Addresses(
    Id INT IDENTITY, 
    AddressText NVARCHAR(200) NOT NULL, 
    TownId INT NOT NULL, 
    CONSTRAINT PK_Addresses PRIMARY KEY (Id),
    CONSTRAINT FK_TownId FOREIGN KEY (TownId) REFERENCES Towns(Id)
)

CREATE TABLE Departments(
    Id INT IDENTITY, 
    Name NVARCHAR(100) NOT NULL
    CONSTRAINT PK_Departments PRIMARY KEY (Id)
)

CREATE TABLE Employees(
    Id INT IDENTITY, 
    FirstName NVARCHAR(20) NOT NULL, 
    MiddleName NVARCHAR(20) NOT NULL, 
    LastName NVARCHAR(20) NOT NULL,
    JobTitle NVARCHAR(50) NOT NULL, 
    DepartmentId INT NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(7,2) NOT NULL, 
    AddressId INT NOT NULL,
    CONSTRAINT PK_Employees PRIMARY KEY (Id), 
    CONSTRAINT FK_Department FOREIGN KEY (DepartmentId) REFERENCES Departments(Id), 
    CONSTRAINT FK_Address FOREIGN KEY (AddressId) REFERENCES Addresses(Id)
)

ALTER TABLE Employees
ADD CONSTRAINT CHK_Salary CHECK (Salary > 0)

--Problem 17.	Backup Database

BACKUP DATABASE SoftUni
TO DISK = 'C:\OneDrive\Databases Basics - MS SQL Server - January 2019\softuni-backup.bak'

-- Problem 18.	Basic Insert

INSERT INTO Towns VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');

INSERT INTO Departments VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

SELECT * FROM Employees

INSERT INTO Addresses VALUES
('??. ??????? 17', 1),
('??. ??????????', 3),
('??. ?????????', 4),
('??. ????? ???????', 1)

INSERT INTO Employees VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, CONVERT([datetime], '01-02-2013',103), 3500, 1),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, CONVERT([datetime], '02-03-2014',103), 4000, 4),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, CONVERT([datetime], '28-08-2016',103), 525.25, 1), 
('Georgi', 'Terziev', 'Ivanov', 'CEO', 2, CONVERT([datetime], '09-12-2007',103), 3000, 2), 
('Peter', 'Pan', 'Pan', 'Intern', 3, CONVERT([datetime], '28-08-2016',103), 599.88, 3);

--Problem 19.	Basic Select All Fields

SELECT * FROM Towns;

SELECT * FROM Departments;

SELECT * FROM Employees;

--Problem 20.	Basic Select All Fields and Order Them

SELECT * FROM Towns
ORDER BY [Name];

SELECT * FROM Departments
ORDER BY [Name];

SELECT * FROM Employees
ORDER BY Salary DESC;

--Problem 21.	Basic Select Some Fields

SELECT [Name] FROM Towns
ORDER BY [Name];

SELECT [Name] FROM Departments
ORDER BY [Name];

SELECT FirstName,LastName,JobTitle,Salary FROM Employees
ORDER BY Salary DESC;

--Problem 22.	Increase Employees Salary

UPDATE  Employees
SET Salary *=1.1;

SELECT Salary FROM Employees;

--Problem 23.	Decrease Tax Rate

USE Hotel;

UPDATE Payments
SET TaxRate *=0.97;

SELECT TaxRate FROM Payments;

--Problem 24.	Delete All Records

USE Hotel;

SELECT * FROM Occupancies;

TRUNCATE TABLE Occupancies;

SELECT * FROM Occupancies;
