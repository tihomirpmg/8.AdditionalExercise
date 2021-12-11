USE Diablo
GO

/*1-------------------------------------------*/

SELECT SUBSTRING(Email, CHARINDEX('@', Email)+1, LEN(Email)) AS 'Email Provider' ,COUNT([Username]) AS 'Number Of Users' FROM [Users]
GROUP BY SUBSTRING(Email, CHARINDEX('@', Email)+1, LEN(Email)) 
ORDER BY 'Number Of Users'DESC, 'Email Provider' 

/*2-------------------------------------------*/

SELECT g.[Name] ,gt.Name ,u.Username ,ug.Level ,ug.Cash ,c.Name FROM [Games]  AS g
JOIN GameTypes AS gt
ON gt.Id = g.GameTypeId
INNER JOIN UsersGames AS ug
ON ug.GameId = g.Id
INNER JOIN Users AS u
ON u.Id = ug.UserId
INNER JOIN Characters AS c
ON c.Id = ug.CharacterId
ORDER BY Level DESC, Username, g.Name

/*3-------------------------------------------*/

SELECT u.Username AS [Username], g.Name AS [Game], COUNT(i.Id) AS [Items Count], SUM(i.Price) AS [Items Price] FROM Games g
INNER JOIN UsersGames ug
ON ug.GameId = g.Id
INNER JOIN Users u
ON u.Id = ug.UserId
INNER JOIN UserGameItems ugi
ON ugi.UserGameId = ug.Id
INNER JOIN Items i
ON i.Id = ugi.ItemId
GROUP BY u.Username, g.Name HAVING COUNT(i.Id) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username

/*4-------------------------------------------*/

SELECT u.Username AS [Username], g.Name AS [Game],
           MAX(c.Name) AS [Character],
           SUM(ist.Strength) + MAX(gst.Strength) + MAX(cs.Strength) AS [Strength],
           SUM(ist.Defence) + MAX(gst.Defence) + MAX(cs.Defence) AS [Defence],
           SUM(ist.Speed) + MAX(gst.Speed) + MAX(cs.Speed) AS [Speed],
           SUM(ist.Mind) + MAX(gst.Mind) + MAX(cs.Mind) AS [Mind],
           SUM(ist.Luck) + MAX(gst.Luck) + MAX(cs.Luck) AS [Luck]
      FROM Users AS u
INNER JOIN UsersGames AS ug
        ON ug.UserId = u.Id
INNER JOIN Games AS g
        ON g.Id = ug.GameId
INNER JOIN Characters AS c
        ON c.Id = ug.CharacterId
INNER JOIN GameTypes AS gt
        ON gt.Id = g.GameTypeId
INNER JOIN [Statistics] AS gst
        ON gst.Id = gt.BonusStatsId
INNER JOIN [Statistics] AS cs
        ON cs.Id = c.StatisticId
INNER JOIN UserGameItems AS ugi
        ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
        ON i.Id = ugi.ItemId
INNER JOIN [Statistics] AS ist
        ON ist.Id = i.StatisticId
  GROUP BY u.Username, 
           g.Name
  ORDER BY [Strength] DESC, 
           [Defence] DESC, 
           [Speed] DESC, 
           [Mind] DESC, 
           [Luck] DESC

/*5-------------------------------------------*/

DECLARE @AverageMind DECIMAL = (SELECT AVG(s.Mind) FROM [Statistics] s)
DECLARE @AcerageLuck DECIMAL = (SELECT AVG(s.Luck) FROM [Statistics] s)
DECLARE @AverageSpeed DECIMAL =(SELECT AVG(s.Speed) FROM [Statistics] s)

SELECT i.Name, i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind FROM Items i
INNER JOIN [Statistics] s
        ON s.Id = i.StatisticId
     WHERE s.Mind > @AverageMind
       AND s.Luck > @AcerageLuck
       AND s.Speed > @AverageSpeed
  ORDER BY i.Name

