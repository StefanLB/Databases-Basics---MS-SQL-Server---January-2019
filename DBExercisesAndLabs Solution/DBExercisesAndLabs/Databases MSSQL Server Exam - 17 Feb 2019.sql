USE master

CREATE DATABASE School

USE School

EXEC sp_changedbowner 'sa'

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age INT CHECK (Age BETWEEN 5 AND 100), /*Negative or zero numbers not allowed, check already covers this constraint?*/
	[Address] NVARCHAR(50),
	[Phone] NCHAR(10) /*Possible Issue*/
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Lessons INT CHECK (Lessons > 0) NOT NULL
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id),
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
	Grade DECIMAL(15,2) NOT NULL CHECK (Grade BETWEEN 2 AND 6)
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	[Date] DATETIME,
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id)
)

CREATE TABLE StudentsExams(
	StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id), /*COMPOSITE PRIMARY KEY MAY NEED TO BE ADDED*/
	ExamId INT NOT NULL FOREIGN KEY REFERENCES Exams(Id),
	Grade DECIMAL(15,2) NOT NULL CHECK (Grade BETWEEN 2 AND 6),
	CONSTRAINT PK_StudentsExams PRIMARY KEY (StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	[Address] NVARCHAR(20) NOT NULL,
	Phone CHAR(10),
	SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id)
)

CREATE TABLE StudentsTeachers(
	StudentId INT NOT NULL FOREIGN KEY REFERENCES Students(Id),/*COMPOSITE PRIMARY KEY MAY NEED TO BE ADDED*/
	TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id),
	CONSTRAINT PK_StudentsTeachers PRIMARY KEY (StudentId, TeacherId)
)

--2. Insert

SELECT * FROM Teachers
SELECT * FROM Subjects

INSERT INTO Teachers VALUES
('Ruthanne',	'Bamb',	'84948 Mesta Junction',	'3105500146',	6),
('Gerrard',	'Lowin',	'370 Talisman Plaza',	'3324874824',	2),
('Merrile',	'Lambdin',	'81 Dahle Plaza',	'4373065154',	5),
('Bert',	'Ivie',	'2 Gateway Circle',	'4409584510',	4)

INSERT INTO Subjects VALUES
('Geometry',	12),
('Health',	10),
('Drama',	7),
('Sports',	9)

--3. Update
/*
UPDATE se
SET Grade = 6.00
FROM StudentsExams AS se
JOIN Exams AS e ON e.Id = se.ExamId
WHERE Grade >= 5.50 AND e.Id IN (1,2)
*/

UPDATE StudentsSubjects
SET Grade = 6.00
WHERE Grade >= 5.50 AND SubjectId IN (1,2)

--4. Delete
DROP CONSTRAINT FK_StudentsTeachers_Teachers

ALTER TABLE StudentsTeachers
DROP CONSTRAINT FK__StudentsT__Teach__398D8EEE

SELECT * FROM Teachers
WHERE Phone LIKE '%72%'

DELETE FROM st
WHERE Phone LIKE '%72%'
StudentsTeachers AS st
JOIN Teachers
WHERE Phone LIKE '%72%'

DELETE FROM StudentsTeachers WHERE TeacherId IN (7,12,15,18,24,26)
DELETE FROM Teachers
WHERE Phone LIKE '%72%'

--5. Teen Students

SELECT FirstName, LastName, Age
FROM Students
WHERE Age >= 12
ORDER BY FirstName,LastName

--6. Cool Addresses

--SELECT FirstName + ' ' + ISNULL(MiddleName + ' ','') + LastName AS [Full Name], Address
--FROM Students
--WHERE [Address] LIKE '%road%'
--ORDER BY FirstName, LastName

SELECT FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + LastName AS [Full Name], Address
FROM Students
WHERE [Address] LIKE '%road%'
ORDER BY FirstName, LastName

--7. 42 Phones

