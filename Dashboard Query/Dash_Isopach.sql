USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_ISOPACH] AS
(
    SELECT TOP 100 PERCENT *
    FROM
    (
        SELECT TOP 100 PERCENT 
            [PROJECTCODE], 
            [HOLEID], 
            [SAMPLEID], 
            [SAMPFROM], 
            [SAMPTO],  
            ([ACQDERIVEDVIEW].[SAMPTO] - [ACQDERIVEDVIEW].[SAMPFROM]) AS [Samp_Interval_DD],  
            (
                CASE 
                    WHEN CAST(CAST([ACQDERIVEDVIEW].[Samp_Length] AS FLOAT) AS FLOAT) * 100 > 100 THEN 100 
                    ELSE CAST(CAST([ACQDERIVEDVIEW].[Samp_Length] AS FLOAT) AS FLOAT) * 100 
                END
            ) AS [Samp_Rec_pct_D], 
            [Ni_AAS-XRF_pct], 
            [Ni_XRF_pct],  
            (
                SELECT 
                    CASE 
                        WHEN CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) = 0 AND CAST([ACQDERIVEDVIEW].[MgO_XRF_pct] AS FLOAT) = 0 THEN 
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
                    END  
            ) AS [Ore_Limit_D]
        FROM
        (
            SELECT 
                [SAMPLE].[PROJECTCODE], 
                [SAMPLE].[HOLEID], 
                [SAMPLE].[SAMPLEID] AS [SAMPLEID], 
                [SAMPLE].[SAMPFROM], 
                [SAMPLE].[SAMPTO], 
                [CORPSAMPLEASSAY_N].[Ni_AAS-XRF_pct], 
                [CORPSAMPLEASSAY_N].[Ni_XRF_pct], 
                CAST([SAMPLEDETAILS].[Samp_Length] AS FLOAT) AS [Samp_Length], 
                [POINTGEOLOGY].[MajorLith], 
                [CORPSAMPLEASSAY_N].[MgO_XRF_pct]
            FROM [SAMPLE]
            INNER JOIN DASH_ISOPACH_WSF ON [DASH_ISOPACH_WSF].[HOLEID] = [SAMPLE].[HOLEID] 
            AND [DASH_ISOPACH_WSF].[PROJECTCODE] = [SAMPLE].[PROJECTCODE] 
            AND [DASH_ISOPACH_WSF].[HOLETYPE] = 'DRILLHOLE'
            LEFT JOIN 
            (
                SELECT 
                    [CORPSAMPLEASSAY_N].[SAMPLEID], 
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'Ni_AAS-XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [Ni_AAS-XRF_pct], 
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'Ni_XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [Ni_XRF_pct], 
                    MIN(CASE WHEN [CORPSAMPLEASSAY_N].[NAME] = 'MgO_XRF_pct' THEN [CORPSAMPLEASSAY_N].[VALUE] ELSE NULL END) AS [MgO_XRF_pct]
                FROM [CORPSAMPLEASSAY_N]
                WHERE [CORPSAMPLEASSAY_N].[NAME] IN ('Ni_AAS-XRF_pct', 'Ni_XRF_pct', 'MgO_XRF_pct')
                GROUP BY [CORPSAMPLEASSAY_N].[SAMPLEID]
            ) [CORPSAMPLEASSAY_N] ON [SAMPLE].[SAMPLEID] = [CORPSAMPLEASSAY_N].[SAMPLEID]
            LEFT JOIN 
            (
                SELECT 
                    [SAMPLEDETAILS].[SAMPLEID], 
                    MIN(CASE WHEN [SAMPLEDETAILS].[NAME] = 'Samp_Length' THEN CAST([SAMPLEDETAILS].[VALUE] AS FLOAT) ELSE NULL END) AS [Samp_Length]
                FROM [SAMPLEDETAILS]
                WHERE [SAMPLEDETAILS].[NAME] IN ('Samp_Length')
                GROUP BY [SAMPLEDETAILS].[SAMPLEID]
            ) [SAMPLEDETAILS] ON [SAMPLE].[SAMPLEID] = [SAMPLEDETAILS].[SAMPLEID]
            LEFT JOIN 
            (
                SELECT 
                    [POINTGEOLOGY].[SAMPLEID], 
                    MIN(CASE WHEN [POINTGEOLOGY].[NAME] = 'MajorLith' THEN [POINTGEOLOGY].[VALUE] ELSE NULL END) AS [MajorLith]
                FROM [POINTGEOLOGY]
                WHERE [POINTGEOLOGY].[NAME] IN ('MajorLith')
                GROUP BY [POINTGEOLOGY].[SAMPLEID]
            ) [POINTGEOLOGY] ON [SAMPLE].[SAMPLEID] = [POINTGEOLOGY].[SAMPLEID]
        ) [ACQDERIVEDVIEW]
    ) [ACQTMP]
    ORDER BY [HOLEID] ASC
);
GO
