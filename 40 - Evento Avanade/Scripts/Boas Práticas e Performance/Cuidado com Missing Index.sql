USE NorthWind
GO

-- Preparando tabela
IF OBJECT_ID('EmployeesBig') IS NOT NULL
  DROP TABLE EmployeesBig
GO
SELECT IDENTITY(Int, 1,1) AS EmployeeID,
       a.LastName,
       a.FirstName + SUBSTRING(CONVERT(VarChar(200), NEWID()), 0, 5) AS FirstName,
       a.Title,
       a.TitleOfCourtesy,
       a.BirthDate,
       a.HireDate,
       a.Address,
       a.City,
       a.Region,
       a.PostalCode,
       a.Country,
       a.HomePhone,
       a.Extension,
       a.Notes,
       a.ReportsTo,
       a.PhotoPath
  INTO EmployeesBig
  FROM Employees AS a, Employees AS b, Employees AS c, Employees AS d, Employees AS e
GO
ALTER TABLE EmployeesBig ADD CONSTRAINT xpkEmployeeID PRIMARY KEY (EmployeeID)
GO


SELECT LastName,
       FirstName,
       Title,
       TitleOfCourtesy,
       BirthDate,
       HireDate,
       Address,
       City,
       Region,
       PostalCode,
       Country,
       HomePhone,
       Extension, (SELECT 1)
  FROM EmployeesBig
 WHERE PostalCode = '98122'
OPTION (RECOMPILE)
GO



SELECT LastName,
       FirstName,
       Title,
       TitleOfCourtesy,
       BirthDate,
       HireDate,
       Address,
       City,
       Region,
       PostalCode,
       Country,
       HomePhone,
       Extension
  FROM EmployeesBig
 WHERE PostalCode = '98122'
OPTION (RECOMPILE, QueryTraceON 8757) -- TraceFlag 8758 para desabilitar planos trivial plans
GO



-- Índice sugerido não é a melhor opção
SELECT OrderID, CustomerID, OrderDate, Value
  FROM OrdersBig
 WHERE OrderDate = '20080205'
 ORDER BY Value
OPTION (RECOMPILE, QueryTraceOn 8757)


-- Consegue ver o problema no índice sugerido?
CREATE NONCLUSTERED INDEX ix1 ON [dbo].[OrdersBig] ([OrderDate]) 
INCLUDE ([CustomerID],[Value])
GO

-- E agora o sort? ...
SELECT CustomerID, OrderDate, Value
  FROM OrdersBig
 WHERE OrderDate = '20080205'
 ORDER BY Value
OPTION (RECOMPILE, QueryTraceOn 8757)

-- O índice correto é: 
 -- DROP INDEX ix1 ON [dbo].[OrdersBig] 
CREATE NONCLUSTERED INDEX ix1 ON [dbo].[OrdersBig] ([OrderDate], [Value]) INCLUDE ([CustomerID])
WITH(DROP_EXISTING=ON)
GO


