USE [ACQ_WEDABAY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASH_COLLAR] AS
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
            [WGS8452N_Plan_X],
            [WGS8452N_Plan_Y],
            [WGS8452N_Plan_Z],
            [WGS8452N_Stakeout_X],
            [WGS8452N_Stakeout_Y],
            [WGS8452N_Stakeout_Z],
            (SQRT(POWER([ACQDERIVEDVIEW].[WGS8452N_Plan_X] - [ACQDERIVEDVIEW].[WGS8452N_Stakeout_X], 2) + 
                  POWER([ACQDERIVEDVIEW].[WGS8452N_Plan_Y] - [ACQDERIVEDVIEW].[WGS8452N_Stakeout_Y], 2))
            ) AS [Deviation_Stakeout_Plan_m],
            [WGS8452N_Surv_X],
            [WGS8452N_Surv_Y],
            [WGS8452N_Surv_Z],
            (SQRT(POWER([ACQDERIVEDVIEW].[WGS8452N_Plan_X] - [ACQDERIVEDVIEW].[WGS8452N_Surv_X], 2) + 
                  POWER([ACQDERIVEDVIEW].[WGS8452N_Plan_Y] - [ACQDERIVEDVIEW].[WGS8452N_Surv_Y], 2))
            ) AS [Deviation_Pickup_Plan_m],
            [Contractor_Stakeout],
            [Stakeout_Tool],
            [CoordDate_Stakeout],
            [Surveyor_Stakeout],
            [Stakeout_Comments],
            [Contractor_Pickup],
            [Pickup_Tool],
            [CoordDate_Pickup],
            [Surveyor_Pickup],
            [Pickup_Comments],
            [Cancel_Date],
            [Cancel_GeosWBN]
        FROM  
        (
            SELECT 
                [HOLELOCATION].[HOLEID] AS [HOLEID],
                [HOLELOCATION].[PROJECTCODE] AS [PROJECTCODE],
                [HOLELOCATION].[PROSPECT],
                [HOLELOCATION].[HOLETYPE],
                [HOLEDETAILS].[Hole_TypeGroup],
                [HOLECOMMENT].[Drill_Space],
                [HOLECOORD].[WGS8452N_Plan_X],
                [HOLECOORD].[WGS8452N_Plan_Y],
                [HOLECOORD].[WGS8452N_Plan_Z],
                [HOLECOORD].[WGS8452N_Stakeout_X],
                [HOLECOORD].[WGS8452N_Stakeout_Y],
                [HOLECOORD].[WGS8452N_Stakeout_Z],
                [HOLECOORD].[WGS8452N_Surv_X],
                [HOLECOORD].[WGS8452N_Surv_Y],
                [HOLECOORD].[WGS8452N_Surv_Z],
                [HOLEDETAILS].[Contractor_Stakeout],
                [HOLEDETAILS].[Stakeout_Tool],
                [HOLEDETAILS].[CoordDate_Stakeout],
                [HOLECOMMENT].[Surveyor_Stakeout],
                [HOLEBIGCOMMENT].[Stakeout_Comments],
                [HOLEDETAILS].[Contractor_Pickup],
                [HOLEDETAILS].[Pickup_Tool],
                [HOLEDETAILS].[CoordDate_Pickup],
                [HOLEDETAILS].[Surveyor_Pickup],
                [HOLEBIGCOMMENT].[Pickup_Comments],
                [HOLEDETAILS].[Cancel_Date],
                [HOLEDETAILS].[Cancel_GeosWBN]
            FROM 
                [HOLELOCATION]
                INNER JOIN [DASH_COLLAR_WSF] ON 
                    [DASH_COLLAR_WSF].[HOLEID] = [HOLELOCATION].[HOLEID] AND 
                    [DASH_COLLAR_WSF].[PROJECTCODE] = [HOLELOCATION].[PROJECTCODE]
                LEFT JOIN 
                (
                    SELECT 
                        [HOLEDETAILS].[HOLEID], 
                        [HOLEDETAILS].[PROJECTCODE],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Hole_TypeGroup' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Hole_TypeGroup],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Contractor_Stakeout' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Contractor_Stakeout],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Stakeout_Tool' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Stakeout_Tool],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'CoordDate_Stakeout' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [CoordDate_Stakeout],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Contractor_Pickup' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Contractor_Pickup],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Pickup_Tool' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Pickup_Tool],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'CoordDate_Pickup' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [CoordDate_Pickup],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Surveyor_Pickup' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Surveyor_Pickup],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Cancel_Date' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Cancel_Date],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Cancel_GeosWBN' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Cancel_GeosWBN]
                    FROM 
                        [HOLEDETAILS]
                    WHERE 
                        [HOLEDETAILS].[NAME] IN 
                        (
                            'Hole_TypeGroup', 
                            'Contractor_Stakeout', 
                            'Stakeout_Tool', 
                            'CoordDate_Stakeout', 
                            'Contractor_Pickup', 
                            'Pickup_Tool', 
                            'CoordDate_Pickup', 
                            'Surveyor_Pickup', 
                            'Cancel_Date', 
                            'Cancel_GeosWBN'
                        )
                    GROUP BY 
                        [HOLEDETAILS].[PROJECTCODE], 
                        [HOLEDETAILS].[HOLEID]
                ) [HOLEDETAILS] ON 
                    [HOLELOCATION].[PROJECTCODE] = [HOLEDETAILS].[PROJECTCODE] AND 
                    [HOLELOCATION].[HOLEID] = [HOLEDETAILS].[HOLEID]
                LEFT JOIN 
                (
                    SELECT 
                        [HOLECOMMENT].[HOLEID], 
                        [HOLECOMMENT].[PROJECTCODE],
                        MIN(CASE WHEN [HOLECOMMENT].[NAME] = 'Drill_Space' THEN [HOLECOMMENT].[VALUE] ELSE NULL END) AS [Drill_Space],
                        MIN(CASE WHEN [HOLECOMMENT].[NAME] = 'Surveyor_Stakeout' THEN [HOLECOMMENT].[VALUE] ELSE NULL END) AS [Surveyor_Stakeout]
                    FROM 
                        [HOLECOMMENT]
                    WHERE 
                        [HOLECOMMENT].[NAME] IN 
                        (
                            'Drill_Space', 
                            'Surveyor_Stakeout'
                        )
                    GROUP BY 
                        [HOLECOMMENT].[PROJECTCODE], 
                        [HOLECOMMENT].[HOLEID]
                ) [HOLECOMMENT] ON 
                    [HOLELOCATION].[PROJECTCODE] = [HOLECOMMENT].[PROJECTCODE] AND 
                    [HOLELOCATION].[HOLEID] = [HOLECOMMENT].[HOLEID]
                LEFT JOIN 
                (
                    SELECT 
                        [HOLEBIGCOMMENT].[HOLEID], 
                        [HOLEBIGCOMMENT].[PROJECTCODE],
                        MIN(CASE WHEN [HOLEBIGCOMMENT].[NAME] = 'Stakeout_Comments' THEN [HOLEBIGCOMMENT].[VALUE] ELSE NULL END) AS [Stakeout_Comments],
                        MIN(CASE WHEN [HOLEBIGCOMMENT].[NAME] = 'Pickup_Comments' THEN [HOLEBIGCOMMENT].[VALUE] ELSE NULL END) AS [Pickup_Comments]
                    FROM 
                        [HOLEBIGCOMMENT]
                    WHERE 
                        [HOLEBIGCOMMENT].[NAME] IN 
                        (
                            'Stakeout_Comments', 
                            'Pickup_Comments'
                        )
                    GROUP BY 
                        [HOLEBIGCOMMENT].[PROJECTCODE], 
                        [HOLEBIGCOMMENT].[HOLEID]
                ) [HOLEBIGCOMMENT] ON 
                    [HOLELOCATION].[PROJECTCODE] = [HOLEBIGCOMMENT].[PROJECTCODE] AND 
                    [HOLELOCATION].[HOLEID] = [HOLEBIGCOMMENT].[HOLEID]
                LEFT JOIN 
                (
                    SELECT 
                        [HOLECOORD].[HOLEID], 
                        [HOLECOORD].[PROJECTCODE],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Plan' THEN [HOLECOORD].[X] ELSE NULL END) AS [WGS8452N_Plan_X],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Plan' THEN [HOLECOORD].[Y] ELSE NULL END) AS [WGS8452N_Plan_Y],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Plan' THEN [HOLECOORD].[Z] ELSE NULL END) AS [WGS8452N_Plan_Z],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Stakeout' THEN [HOLECOORD].[X] ELSE NULL END) AS [WGS8452N_Stakeout_X],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Stakeout' THEN [HOLECOORD].[Y] ELSE NULL END) AS [WGS8452N_Stakeout_Y],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Stakeout' THEN [HOLECOORD].[Z] ELSE NULL END) AS [WGS8452N_Stakeout_Z],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Surv' THEN [HOLECOORD].[X] ELSE NULL END) AS [WGS8452N_Surv_X],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Surv' THEN [HOLECOORD].[Y] ELSE NULL END) AS [WGS8452N_Surv_Y],
                        MIN(CASE WHEN [HOLECOORD].[COORDINATESET] = 'WGS8452N_Surv' THEN [HOLECOORD].[Z] ELSE NULL END) AS [WGS8452N_Surv_Z]
                    FROM 
                        [HOLECOORD]
                    WHERE 
                        [HOLECOORD].[COORDINATESET] IN 
                        (
                            'WGS8452N_Plan', 
                            'WGS8452N_Stakeout', 
                            'WGS8452N_Surv'
                        )
                    GROUP BY 
                        [HOLECOORD].[PROJECTCODE], 
                        [HOLECOORD].[HOLEID]
                ) [HOLECOORD] ON 
                    [HOLELOCATION].[PROJECTCODE] = [HOLECOORD].[PROJECTCODE] AND 
                    [HOLELOCATION].[HOLEID] = [HOLECOORD].[HOLEID]
        ) [ACQDERIVEDVIEW]
    ) [ACQTMP]
)
GO
