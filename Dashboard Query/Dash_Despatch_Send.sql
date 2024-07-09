USE [ACQ_WEDABAY];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW [dbo].[DASH_DESPATCHSEND] AS
(
    SELECT TOP 100 PERCENT *
    FROM
    (
        SELECT TOP 100 PERCENT 
            [DESPATCHNO], 
            [LABCODE], 
            [SENDDATE],
            (
                SELECT COUNT(SAMPLEID)
                FROM dbo.QV_SAMPLE_CHECK_DESPATCH
                WHERE DESPATCHNO = [ACQDERIVEDVIEW].[DESPATCHNO]
                AND DUPLICATENO = 'PRIMARY'
            ) AS [TotalPrimarySamples_D],
            (
                SELECT COUNT(DISTINCT SCA.SAMPLEID)
                FROM dbo.QV_CORP_SAMPLE_CHECK_ASSAY_CMB SCA
                JOIN dbo.QV_SAMPLE_CHECK_DESPATCH DP
                ON SCA.SAMPLEID = DP.SAMPLEID AND SCA.DUPLICATENO = DP.DUPLICATENO
                WHERE DP.DESPATCHNO = [ACQDERIVEDVIEW].[DESPATCHNO] 
                AND SCA.DUPLICATENO = 'PRIMARY'
            ) AS [TotalPrimaryAssays_D],
            (
                SELECT COUNT(SAMPLEID)
                FROM dbo.QV_SAMPLE_CHECK_DESPATCH
                WHERE DESPATCHNO = [ACQDERIVEDVIEW].[DESPATCHNO]
                AND DUPLICATENO NOT LIKE '%LAB%'
                AND DUPLICATENO NOT LIKE 'PRIMARY'
                AND SAMPLEID NOT LIKE '%WBRM%'
            ) AS [TotalCheckSamples_DD],
            (
                SELECT COUNT(DISTINCT SCA.SAMPLEID)
                FROM dbo.QV_CORP_SAMPLE_CHECK_ASSAY_CMB SCA
                JOIN dbo.QV_SAMPLE_CHECK_DESPATCH DP
                ON SCA.SAMPLEID = DP.SAMPLEID AND SCA.DUPLICATENO = DP.DUPLICATENO
                WHERE DP.DESPATCHNO = [ACQDERIVEDVIEW].[DESPATCHNO] 
                AND SCA.DUPLICATENO NOT LIKE '%LAB%'
                AND SCA.DUPLICATENO NOT LIKE 'PRIMARY'
                AND SCA.SAMPLEID NOT LIKE '%WBRM%'
            ) AS [TotalCheckAssays_DD],
            (
                SELECT COUNT(SAMPLEID)
                FROM dbo.QV_SAMPLE_CHECK_DESPATCH
                WHERE DESPATCHNO = [ACQDERIVEDVIEW].[DESPATCHNO] 
                AND DUPLICATENO NOT LIKE '%LAB%'
                AND SAMPLEID NOT LIKE '%WBRM%'
            ) AS [TotalSamples_DD],
            (
                SELECT COUNT(DISTINCT SCA.SAMPLEID)
                FROM dbo.QV_CORP_SAMPLE_CHECK_ASSAY_CMB SCA
                JOIN dbo.QV_SAMPLE_CHECK_DESPATCH DP
                ON SCA.SAMPLEID = DP.SAMPLEID AND SCA.DUPLICATENO = DP.DUPLICATENO
                WHERE DP.DESPATCHNO = [ACQDERIVEDVIEW].[DESPATCHNO] 
                AND SCA.DUPLICATENO NOT LIKE '%LAB%'
                AND SCA.SAMPLEID NOT LIKE '%WBRM%'
            ) AS [TotalAssays_DD]
        FROM
        (
            SELECT 
                [DESPATCHSEND].[DESPATCHNO] AS [DESPATCHNO], 
                [DESPATCHSEND].[LABCODE], 
                [DESPATCHSEND].[SENDDATE]
            FROM 
                [DESPATCHSEND]
        ) [ACQDERIVEDVIEW]
    ) [ACQTMP]
);
GO
