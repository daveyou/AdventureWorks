
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
SET NOCOUNT ON;
PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
', Line ' + CONVERT(varchar(50), ERROR_LINE());
PRINT ERROR_MESSAGE();
END;
GO


EXEC sp_addextendedproperty N'MS_Description', N'Prints error information about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without printing any error information.', 'SCHEMA', N'dbo', 'PROCEDURE', N'uspPrintError', NULL, NULL
GO
