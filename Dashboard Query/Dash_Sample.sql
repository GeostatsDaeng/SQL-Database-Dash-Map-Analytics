USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_SAMPLE] AS
(
    SELECT TOP 100 PERCENT *
    FROM 
    (
        SELECT TOP 100 PERCENT
            [SAMPLEID],
            [HOLEID],
            [PROJECTCODE],
            [dbo].[QFN_SAMPLE_DESPATCH_LIST]([ACQDERIVEDVIEW].[SAMPLEID], 'DESPATCHNO', ',') AS [DespatchNo_DDD],
            [PRIORITY],
            [SAMPLETYPE],
            [SAMPFROM],
            [SAMPTO],
            [Samp_Depth],
            [Samp_Length],
            CASE 
                WHEN CAST([ACQDERIVEDVIEW].[Samp_Length] AS FLOAT) * 100 > 100 THEN 100
                ELSE CAST([ACQDERIVEDVIEW].[Samp_Length] AS FLOAT) * 100
            END AS [Samp_Rec_pct_D],
            [Geo_LoggedBy],
            [MajorLith],
            [MinorLith],
            [Rock_pct],
            [RockType],
            CASE 
                WHEN [ACQDERIVEDVIEW].[MgO_XRF_pct] IS NOT NULL 
                     AND [ACQDERIVEDVIEW].[Fe2O3_XRF_pct] IS NOT NULL  
                     AND [ACQDERIVEDVIEW].[Al2O3_XRF_pct] IS NOT NULL 
                THEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) / 
                     ((CAST([ACQDERIVEDVIEW].[Fe2O3_XRF_pct] AS FLOAT) + CAST([ACQDERIVEDVIEW].[Al2O3_XRF_pct] AS FLOAT)) AS VARCHAR)
                ELSE NULL
            END AS [Alteration_Index],
            CASE 
                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) = 0 THEN
                    CASE 
                        WHEN [ACQDERIVEDVIEW].[MajorLith] IN ('OB', 'LIM', 'TRP') THEN 'LIM'
                        WHEN [ACQDERIVEDVIEW].[MajorLith] = 'FSAP' THEN 'FSAP'
                        WHEN [ACQDERIVEDVIEW].[MajorLith] IN ('SAP', 'RSAP', 'CST') THEN 'RSAP'
                        WHEN [ACQDERIVEDVIEW].[MajorLith] = 'BRK' THEN 'BRK'
                    END
                ELSE
                    CASE 
                        WHEN [ACQDERIVEDVIEW].[MajorLith] IN ('OB', 'LIM', 'TRP') THEN
                            CASE 
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) <= 5 THEN 'LIM'
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) > 5 AND CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) <= 30 THEN 'FSAP'
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) > 30 THEN 'RSAP'
                                ELSE 'LIM'
                            END
                        WHEN [ACQDERIVEDVIEW].[MajorLith] = 'FSAP' THEN
                            CASE 
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) < 5 THEN 'LIM'
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) >= 5 AND CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) <= 30 THEN 'FSAP'
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) > 30 THEN 'RSAP'
                                ELSE 'FSAP'
                            END
                        WHEN [ACQDERIVEDVIEW].[MajorLith] IN ('SAP', 'RSAP') THEN
                            CASE 
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) < 5 THEN 'LIM'
                                WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) < 30 THEN 'FSAP'
                                ELSE 'RSAP'
                            END
                        WHEN [ACQDERIVEDVIEW].[MajorLith] = 'BRK' THEN
                            CASE 
                                WHEN CAST([ACQDERIVEDVIEW].[Ni_XRF_pct] AS FLOAT) > 0.4 THEN 'RSAP'
                                ELSE 'BRK'
                            END
                        WHEN [ACQDERIVEDVIEW].[MajorLith] = 'CST' THEN 'RSAP'
                        ELSE ''
                    END
            END AS [Ore_Limit_D]
        FROM 
        (
            SELECT 
                [SAMPLE].[SAMPLEID] AS [SAMPLEID],
                [SAMPLE].[HOLEID],
                [SAMPLE].[PROJECTCODE],
                [SAMPLE].[PRIORITY],
                [SAMPLE].[SAMPLETYPE],
                [SAMPLE].[SAMPFROM],
                [SAMPLE].[SAMPTO],
                CAST([SAMPLEDETAILS].[Samp_Depth] AS FLOAT) AS [Samp_Depth],
                CAST([SAMPLEDETAILS].[Samp_Length] AS FLOAT) AS [Samp_Length],
                [POINTGEOLOGY].[Geo_LoggedBy],
                [POINTGEOLOGY].[MajorLith],
                [POINTGEOLOGY].[MinorLith],
                [POINTGEOLOGY].[Rock_pct],
                [POINTGEOLOGY].[RockType],
                [CORPSAMPLEASSAY_N].[Al2O3_XRF_pct],
                [CORPSAMPLEASSAY_N].[Fe2O3_XRF_pct],
                [CORPSAMPLEASSAY_N].[MgO_XRF_pct],
                [CORPSAMPLEASSAY_N].[Ni_XRF_pct]
            FROM [SAMPLE]
            INNER JOIN DASH_SAMPLE_WSF 
                ON [DASH_SAMPLE_WSF].[HOLEID] = [SAMPLE].[HOLEID]
                AND [DASH_SAMPLE_WSF].[PROJECTCODE] = [SAMPLE].[PROJECTCODE]
                AND [DASH_SAMPLE_WSF].[HOLETYPE] = 'DRILLHOLE'
            LEFT JOIN 
            (
                SELECT 
                    [CORPSAMPLEASSAY_N].[SAMPLEID],
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'Al2O3_XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [Al2O3_XRF_pct],
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'Fe2O3_XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [Fe2O3_XRF_pct],
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'MgO_XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [MgO_XRF_pct],
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'Ni_XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [Ni_XRF_pct]
                FROM [CORPSAMPLEASSAY_N]
                WHERE [CORPSAMPLEASSAY_N].[NAME] IN ('Al2O3_XRF_pct', 'Fe2O3_XRF_pct', 'MgO_XRF_pct', 'Ni_XRF_pct')
                GROUP BY [CORPSAMPLEASSAY_N].[SAMPLEID]
            ) [CORPSAMPLEASSAY_N] 
                ON [SAMPLE].[SAMPLEID] = [CORPSAMPLEASSAY_N].[SAMPLEID]
            LEFT JOIN 
            (
                SELECT 
                    [SAMPLEDETAILS].[SAMPLEID],
                    MIN(CASE WHEN [SAMPLEDETAILS].[NAME] = 'Samp_Depth' THEN CAST([SAMPLEDETAILS].[VALUE] AS FLOAT) ELSE NULL END) AS [Samp_Depth],
                    MIN(CASE WHEN [SAMPLEDETAILS].[NAME] = 'Samp_Length' THEN CAST([SAMPLEDETAILS].[VALUE] AS FLOAT) ELSE NULL END) AS [Samp_Length]
                FROM [SAMPLEDETAILS]
                WHERE [SAMPLEDETAILS].[NAME] IN ('Samp_Depth', 'Samp_Length')
                GROUP BY [SAMPLEDETAILS].[SAMPLEID]
            ) [SAMPLEDETAILS] 
                ON [SAMPLE].[SAMPLEID] = [SAMPLEDETAILS].[SAMPLEID]
            LEFT JOIN 
            (
                SELECT 
                    [POINTGEOLOGY].[SAMPLEID],
                    MIN(CASE WHEN [POINTGEOLOGY].[NAME] = 'Geo_LoggedBy' THEN [POINTGEOLOGY].[VALUE] ELSE NULL END) AS [Geo_LoggedBy],
                    MIN(CASE WHEN [POINTGEOLOGY].[NAME] = 'MajorLith' THEN [POINTGEOLOGY].[VALUE] ELSE NULL END) AS [MajorLith],
                    MIN(CASE WHEN [POINTGEOLOGY].[NAME] = 'MinorLith' THEN [POINTGEOLOGY].[VALUE] ELSE NULL END) AS [MinorLith],
                    MIN(CASE WHEN [POINTGEOLOGY].[NAME] = 'Rock_pct' THEN [POINTGEOLOGY].[VALUE] ELSE NULL END) AS [Rock_pct],
                    MIN(CASE WHEN [POINTGEOLOGY].[NAME] = 'RockType' THEN [POINTGEOLOGY].[VALUE] ELSE NULL END) AS [RockType]
                FROM [POINTGEOLOGY]
                WHERE [POINTGEOLOGY].[NAME] IN ('Geo_LoggedBy', 'MajorLith', 'MinorLith', 'Rock_pct', 'RockType')
                GROUP BY [POINTGEOLOGY].[SAMPLEID]
            ) [POINTGEOLOGY] 
                ON [SAMPLE].[SAMPLEID] = [POINTGEOLOGY].[SAMPLEID]
        ) [ACQDERIVEDVIEW]
    ) [ACQTMP]
);
GO
