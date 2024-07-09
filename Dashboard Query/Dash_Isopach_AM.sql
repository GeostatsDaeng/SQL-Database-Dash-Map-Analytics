USE [ACQ_WEDABAY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASH_ISOPACH_AM] AS (
SELECT 
    PROJECTCODE, 
    HOLEID,

    -- CUT OFF 0.0%
    -- Ore thickness for Ni with cut off 0.0%
    SUM(CASE
        WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct >= 0 THEN Samp_Interval_DD
        ELSE 0
    END) AS T_LIM_Co00,

    SUM(CASE
        WHEN (Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct >= 0 THEN Samp_Interval_DD
        ELSE 0
    END) AS T_SAP_Co00,

    SUM(CASE
        WHEN (Ore_Limit_D = 'LIM' OR Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct >= 0 THEN Samp_Interval_DD
        ELSE 0
    END) AS T_LIM_SAP_Co00,

    -- Weighted Ni average for cut off 0.0%		COALESCE('',0) used to replace null with 0 
    COALESCE(ROUND(
        AVG(CASE 
            WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct >= 0 THEN Ni_XRF_pct * Samp_Interval_DD 
        END) 
        / AVG(CASE 
            WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct >= 0 THEN Samp_Interval_DD 
        END), 
        2
    ), 0) AS X_LIM_Co00,

    COALESCE(ROUND(
        AVG(CASE 
            WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct >= 0 THEN Ni_XRF_pct * Samp_Interval_DD 
        END) 
        / AVG(CASE 
            WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct >= 0 THEN Samp_Interval_DD 
        END), 
        2
    ), 0) AS X_SAP_Co00,

    COALESCE(ROUND(
        AVG(CASE 
            WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') AND Ni_XRF_pct >= 0 THEN Ni_XRF_pct * Samp_Interval_DD 
        END) 
        / AVG(CASE 
            WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') AND Ni_XRF_pct >= 0 THEN Samp_Interval_DD 
        END), 
        2
    ), 0) AS X_LIM_SAP_Co00,

	-- Accumulated Ni cut off 0.0% in LIM, FSAP and RSAP
	ROUND(SUM(CASE
        WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') AND Ni_XRF_pct >= 0 THEN Ni_XRF_pct * Samp_Interval_DD 
        ELSE 0
    END), 2) AS ACC_LIM_SAP_Co00,


    -- CUT OFF 0.7% AND 0.8%
    -- Ore thickness for Ni with cut off 0.7% and 0.8%
    SUM(CASE
        WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Samp_Interval_DD
        ELSE 0
    END) AS T_LIM_Co07,

    SUM(CASE
        WHEN (Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct > 0.8 THEN Samp_Interval_DD
        ELSE 0
    END) AS T_SAP_Co08,

    SUM(CASE
        WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) 
            OR ((Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct > 0.8) 
        THEN Samp_Interval_DD
        ELSE 0
    END) AS T_LIM_SAP_Co08,

    -- Weighted Ni average for cut off 0.7% and 0.8%
    COALESCE(ROUND(
        AVG(CASE 
            WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Ni_XRF_pct * Samp_Interval_DD 
        END) 
        / AVG(CASE 
            WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Samp_Interval_DD 
        END), 
        2
    ), 0) AS X_LIM_Co07,

    COALESCE(ROUND(
        AVG(CASE 
            WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Ni_XRF_pct * Samp_Interval_DD 
        END) 
        / AVG(CASE 
            WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Samp_Interval_DD 
        END), 
        2
    ), 0) AS X_SAP_Co08,

    COALESCE(ROUND(
        AVG(CASE 
            WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) 
                OR ((Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct > 0.8) 
            THEN Ni_XRF_pct * Samp_Interval_DD 
        END) 
        / AVG(CASE 
            WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) 
                OR ((Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct > 0.8) 
            THEN Samp_Interval_DD 
        END), 
        2
    ), 0) AS X_LIM_SAP_Co0708,

	-- Accumulated Ni cut off 0.7% and 0.8%
	ROUND(SUM(CASE
        WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Ni_XRF_pct * Samp_Interval_DD 
        ELSE 0
    END), 2) AS ACC_LIM_Co07,

	ROUND(SUM(CASE
        WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Ni_XRF_pct * Samp_Interval_DD 
        ELSE 0
    END), 2) AS ACC_SAP_Co08,

	ROUND(SUM(CASE
        WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) 
			OR ((Ore_Limit_D = 'FSAP' OR Ore_Limit_D = 'RSAP') AND Ni_XRF_pct > 0.8) 
        THEN Ni_XRF_pct * Samp_Interval_DD 
        ELSE 0
    END), 2) AS ACC_LIM_SAP_Co0708


FROM DASH_ISOPACH
GROUP BY 
    PROJECTCODE, 
    HOLEID)
GO