/*6-------------------------------------------*/

SELECT i.Name AS Item, i.Price, i.MinLevel, gt.Name AS 'Forbidden Game Type' FROM Items AS i
JOIN GameTypeForbiddenItems AS gtf
ON gtf.ItemId = i.Id
JOIN GameTypes AS gt
ON gt.Id = gtf.GameTypeId
ORDER BY gt.Name DESC, i.Name

/*7-------------------------------------------*/

DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = 'Alex')
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = 'Edinburgh')
DECLARE @AlexUserGameId INT = (SELECT Id FROM UsersGames WHERE GameId = @GameId AND UserId = @UserId)
DECLARE @TotalPrice MONEY = (SELECT SUM(Price) FROM Items WHERE Name IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))
DECLARE @AlexGameId INT = (SELECT GameId FROM UsersGames WHERE Id = @AlexUserGameId)

INSERT INTO UserGameItems SELECT i.Id, @AlexUserGameId FROM Items AS i
WHERE i.Name IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')

UPDATE UsersGames
   SET Cash -= @TotalPrice
 WHERE Id = @AlexUserGameId

SELECT u.Username [Username], g.Name AS [Name], ug.Cash [Cash], i.Name AS [Item name] FROM Users AS u
INNER JOIN UsersGames AS ug
        ON ug.UserId = u.Id
INNER JOIN Games AS g
        ON g.Id = ug.GameId
INNER JOIN UserGameItems AS ugi
        ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
        ON i.Id = ugi.ItemId
WHERE ug.GameId = @AlexGameId
ORDER BY [Item name]

/*-------------------------------------------*/
USE Geography
GO

/*8-------------------------------------------*/

SELECT p.PeakName,m.MountainRange AS Mounntain, p.Elevation FROM Peaks AS p
JOIN Mountains AS m
ON m.Id = p.MountainId
ORDER BY p.Elevation DESC

/*9-------------------------------------------*/

SELECT p.PeakName, m.MountainRange AS Mounntain, c.CountryName, con.ContinentName FROM Peaks AS p
JOIN Mountains AS m
ON m.Id = p.MountainId
JOIN MountainsCountries AS mc
ON mc.MountainId = m.Id
JOIN Countries AS c
ON c.CountryCode = mc.CountryCode
JOIN Continents AS con
ON con.ContinentCode = c.ContinentCode
ORDER BY p.Peakname

/*10-------------------------------------------*/
SELECT c.CountryName,con.ContinentName, (CASE WHEN COUNT(r.RiverName) IS NULL THEN 0 ELSE COUNT(r.RiverName) END) AS RiversCount ,
(CASE WHEN SUM(r.Length) IS NULL THEN 0 ELSE SUM(r.Length) END)  AS TotalLenght FROM Countries AS c
JOIN Continents AS con
ON con.ContinentCode = c.ContinentCode
LEFT JOIN CountriesRivers AS cr
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r
ON r.Id = cr.RiverId
GROUP BY c.CountryName ,con.ContinentName
ORDER BY RiversCount DESC, TotalLenght DESC, c.CountryName

/*11-------------------------------------------*/

SELECT cur.CurrencyCode ,cur.Description AS Currency,COUNT(con.ContinentName) AS NumberOfCountries FROM Currencies AS cur
LEFT JOIN Countries AS c
ON c.CurrencyCode = cur.CurrencyCode
LEFT JOIN Continents AS con
On con.ContinentCode = c.ContinentCode
GROUP BY cur.CurrencyCode, cur.Description
ORDER BY NumberOfCountries DESC, cur.Description

/*12-------------------------------------------*/ 

SELECT con.ContinentName, SUM(c.AreaInSqKm)  AS CountriesArea,SUM(CAST(c.Population AS BIGINT)) AS CountriesPopulation FROM Continents AS con
INNER JOIN Countries As c
ON con.ContinentCode = c.ContinentCode
GROUP BY ContinentName
ORDER BY CountriesPopulation DESC