SELECT FirstName, [Address], Phone
FROM Students
WHERE Phone LIKE '42%' AND MiddleName IS NOT NULL
ORDER BY FirstName

--8. Students Teachers

SELECT FirstName, LastName, Count(st.TeacherId) AS TeachersCount
FROM Students AS s
JOIN StudentsTeachers AS st ON s.Id = st.StudentId
GROUP BY FirstName, LastName

--9. Subjects with Students

--ORDERED DIFFERENTLY THAN THE EXAMPLE

SELECT t.FirstName + ' ' + t.LastName AS FullName, CAST((CAST(s.Name AS NVARCHAR) + CAST('-' AS NVARCHAR) + CAST(s.Lessons AS NVARCHAR)) AS NVARCHAR) AS Subjects, COUNT(st.StudentId) AS Students
FROM Teachers AS t
JOIN Subjects AS s ON s.Id = t.SubjectId
JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName, s.Name, s.Lessons
ORDER BY COUNT(st.StudentId) DESC

--10. Students to Go

SELECT FirstName + ' ' + LastName AS [Full Name]
FROM Students AS s
LEFT JOIN StudentsExams AS se ON se.StudentId = s.Id
WHERE se.ExamId IS NULL
ORDER BY [Full Name]

--11. Busiest Teachers

SELECT TOP(10) t.FirstName, t.LastName, COUNT(st.StudentId) AS StudentsCount
FROM Teachers AS t
JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName
ORDER BY StudentsCount DESC, t.FirstName, t.LastName

--12. Top Students

SELECT TOP(10) s.FirstName, s.LastName, CAST(AVG(se.Grade) AS DECIMAL(15,2)) AS Grade
FROM Students AS s
JOIN StudentsExams AS se ON se.StudentId = s.Id
GROUP BY s.FirstName, s.LastName
ORDER BY AVG(se.Grade) DESC, s.FirstName, s.LastName

--13. Second Highest Grade

SELECT DISTINCT FirstQ.FirstName, FirstQ.LastName, FirstQ.Grade
FROM
	(SELECT s.FirstName, s.LastName, ss.Grade,
	ROW_NUMBER() OVER 
			(PARTITION BY s.Id ORDER BY ss.Grade DESC) AS [GradeRank]
	FROM Students AS s
	JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id) AS FirstQ
WHERE FirstQ.GradeRank = 2
ORDER BY FirstQ.FirstName, FirstQ.LastName


--14. Not So In The Studying

SELECT s.FirstName + ' ' + ISNULL(s.MiddleName + ' ','') + s.LastName AS [Full Name]
FROM Students AS s
LEFT JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
WHERE ss.SubjectId IS NULL
ORDER BY [Full Name]

--15. Top Student per Teacher

SELECT fq.[Teacher Full Name], fq.[Subject Name], fq.[Student Full Name], fq.Grade
FROM(
	SELECT	t.FirstName + ' ' + t.LastName AS [Teacher Full Name],
			s.Name AS [Subject Name],
			avgs.FirstName + ' ' + avgs.LastName AS [Student Full Name],
			avgs.Grade,
			DENSE_RANK() OVER (PARTITION BY t.FirstName, t.LastName, s.Name ORDER BY avgs.Grade DESC) AS [GradeRank]
	FROM Teachers AS t
	JOIN StudentsTeachers AS st ON t.Id = st.TeacherId
	JOIN Subjects AS s ON s.Id = t.SubjectId
	JOIN
			(SELECT s.Id, s.FirstName,s.LastName, ss.SubjectId, CAST(AVG(ss.Grade) AS DECIMAL(15,2)) AS Grade
			FROM Students AS s
			JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
			GROUP BY s.Id, ss.SubjectId, s.FirstName, s.LastName) AS avgs ON (st.StudentId = avgs.Id AND t.SubjectId = avgs.SubjectId)) AS fq
WHERE fq.GradeRank = 1
ORDER BY fq.[Subject Name], fq.[Teacher Full Name], fq.Grade DESC



