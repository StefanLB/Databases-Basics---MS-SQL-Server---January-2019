USE master

CREATE DATABASE TableRelationsExercises

USE TableRelationsExercises

EXEC sp_changedbowner 'sa'

--Problem 1.	One-To-One Relationship

CREATE TABLE Persons(
	PersonID INT,
	FirstName NVARCHAR(50),
	Salary DECIMAL,
	PassportID INT
)

CREATE TABLE Passports(
	PassportID INT,
	PassportNumber NVARCHAR(8)
)

INSERT INTO Persons VALUES
(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3, 'Yana', 60200.00, 101)

INSERT INTO Passports VALUES
(101,'N34FG21B'),
(102,'K65LO4R7'),
(103,'ZE657QP2')

ALTER TABLE Persons
ALTER COLUMN PersonID INT NOT NULL

ALTER TABLE Persons
ALTER COLUMN PassportID INT NOT NULL

ALTER TABLE Passports
ALTER COLUMN PassportID INT NOT NULL

ALTER TABLE Passports
ADD CONSTRAINT PK_Passports PRIMARY KEY (PassportID)

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons PRIMARY KEY (PersonID),
	CONSTRAINT FK_Persons_Passports FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)


--Problem 2.	One-To-Many Relationship

CREATE TABLE Models(
	ModelID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManufacturerID INT NOT NULL
)

CREATE TABLE Manufacturers(
	ManufacturerID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	EstablishedOn DATE NOT NULL
)

INSERT INTO Models VALUES
(101,'X1',1),
(102,'i6',1),
(103,'Model S',2),
(104,'Model X',2),
(105,'Model 3',3),
(106,'Nova',3)


INSERT INTO Manufacturers VALUES
(1,'BMW','07/03/1916'),
(2,'Tesla','01/01/2003'),
(3,'Lada','01/05/1966')

ALTER TABLE Manufacturers
ADD CONSTRAINT PK_Manufacturers PRIMARY KEY (ManufacturerID)


ALTER TABLE Models
ADD CONSTRAINT PK_Models PRIMARY KEY (ModelID),
	CONSTRAINT FK_Models_Manufacturers FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)


--Problem 3.	Many-To-Many Relationship

CREATE TABLE Students(
	StudentID INT NOT NULL PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Exams(
	ExamID INT NOT NULL PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentID INT NOT NULL,
	ExamID INT NOT NULL,
	CONSTRAINT PK_Studensts_Exams PRIMARY KEY (StudentID,ExamID)
)

INSERT INTO Students VALUES
(1,'Mila'),
(2,'Toni'),
(3,'Ron')

INSERT INTO Exams VALUES
(101,'SpringMVC'),
(102,'Neo4j'),
(103,'Oracle 11g')

INSERT INTO StudentsExams VALUES
(1,	102),
(2,	101),
(1,	101),
(3,	103),
(2,	102),
(2,	103)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
	CONSTRAINT FK_StudentsExams_Exams FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)

--Problem 4.	Self-Referencing 

CREATE TABLE Teachers(
	TeacherID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManagerID INT NOT NULL
)

ALTER TABLE Teachers
ALTER COLUMN ManagerID INT

INSERT INTO Teachers VALUES
(101,'John',NULL),
(102,'Maya',106),
(103,'Silvia',	106),
(104,'Ted',105),
(105,'Mark',101),
(106,'Greta',101)

ALTER TABLE Teachers
ADD CONSTRAINT PK_Teachers PRIMARY KEY (TeacherID),
	CONSTRAINT FK_Teachers_Teachers FOREIGN KEY (ManagerID) REFERENCES Teachers(TeacherID)


--Problem 5.	Online Store Database

USE master

CREATE DATABASE OnlineStoreDatabase

USE OnlineStoreDatabase

EXEC sp_changedbowner 'sa'

CREATE TABLE Cities(
	CityID INT NOT NULL PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Customers(
	CustomerID INT NOT NULL PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	Birthday DATE,
	CityID INT NOT NULL,
	CONSTRAINT FK_Customers_Cities FOREIGN KEY (CityID) REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
	OrderID INT NOT NULL PRIMARY KEY,
	CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes(
	ItemTypeID INT NOT NULL PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Items(
	ItemID INT NOT NULL PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT NOT NULL FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems(
	OrderID INT NOT NULL,
	ItemID INT NOT NULL,
	CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID,ItemID),
	CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
	CONSTRAINT FK_OrderItems_Items FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
)


--Problem 6.	University Database

USE master

CREATE DATABASE UniversityDatabase

USE UniversityDatabase

EXEC sp_changedbowner 'sa'

CREATE TABLE Majors(
	MajorID INT NOT NULL PRIMARY KEY,
	[Name] VARCHAR(50)
)

CREATE TABLE Subjects(
	SubjectID INT NOT NULL PRIMARY KEY,
	SubjectName VARCHAR(50) NOT NULL
)

CREATE TABLE Payments(
	PaymentID INT NOT NULL PRIMARY KEY,
	PaymentDate DATE NOT NULL,
	PaymentAmount DECIMAL NOT NULL,
	StudentID INT NOT NULL
)

CREATE TABLE Students(
	StudentID INT NOT NULL PRIMARY KEY,
	StudentNumber INT NOT NULL,
	StudentName VARCHAR(50) NOT NULL,
	MajorID INT NOT NULL,
	CONSTRAINT FK_Students_Majors FOREIGN KEY (MajorID) REFERENCES Majors(MajorID)
)

ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID)

CREATE TABLE Agenda(
	StudentID INT NOT NULL,
	SubjectID INT NOT NULL,
	CONSTRAINT PK_Agenda PRIMARY KEY (StudentID,SubjectID),
	CONSTRAINT FK_Agenda_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID),
	CONSTRAINT FK_Agenda_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
)

USE SoftUni

EXEC sp_changedbowner 'sa'

USE [Geography]

EXEC sp_changedbowner 'sa'

SELECT m.MountainRange, p.PeakName, p.Elevation 
FROM Peaks AS p
JOIN Mountains AS m
ON m.Id = p.MountainId
WHERE m.MountainRange = 'RILA'
ORDER BY p.Elevation DESC