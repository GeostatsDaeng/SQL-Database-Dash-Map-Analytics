USE [ACQ_WEDABAY]
GO

SET ANSI_NULLS ON
-- ANSI_NULLS: When enabled (ON), this setting determines how NULL comparison operators are evaluated. If ANSI_NULLS is enabled, comparisons to NULL (e.g., column = NULL) will always yield FALSE. Conversely, to check for NULL, you must use IS NULL or IS NOT NULL.
GO

SET QUOTED_IDENTIFIER ON
-- QUOTED_IDENTIFIER: When enabled (ON), this setting allows you to use double quotes (") to quote identifiers such as table or column names that might use reserved words or contain spaces. If disabled (OFF), double quotes are treated as string literal delimiters.
GO

CREATE VIEW [dbo].[DASH_HOLE_STATUS] AS
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
        C.[WGS8452N_Stakeout_X] AS SO,
        C.[WGS8452N_Surv_Z] AS PU,
        C.[Cancel_Date],
        C.[Cancel_GeosWBN],
        C.[DEPTH],
        C.[ENDDATE],
        C.[Sample_Type_D],
        FS.FIRST_SAMPLEID AS LOGS,
        FA.FIRST_ASSAYID AS ASSAYS,
        CASE
            WHEN C.[Cancel_Date] IS NOT NULL OR
                 C.[Cancel_GeosWBN] IS NOT NULL --OR
    --           C.[Cancel_GeosCONTRACTOR] IS NOT NULL
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
                  C.[Sample_Type_D] IS NOT NULL) AND
                  FA.FIRST_ASSAYID IS NULL AND
                  C.[WGS8452N_Surv_Z] IS NULL
            THEN 'Hole Finished'
            WHEN C.[WGS8452N_Stakeout_X] IS NOT NULL
            THEN 'To be Drilled'
            ELSE 'Hole Planned'
        END AS HOLESTATUS
    FROM
        [ACQ_WEDABAY].[dbo].[DASH_COLLAR] C			-- Pay attention to the alias I use, C for Table DASH_COLLAR
    LEFT JOIN
        FirstSample FS ON C.HOLEID = FS.HOLEID		-- Pay attention to the alias I use, FS for Table FirstSample (CTE alias that I used the first WITH FirstSample AS (...)
    LEFT JOIN
        FirstAssay FA ON C.HOLEID = FA.HOLEID		-- Pay attention to the alias I use, FA for Table FirstAssay
)

-- Select desired columns from HoleStatus CTE
SELECT HS.HOLEID, HS.PROJECTCODE, HS.PROSPECT, HS.DRILLTYPE, HS.DRILLINGSPACE, HS.HOLESTATUS
FROM HoleStatus HS;
GO