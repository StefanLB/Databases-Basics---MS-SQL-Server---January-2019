USE master

CREATE DATABASE ColonialJourney

USE ColonialJourney

EXEC sp_changedbowner 'sa'

--Section 1. DDL (30 pts)

CREATE TABLE Planets
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL FOREIGN KEY REFERENCES Planets(Id)
)

CREATE TABLE Spaceships
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK (Purpose IN ('Medical', 'Technical', 'Educational', 'Military')), /*May have to be NOT NULL*/
	DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CardNumber CHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK (JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')), /*May have to be NOT NULL*/
	ColonistId INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId INT NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
)


--Section 2. DML (10 pts)

--2.	Insert

INSERT INTO Planets VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')


INSERT INTO Spaceships VALUES
('Golf',	'VW',	3),
('WakaWaka',	'Wakanda',	4),
('Falcon9',	'SpaceX',	1),
('Bed',	'Vidolov',	6)


--3.	Update

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

--4.	Delete
--Delete first three inserted Journeys (be careful with the relationships).

DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3

--Section 3. Querying (40 pts)

--5.	Select all travel cards

--USE master
--DROP DATABASE ColonialJourney

SELECT CardNumber, JobDuringJourney
FROM TravelCards
ORDER BY CardNumber

--6.	Select all colonists

--Extract from the database, all colonists. Sort the results by first name, them by last name, and finally by id in ascending order.

SELECT Id, (FirstName + ' ' + LastName) AS FullName, Ucn
FROM Colonists
ORDER BY FirstName, LastName, Id

--7.	Select all military journeys
-- Extract from the database, all Military journeys. Sort the results ascending by journey start.

SELECT Id, CONVERT (NVARCHAR,JourneyStart,103), CONVERT (NVARCHAR,JourneyEnd,103)
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart

--8.	Select all pilots

--Extract from the database all colonists, which have a pilot job. Sort the result by id, ascending.

SELECT c.Id, c.FirstName + ' ' + c.LastName AS full_name
FROM COLONISTS AS c
JOIN TravelCards AS tc ON tc.ColonistId = c.Id
WHERE tc.JobDuringJourney = 'Pilot'
ORDER BY c.Id

--9.	Count colonists
--Count all colonists that are on technical journey. 

SELECT COUNT(*) AS count
FROM COLONISTS AS c
JOIN TravelCards AS tc ON tc.ColonistId = c.Id
JOIN Journeys AS j ON j.Id = tc.JourneyId
WHERE j.Purpose= 'Technical'

--10.	Select the fastest spaceship

--Extract from the database the fastest spaceship and its destination spaceport name. In other words, the ship with the highest light speed rate.

SELECT TOP(1) s.Name AS [SpaceshipName], sp.Name AS [SpaceportName]
FROM Spaceships AS s
JOIN Journeys AS j ON s.Id = j.SpaceshipId
JOIN Spaceports AS sp ON j.DestinationSpaceportId = sp.Id
ORDER BY s.LightSpeedRate DESC

--11.	Select spaceships with pilots younger than 30 years
--Extract from the database those spaceships, which have pilots, younger than 30 years old. In other words, 30 years from 01/01/2019. Sort the results alphabetically by spaceship name.

SELECT s.Name, s.Manufacturer
FROM Spaceships AS s
JOIN Journeys AS j ON j.SpaceshipId = s.Id
JOIN TravelCards AS tc ON j.Id = tc.JourneyId
JOIN Colonists AS c ON c.Id = tc.ColonistId
WHERE tc.JobDuringJourney = 'Pilot' AND (YEAR(c.BirthDate) + 30) > 2019
ORDER BY s.Name


--12.	Select all educational mission planets and spaceports
--Extract from the database names of all planets and their spaceports, which have educational missions. Sort the results by spaceport name in descending order.

SELECT p.[Name] AS [PlanetName], sp.[Name] AS [SpaceportName]
FROM Planets AS p
JOIN Spaceports AS sp ON p.Id = sp.PlanetId
JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
WHERE j.Purpose = 'Educational'
ORDER BY sp.Name DESC

--13.	Select all planets and their journey count
--Extract from the database all planets’ names and their journeys count. Order the results by journeys count, descending and by planet name ascending.

SELECT p.[Name], COUNT(*) AS JourneysCount
FROM Journeys AS j
JOIN Spaceports AS sp ON j.DestinationSpaceportId = sp.Id
JOIN Planets AS p ON p.Id = sp.PlanetId
GROUP BY p.Name
ORDER BY JourneysCount DESC, p.[Name]

--14.	Select the longest journey
--Extract from the database the longest journey, its destination spaceport name, planet name and purpose.

