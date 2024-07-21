USE [ACQ_WEDABAY]
GO

DROP VIEW [dbo].[DASH_ISOPACH_AM]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASH_ISOPACH_AM] AS (
SELECT 
    HOLEID AS DH_ID,
    PROJECTCODE AS Deposit,

    -- Ore thickness for Ni with cut off 0.0%
    SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Samp_Interval_DD ELSE 0 END) AS tlim00,
    SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Samp_Interval_DD ELSE 0 END) AS tsap00,
    SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') THEN Samp_Interval_DD ELSE 0 END) AS tore00,

    -- Weighted Ni average for cut off 0.0%
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS nilim00,
    
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS nisap00,

    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS ni00,

    -- Accumulated Ni cut off 0.0% in LIM, FSAP, and RSAP
    ROUND(SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP') THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS accni00,

    -- Ore thickness for Ni with cut off 0.7% and 0.8%
    SUM(CASE WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Samp_Interval_DD ELSE 0 END) AS tlim07,
    SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Samp_Interval_DD ELSE 0 END) AS tsap08,
    SUM(CASE WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) OR (Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8) THEN Samp_Interval_DD ELSE 0 END) AS tore0708,

    -- Weighted Ni average for cut off 0.7% and 0.8%
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS nilim07,

    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS nisap08,

    COALESCE(ROUND(
        SUM(CASE WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) OR (Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8) THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) OR (Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8) THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS ni0708,

    -- Accumulated Ni cut off 0.7% and 0.8%
    ROUND(SUM(CASE WHEN Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7 THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS lim_acni07,
    ROUND(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8 THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS sap_acni08,
    ROUND(SUM(CASE WHEN (Ore_Limit_D = 'LIM' AND Ni_XRF_pct > 0.7) OR (Ore_Limit_D IN ('FSAP', 'RSAP') AND Ni_XRF_pct > 0.8) THEN Ni_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS accni0708,

    -- Weighted SiO2 average for Ni cut off 0.0% in LIM
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS si_lim,

    -- Accumulated SiO2 average for Ni cut off 0.0% in LIM
    ROUND(SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS si_aclim,

    -- Weighted SiO2 average for Ni cut off 0.0% in SAP
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS si_sap,

    -- Accumulated SiO2 average for Ni cut off 0.0% in SAP
    ROUND(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS si_acsap,

    -- Weighted SiO2 average for Ni cut off 0.0% in BRK
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D = 'BRK' THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D = 'BRK' THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS si_brk,

    -- Weighted SiO2 average for Ni cut off 0.0% in ALL
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP', 'BRK') THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP', 'BRK') THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS si_all,

    -- Accumulated SiO2 average for Ni cut off 0.0% in ALL
    COALESCE(ROUND(SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP', 'BRK') THEN SiO2_XRF_pct * Samp_Interval_DD ELSE 0 END), 2), 0) AS si_acc,

    -- Weighted Al2O3 average for Ni cut off 0.0% in LIM
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS al_lim,

    -- Accumulated Al2O3 average for Ni cut off 0.0% in LIM
    ROUND(SUM(CASE WHEN Ore_Limit_D = 'LIM' THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS al_aclim,

    -- Weighted Al2O3 average for Ni cut off 0.0% in SAP
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS al_sap,

    -- Accumulated Al2O3 average for Ni cut off 0.0% in SAP
    ROUND(SUM(CASE WHEN Ore_Limit_D IN ('FSAP', 'RSAP') THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END), 2) AS al_acsap,

    -- Weighted Al2O3 average for Ni cut off 0.0% in BRK
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D = 'BRK' THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D = 'BRK' THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS al_brk,

    -- Weighted Al2O3 average for Ni cut off 0.0% in ALL
    COALESCE(ROUND(
        SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP', 'BRK') THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP', 'BRK') THEN Samp_Interval_DD ELSE 0 END), 0), 2), 0) AS al_all,

    -- Accumulated Al2O3 average for Ni cut off 0.0% in ALL
    COALESCE(ROUND(SUM(CASE WHEN Ore_Limit_D IN ('LIM', 'FSAP', 'RSAP', 'BRK') THEN Al2O3_XRF_pct * Samp_Interval_DD ELSE 0 END), 2), 0) AS al_acc,

    -- Assay status telling if we have Ore_Limit from the assay or only sample log (without assay)
    CASE WHEN SUM(SiO2_XRF_pct) > 0 THEN 'Completed' ELSE 'Just Major' END AS Assay_Status

FROM DASH_ISOPACH
GROUP BY PROJECTCODE, HOLEID)

GO
