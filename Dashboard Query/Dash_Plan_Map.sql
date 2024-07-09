USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_PLAN_MAP] AS
(
    SELECT TOP 100 PERCENT *
    FROM 
    (
        SELECT 
            [HOLELOCATION].[HOLEID] AS [HOLEID], 
            [HOLELOCATION].[PROJECTCODE] AS [PROJECTCODE], 
            [HOLELOCATION].[HOLETYPE], 
            [HOLELOCATION].[PROSPECT], 
            [HOLECOORD].[WGS8452N_Plan_X], 
            [HOLECOORD].[WGS8452N_Plan_Y]
        FROM [HOLELOCATION]
        INNER JOIN DASH_PLAN_MAP_WSF 
            ON [DASH_PLAN_MAP_WSF].[HOLEID] = [HOLELOCATION].[HOLEID] 
            AND [DASH_PLAN_MAP_WSF].[PROJECTCODE] = [HOLELOCATION].[PROJECTCODE]
        LEFT JOIN 
        (
            SELECT 
                [HOLECOORD].[HOLEID], 
                [HOLECOORD].[PROJECTCODE], 
                MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Plan' THEN [HOLECOORD].[X] ELSE NULL END) AS [WGS8452N_Plan_X], 
                MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Plan' THEN [HOLECOORD].[Y] ELSE NULL END) AS [WGS8452N_Plan_Y]
            FROM [HOLECOORD]
            WHERE [HOLECOORD].[COORDINATESET] IN ('WGS8452N_Plan', 'WGS8452N_Plan')
            GROUP BY [HOLECOORD].[PROJECTCODE], [HOLECOORD].[HOLEID]
        ) [HOLECOORD] 
            ON [HOLELOCATION].[PROJECTCODE] = [HOLECOORD].[PROJECTCODE] 
            AND [HOLELOCATION].[HOLEID] = [HOLECOORD].[HOLEID]
    ) [ACQTMP]
    WHERE [ACQTMP].[WGS8452N_Plan_X] IS NOT NULL
);
GO