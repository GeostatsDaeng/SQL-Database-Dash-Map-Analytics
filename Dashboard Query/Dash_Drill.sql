USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_DRILL] AS
(
    SELECT TOP 100 PERCENT *
    FROM
    (
        SELECT TOP 100 PERCENT 
            [HOLEID], 
            [PROJECTCODE], 
            [PROSPECT], 
            [HOLETYPE], 
            [Hole_TypeGroup], 
            [Drill_Space], 
            [Contractor_Drilling], 
            [RigID], 
            [STARTDATE], 
            [ENDDATE], 
            [DEPTH],  
            (
                SELECT ROUND(AVG(CAST(sd.VALUE AS FLOAT)), 2) * 100
                FROM dbo.[SAMPLE] AS s
                JOIN dbo.SAMPLEDETAILS AS sd ON s.SAMPLEID = sd.SAMPLEID
                WHERE s.HOLEID = [ACQDERIVEDVIEW].[HOLEID]
                AND s.PROJECTCODE = [ACQDERIVEDVIEW].[PROJECTCODE]
                AND sd.[NAME] = 'Samp_Length'
            ) AS [Hole_Rec_pct_D],  
            (
                SELECT TOP 1(SAMPLETYPE) 
                FROM dbo.SAMPLE
                WHERE HOLEID = [ACQDERIVEDVIEW].[HOLEID]
                AND PROJECTCODE = [ACQDERIVEDVIEW].[PROJECTCODE]
            ) AS [Sample_Type_D],  
            (
                SELECT COUNT(SAMPLEID) 
                FROM dbo.SAMPLE
                WHERE HOLEID = [ACQDERIVEDVIEW].[HOLEID]
                AND PROJECTCODE = [ACQDERIVEDVIEW].[PROJECTCODE]
            ) AS [Total_Samples_D], 
            [CoordDate_Stakeout], 
            [CoordDate_Pickup]
        FROM
        (
            SELECT 
                [HOLELOCATION].[HOLEID] AS [HOLEID], 
                [HOLELOCATION].[PROJECTCODE] AS [PROJECTCODE], 
                [HOLELOCATION].[PROSPECT], 
                [HOLELOCATION].[HOLETYPE], 
                [HOLEDETAILS].[Hole_TypeGroup], 
                [HOLECOMMENT].[Drill_Space], 
                [HOLEDETAILS].[Contractor_Drilling], 
                [HOLEDETAILS].[RigID], 
                [HOLELOCATION].[STARTDATE], 
                [HOLELOCATION].[ENDDATE], 
                [HOLELOCATION].[DEPTH], 
                [HOLEDETAILS].[CoordDate_Stakeout], 
                [HOLEDETAILS].[CoordDate_Pickup]
            FROM [HOLELOCATION]
            INNER JOIN DASH_DRILL_WSF ON [DASH_DRILL_WSF].[HOLEID] = [HOLELOCATION].[HOLEID] 
            AND [DASH_DRILL_WSF].[PROJECTCODE] = [HOLELOCATION].[PROJECTCODE]
            LEFT JOIN 
            (
                SELECT 
                    [HOLEDETAILS].[HOLEID], 
                    [HOLEDETAILS].[PROJECTCODE], 
                    MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Hole_TypeGroup' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Hole_TypeGroup], 
                    MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Contractor_Drilling' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Contractor_Drilling], 
                    MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'RigID' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [RigID], 
                    MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'CoordDate_Stakeout' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [CoordDate_Stakeout], 
                    MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'CoordDate_Pickup' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [CoordDate_Pickup] 
                FROM [HOLEDETAILS]
                WHERE [HOLEDETAILS].[NAME] IN ('Hole_TypeGroup', 'Contractor_Drilling', 'RigID', 'CoordDate_Stakeout', 'CoordDate_Pickup')
                GROUP BY [HOLEDETAILS].[PROJECTCODE], [HOLEDETAILS].[HOLEID]
            ) [HOLEDETAILS] ON [HOLELOCATION].[PROJECTCODE] = [HOLEDETAILS].[PROJECTCODE] 
            AND [HOLELOCATION].[HOLEID] = [HOLEDETAILS].[HOLEID]
            LEFT JOIN 
            (
                SELECT 
                    [HOLECOMMENT].[HOLEID], 
                    [HOLECOMMENT].[PROJECTCODE], 
                    MIN(CASE WHEN [HOLECOMMENT].[NAME] = 'Drill_Space' THEN [HOLECOMMENT].[VALUE] ELSE NULL END) AS [Drill_Space]
                FROM [HOLECOMMENT]
                WHERE [HOLECOMMENT].[NAME] IN ('Drill_Space')
                GROUP BY [HOLECOMMENT].[PROJECTCODE], [HOLECOMMENT].[HOLEID]
            ) [HOLECOMMENT] ON [HOLELOCATION].[PROJECTCODE] = [HOLECOMMENT].[PROJECTCODE] 
            AND [HOLELOCATION].[HOLEID] = [HOLECOMMENT].[HOLEID]
        ) [ACQDERIVEDVIEW]
    ) [ACQTMP]
);
GO
