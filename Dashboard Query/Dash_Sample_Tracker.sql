USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_SAMPLE_TRACKER] AS
(
    SELECT 
        [DespatchNo_DD] AS [DespatchNo],
        [HOLEID] AS [HOLEID],
        [PROJECTCODE] AS [PROJECTCODE],
        [HOLETYPE] AS [HOLETYPE],
        [Con_Sample_Status] AS [Sample status],
        [Con_Ready_Field_Date] AS [Ready on the Field],
        [Con_Camp_Date] AS [Camp contractor],
        [Con_Collection_Date] AS [At the collection Point],
        [Con_Sent_WBN_Date] AS [Sent to WBN],
        [PROSPECT] AS [Prospect],
        [Total_Samples_D] AS [Total Samples]
    FROM 
    (
        SELECT TOP 100 PERCENT *
        FROM 
        (
            SELECT TOP 100 PERCENT
                dbo.QFN_COLLAR_DESPATCH_LIST([ACQDERIVEDVIEW].[HOLEID], [ACQDERIVEDVIEW].[PROJECTCODE], 'DESPATCHNO', ',') AS [DespatchNo_DD],
                [HOLEID],
                [PROJECTCODE],
                [HOLETYPE],
                [Con_Sample_Status],
                [Con_Ready_Field_Date],
                [Con_Camp_Date],
                [Con_Collection_Date],
                [Con_Sent_WBN_Date],
                [PROSPECT],
                (
                    SELECT COUNT(SAMPLEID)
                    FROM dbo.SAMPLE
                    WHERE HOLEID = [ACQDERIVEDVIEW].[HOLEID]
                        AND PROJECTCODE = [ACQDERIVEDVIEW].[PROJECTCODE]
                ) AS [Total_Samples_D]
            FROM 
            (
                SELECT 
                    [HOLELOCATION].[HOLEID] AS [HOLEID],
                    [HOLELOCATION].[PROJECTCODE] AS [PROJECTCODE],
                    [HOLELOCATION].[HOLETYPE],
                    [HOLEDETAILS].[Con_Sample_Status],
                    [HOLEDETAILS].[Con_Ready_Field_Date],
                    [HOLEDETAILS].[Con_Camp_Date],
                    [HOLEDETAILS].[Con_Collection_Date],
                    [HOLEDETAILS].[Con_Sent_WBN_Date],
                    [HOLELOCATION].[PROSPECT]
                FROM [HOLELOCATION]
                INNER JOIN DASH_SAMPLE_TRACKER_WSF 
                    ON [DASH_SAMPLE_TRACKER_WSF].[HOLEID] = [HOLELOCATION].[HOLEID]
                    AND [DASH_SAMPLE_TRACKER_WSF].[PROJECTCODE] = [HOLELOCATION].[PROJECTCODE]
                LEFT JOIN 
                (
                    SELECT 
                        [HOLEDETAILS].[HOLEID],
                        [HOLEDETAILS].[PROJECTCODE],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Con_Sample_Status' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Con_Sample_Status],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Con_Ready_Field_Date' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Con_Ready_Field_Date],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Con_Camp_Date' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Con_Camp_Date],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Con_Collection_Date' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Con_Collection_Date],
                        MIN(CASE WHEN [HOLEDETAILS].[NAME] = 'Con_Sent_WBN_Date' THEN [HOLEDETAILS].[VALUE] ELSE NULL END) AS [Con_Sent_WBN_Date]
                    FROM [HOLEDETAILS]
                    WHERE [HOLEDETAILS].[NAME] IN ('Con_Sample_Status', 'Con_Ready_Field_Date', 'Con_Camp_Date', 'Con_Collection_Date', 'Con_Sent_WBN_Date')
                    GROUP BY [HOLEDETAILS].[PROJECTCODE], [HOLEDETAILS].[HOLEID]
                ) [HOLEDETAILS]
                    ON [HOLELOCATION].[PROJECTCODE] = [HOLEDETAILS].[PROJECTCODE]
                    AND [HOLELOCATION].[HOLEID] = [HOLEDETAILS].[HOLEID]
            ) [ACQDERIVEDVIEW]
        ) [ACQTMP]
        WHERE [Con_Sample_Status] IS NOT NULL
            AND [HOLETYPE] = 'DRILLHOLE'
    ) AS [DASH_SAMPLE_TRACKER]
);
GO
