USE [ACQ_WEDABAY]
GO

/****** Object:  View [dbo].[AM_HOLESTATUS_RDP]    Script Date: 7/21/2024 5:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[AM_HOLESTATUS_RDP] AS
-- Define CTEs first
WITH FirstSample AS (
    SELECT
        HOLEID,
        MIN(SAMPLEID) AS FIRST_SAMPLEID
    FROM
        [ACQ_WEDABAY].[dbo].[DASH_SAMPLE]
    GROUP BY
        HOLEID
),
FirstAssay AS (
    SELECT
        HOLEID,
        MIN(SAMPLEID) AS FIRST_ASSAYID
    FROM
        [ACQ_WEDABAY].[dbo].[DASH_ASSAY_OUT]
    GROUP BY
        HOLEID
)

-- Use CTEs in the main query
, HoleStatus AS (
    SELECT
        C.[HOLEID],
        C.[PROJECTCODE],
        C.[PROSPECT],
        C.[Hole_TypeGroup] AS DRILLTYPE,
        C.[Drill_Space] AS DRILLINGSPACE,
		C.[WGS8452N_Plan_X],
		C.[WGS8452N_Plan_Y],
		C.[WGS8452N_Plan_Z],
        C.[WGS8452N_Stakeout_X] AS SO,
        C.[WGS8452N_Surv_Z] AS PU,
        C.[Cancel_Date],
        C.[Cancel_GeosWBN],
		C.[Cancel_GeoContractor],
		C.[Cancel_Comments],
        C.[DEPTH],
        C.[ENDDATE],
        C.[Sample_Type_D],
        FS.FIRST_SAMPLEID AS LOGS,
        FA.FIRST_ASSAYID AS ASSAYS,
        CASE
            WHEN C.[Cancel_Date] IS NOT NULL OR
                 C.[Cancel_GeosWBN] IS NOT NULL OR
				 C.[Cancel_GeoContractor] IS NOT NULL OR
				 C.[Cancel_Comments] IS NOT NULL
				 -- HOLE CANCELED IF ONE OF THE FOUR CONDITIONS MET
            THEN 'Hole Canceled'
            WHEN (C.[DEPTH] IS NOT NULL OR
                  C.[ENDDATE] IS NOT NULL OR
                  C.[Sample_Type_D] IS NOT NULL) AND
                  C.[WGS8452N_Surv_Z] IS NOT NULL AND
                  FA.FIRST_ASSAYID IS NOT NULL
            THEN 'Hole Complete'
            WHEN (C.[DEPTH] IS NOT NULL OR
                  C.[ENDDATE] IS NOT NULL OR
                  C.[Sample_Type_D] IS NOT NULL) AND
                  FA.FIRST_ASSAYID IS NOT NULL AND
                  C.[WGS8452N_Surv_Z] IS NULL
            THEN 'Waiting Pickup'
            WHEN (C.[DEPTH] IS NOT NULL OR
                  C.[ENDDATE] IS NOT NULL OR
                  C.[Sample_Type_D] IS NOT NULL) AND
                  C.[WGS8452N_Surv_Z] IS NOT NULL AND
                  FA.FIRST_ASSAYID IS NULL
            THEN 'Waiting Assay'
            WHEN (C.[DEPTH] IS NOT NULL OR
                  C.[ENDDATE] IS NOT NULL OR
                  C.[Sample_Type_D] IS NOT NULL)
				  -- HOLE FINISHED IF ONE OF THE THREE CONDITIONS MET
				  AND
                  FA.FIRST_ASSAYID IS NULL AND
                  C.[WGS8452N_Surv_Z] IS NULL
            THEN 'Hole Finished'
            WHEN C.[WGS8452N_Stakeout_X] IS NOT NULL
            THEN 'To be Drilled'
            ELSE 'Hole Planned'
        END AS HOLESTATUS
    FROM
        [ACQ_WEDABAY].[dbo].[DASH_COLLAR] C
    LEFT JOIN
        FirstSample FS ON C.HOLEID = FS.HOLEID
    LEFT JOIN
        FirstAssay FA ON C.HOLEID = FA.HOLEID
)

-- Select desired columns from HoleStatus CTE
SELECT HS.HOLEID, HS.PROJECTCODE, HS.PROSPECT, HS.DRILLTYPE, HS.DRILLINGSPACE, HS.[WGS8452N_Plan_X] X, HS.[WGS8452N_Plan_Y] Y, HS.[WGS8452N_Plan_Z] Z, HS.ENDDATE, HS.HOLESTATUS
FROM HoleStatus HS
WHERE HS.DRILLTYPE = 'RDP';
GO