--16. Average Grade per Subject

SELECT s.Name, AVG(ss.Grade) AS AverageGrade
FROM Subjects AS s
JOIN StudentsSubjects AS ss ON s.Id = ss.SubjectId
GROUP BY s.Name, s.Id
ORDER BY s.Id

--17. Exams Information

SELECT 
	CASE
		WHEN DATEPART(QUARTER,e.Date) = 1 THEN 'Q1'
		WHEN DATEPART(QUARTER,e.Date) = 2 THEN 'Q2'
		WHEN DATEPART(QUARTER,e.Date) = 3 THEN 'Q3'
		WHEN DATEPART(QUARTER,e.Date) = 4 THEN 'Q4'
		ELSE 'TBA'
		END AS [Quarter]
		, s.Name
		, COUNT(se.StudentId)
FROM Exams AS e
JOIN Subjects AS s ON e.SubjectId = s.Id
JOIN StudentsExams AS se ON se.ExamId = e.Id
WHERE Grade >= 4.00
GROUP BY CASE
		WHEN DATEPART(QUARTER,e.Date) = 1 THEN 'Q1'
		WHEN DATEPART(QUARTER,e.Date) = 2 THEN 'Q2'
		WHEN DATEPART(QUARTER,e.Date) = 3 THEN 'Q3'
		WHEN DATEPART(QUARTER,e.Date) = 4 THEN 'Q4'
		ELSE 'TBA' END
		, s.Name
ORDER BY [Quarter]

--18. Exam Grades

CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15,2))
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @foundId INT = (SELECT TOP(1) Id FROM Students WHERE Id = @studentId)

	IF (@foundId IS NULL)
	BEGIN
		RETURN 'The student with provided id does not exist in the school!'
	END

	IF(@grade > 6.00)
	BEGIN
		RETURN 'Grade cannot be above 6.00!'
	END

	DECLARE @Result INT

	SET @Result = (SELECT COUNT(*)
					FROM Students AS s
					JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
					WHERE s.Id = @studentId AND ss.Grade > @grade AND ss.Grade <= (@grade + 0.50))

	DECLARE @studentFirstName NVARCHAR(50)

	SET @studentFirstName = (SELECT TOP(1) FirstName FROM Students WHERE Id = @studentId)

	DECLARE @endMessage NVARCHAR(MAX)

	SET @endMessage = CONCAT('You have to update ', CAST(@Result AS NVARCHAR(50)),' grades for the student ',CAST(@studentFirstName AS NVARCHAR(50)))

	RETURN @endMessage

	END

SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)

--19. Exclude from school

CREATE PROCEDURE usp_ExcludeFromSchool(@StudentId INT)
AS
BEGIN
	BEGIN TRANSACTION

	DECLARE @foundStudentId INT = (SELECT TOP(1) Id FROM Students WHERE Id = @StudentId)

	IF (@foundStudentId IS NULL)
	BEGIN
		RAISERROR('This school has no student with the provided id!', 16, 1);
		ROLLBACK;
		RETURN; 
	END

DELETE FROM StudentsSubjects
WHERE StudentId = @StudentId

DELETE FROM StudentsExams
WHERE StudentId = @StudentId

DELETE FROM StudentsTeachers
WHERE StudentId = @StudentId

DELETE FROM Students
WHERE Id = @StudentId

COMMIT
END

DROP PROCEDURE usp_ExcludeFromSchool

EXEC usp_ExcludeFromSchool 1

EXEC usp_ExcludeFromSchool 301

--20. Deleted Student

CREATE TABLE ExcludedStudents(
	StudentId INT,
	StudentName NVARCHAR(50)
)

CREATE TRIGGER tr_DeletedStudent ON Students AFTER DELETE
AS
	INSERT INTO ExcludedStudents
	SELECT d.Id, d.FirstName + ' ' + d.LastName
	FROM deleted as d
