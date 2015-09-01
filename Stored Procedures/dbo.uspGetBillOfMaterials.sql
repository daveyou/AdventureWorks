
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGetBillOfMaterials]
@StartProductID [int],
@CheckDate [datetime]
AS
BEGIN
SET NOCOUNT ON;
WITH [BOM_cte]([ProductAssemblyID], [ComponentID], [ComponentDesc], [PerAssemblyQty], [StandardCost], [ListPrice], [BOMLevel], [RecursionLevel]) -- CTE name and columns
AS (
SELECT b.[ProductAssemblyID], b.[ComponentID], p.[Name], b.[PerAssemblyQty], p.[StandardCost], p.[ListPrice], b.[BOMLevel], 0 -- Get the initial list of components for the bike assembly
FROM [Production].[BillOfMaterials] b
INNER JOIN [Production].[Product] p 
ON b.[ComponentID] = p.[ProductID] 
WHERE b.[ProductAssemblyID] = @StartProductID 
AND @CheckDate >= b.[StartDate] 
AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
UNION ALL
SELECT b.[ProductAssemblyID], b.[ComponentID], p.[Name], b.[PerAssemblyQty], p.[StandardCost], p.[ListPrice], b.[BOMLevel], [RecursionLevel] + 1 -- Join recursive member to anchor
FROM [BOM_cte] cte
INNER JOIN [Production].[BillOfMaterials] b 
ON b.[ProductAssemblyID] = cte.[ComponentID]
INNER JOIN [Production].[Product] p 
ON b.[ComponentID] = p.[ProductID] 
WHERE @CheckDate >= b.[StartDate] 
AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
)
SELECT b.[ProductAssemblyID], b.[ComponentID], b.[ComponentDesc], SUM(b.[PerAssemblyQty]) AS [TotalQuantity] , b.[StandardCost], b.[ListPrice], b.[BOMLevel], b.[RecursionLevel]
FROM [BOM_cte] b
GROUP BY b.[ComponentID], b.[ComponentDesc], b.[ProductAssemblyID], b.[BOMLevel], b.[RecursionLevel], b.[StandardCost], b.[ListPrice]
ORDER BY b.[BOMLevel], b.[ProductAssemblyID], b.[ComponentID]
OPTION (MAXRECURSION 50) 
END;
GO


EXEC sp_addextendedproperty N'MS_Description', N'Stored procedure using a recursive query to return a multi-level bill of material for the specified ProductID.', 'SCHEMA', N'dbo', 'PROCEDURE', N'uspGetBillOfMaterials', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Input parameter for the stored procedure uspGetBillOfMaterials used to eliminate components not used after that date. Enter a valid date.', 'SCHEMA', N'dbo', 'PROCEDURE', N'uspGetBillOfMaterials', 'PARAMETER', N'@CheckDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Input parameter for the stored procedure uspGetBillOfMaterials. Enter a valid ProductID from the Production.Product table.', 'SCHEMA', N'dbo', 'PROCEDURE', N'uspGetBillOfMaterials', 'PARAMETER', N'@StartProductID'
GO