SELECT TOP(1) j.Id, p.[Name] AS PlanetName, sp.[Name] AS SpaceportName, j.Purpose AS JourneyPurpose
FROM Journeys AS j
JOIN Spaceports AS sp ON sp.Id = j.DestinationSpaceportId
JOIN Planets AS p ON p.Id = sp.PlanetId
ORDER BY (j.JourneyStart - j.JourneyEnd) DESC


--15.	Select the less popular job

SELECT TOP(1) j.Id, tc.JobDuringJourney
FROM Journeys AS j
JOIN Spaceports AS sp ON sp.Id = j.DestinationSpaceportId
JOIN Planets AS p ON p.Id = sp.PlanetId
JOIN TravelCards AS tc ON tc.JourneyId = j.Id
ORDER BY (j.JourneyEnd - j.JourneyStart) DESC

--16.	Select Second Oldest Important Colonist

--Find all colonists and their job during journey with rank 2. Keep in mind that all the selected colonists with rank 2 must be the oldest ones. You can use ranking over  their job during their journey.

WITH CTE AS (
SELECT tc.JobDuringJourney, c.FirstName + ' ' + c.LastName AS FullName,
DENSE_RANK() OVER 
		(PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate) AS [JobRank]
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId)

SELECT * FROM CTE WHERE [JobRank] = 2

SELECT * FROM Colonists
SELECT * FROM Journeys
SELECT * FROM TravelCards AS tc
JOIN Colonists AS c ON tc.ColonistId = c.Id
 WHERE JobDuringJourney = 'Cleaner'
 ORDER BY c.BirthDate

--17.	Planets and Spaceports

--Find all planets and all of their spaceports. Select planet name and the count of the spaceports. Sort them by spaceports count (descending), then by name (ascending).

SELECT p.[Name], COUNT(sp.Id) AS [Count]
FROM Planets AS p
LEFT JOIN Spaceports AS sp ON sp.PlanetId = p.Id
GROUP BY p.[Name]
ORDER BY [Count] DESC, p.[Name]

--Section 4. Programmability (20 pts)
--18.	Get Colonists Count

--Create a user defined function with the name dbo.udf_GetColonistsCount(PlanetName VARCHAR (30)) that receives planet name and returns the count of all colonists sent to that planet.

CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN
	DECLARE @Result INT

    SET @Result = (SELECT TOP(1) COUNT(*)
	FROM Planets AS p
	JOIN Spaceports AS sp ON p.Id = sp.PlanetId
	JOIN Journeys AS j ON j.DestinationSpaceportId = sp.Id
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	WHERE p.[Name] = @PlanetName
	GROUP BY p.[Name])

	IF(@Result IS NULL)
	SET @Result = 0

	RETURN @Result
END

--DROP FUNCTION dbo.udf_GetColonistsCount
SELECT dbo.udf_GetColonistsCount('Otroyphus')

--19.	Change Journey Purpose

CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	BEGIN TRANSACTION

	DECLARE @targetJourneyId INT = (SELECT TOP(1) j.Id FROM Journeys AS j WHERE j.Id = @JourneyId)

	IF(@targetJourneyId IS NULL)
		BEGIN 
			RAISERROR('The journey does not exist!', 16, 1);
			ROLLBACK;
			RETURN;  
		END

	DECLARE @targetJourneyPurpose VARCHAR(11) = (SELECT TOP(1) j.Purpose FROM Journeys AS j WHERE j.Id = @JourneyId)

	IF(@targetJourneyPurpose = @NewPurpose)
		BEGIN
			RAISERROR('You cannot change the purpose!', 16, 2);
			ROLLBACK;
			RETURN;  
		END

UPDATE Journeys
SET Purpose = @NewPurpose
WHERE Id = @JourneyId

COMMIT
END

DROP PROCEDURE usp_ChangeJourneyPurpose

EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'
EXEC usp_ChangeJourneyPurpose 1, 'Technical'

--20.	Deleted Journeys

CREATE TABLE DeletedJourneys
(
	Id INT NOT NULL,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK (Purpose IN ('Medical', 'Technical', 'Educational', 'Military')), /*May have to be NOT NULL*/
	DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)

CREATE TRIGGER tr_DeleteJourney ON Journeys AFTER DELETE
AS
	INSERT INTO DeletedJourneys
	SELECT 	
		d.Id, 
		d.JourneyStart, 
		d.JourneyEnd, 
		d.Purpose, 
		d.DestinationSpaceportId, 
		d.SpaceshipId
	FROM deleted as d

	SELECT * FROM Journeys

	DELETE FROM Journeys WHERE Id = 1