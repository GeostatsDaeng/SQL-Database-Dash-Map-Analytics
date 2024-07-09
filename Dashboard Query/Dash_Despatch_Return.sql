USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_DESPATCHRETURNS] AS
(
    SELECT TOP 100 PERCENT *
    FROM
    (
        SELECT 
            [DESPATCHRETURN].[LABJOBNO] AS [LABJOBNO],
            [DESPATCHRETURN].[DESPATCHNO] AS [DESPATCHNO],
            [DESPATCHRETURN].[COMMENTS],
            [DESPATCHRETURN].[RETURNDATE]
        FROM 
            [DESPATCHRETURN]
    ) [ACQTMP]
);
GO
