# Insightia - Unused Indexes to Drop

Zero seeks, zero scans and zero lookups on **both the primary and the readable secondary**.
Primary keys, unique indexes and unique constraints are excluded.

> **Readable secondary checked - list unchanged.**
>
> Secondary usage was collected and unioned per index (join matched 163/163 activist and 88/88
> proxy read-bearing indexes, zero unmatched). **Not one of the indexes below shows any read on the
> secondary.** Every index that the secondary does use is also used on the primary.
>
> Effective evidence window is now **105 days** (2026-05-20 -> 2026-09-02): the secondary's DMVs
> reset later than the primary's, so its shorter window governs. Still short of an annual cycle -
> the `*_backup` and `tblvoting_data_ready_to_process_*` caveats below still apply.

**Disable first - it is instant, reversible, and frees the space. Only drop after a full
business cycle with no regression.** The rollback rebuild is listed under each entry.

Caveats before running any of this:

- 115 days covers a quarter but **not an annual cycle**. Tables named `*_backup` and the
  year-partitioned `tblvoting_data_ready_to_process_*` family are the most likely to be
  touched by an annual process. Confirm those first.
- Usage DMVs do not record foreign key enforcement, replication, CDC or Change Tracking
  dependencies. Verify before dropping.
- Undoing a DISABLE is a full index build. On the multi-GB entries that is significant AG
  log generation - schedule inside the maintenance window.
- A few of these also appear in `index-recommendations.md` Part 3 as consolidation drops.

---

## activist_insight

93 unused indexes, 105.5 GB, carrying 389,015,351 index updates.

```sql
USE activist_insight;
GO

-- tblvoting_import_audit.IX_tblvoting_import_audit_insert_by | 19,575 MB | 319,163,018 rows
-- KEY (insert_by, insert_date)
-- 21,968,280 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_import_audit_insert_by] ON [dbo].[tblvoting_import_audit] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_import_audit_insert_by] ON [dbo].[tblvoting_import_audit];
--   rollback   : ALTER INDEX [IX_tblvoting_import_audit_insert_by] ON [dbo].[tblvoting_import_audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblFeed_data_backup.feed_idx_table_id_times | 18,310 MB | 460,018,874 rows
-- KEY (table_id, times) INCLUDE (unique_id, feed_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [feed_idx_table_id_times] ON [dbo].[tblFeed_data_backup] DISABLE;
--   drop later : DROP INDEX [feed_idx_table_id_times] ON [dbo].[tblFeed_data_backup];
--   rollback   : ALTER INDEX [feed_idx_table_id_times] ON [dbo].[tblFeed_data_backup] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblFeed_data_backup.NonClusteredIndex-20210621-092130 | 15,756 MB | 460,018,874 rows
-- KEY (table_id, times) INCLUDE (feed_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20210621-092130] ON [dbo].[tblFeed_data_backup] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20210621-092130] ON [dbo].[tblFeed_data_backup];
--   rollback   : ALTER INDEX [NonClusteredIndex-20210621-092130] ON [dbo].[tblFeed_data_backup] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblFeed_data_backup.feed_idx_table_id_times_feed | 15,688 MB | 460,018,874 rows
-- KEY (feed_id, times, table_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [feed_idx_table_id_times_feed] ON [dbo].[tblFeed_data_backup] DISABLE;
--   drop later : DROP INDEX [feed_idx_table_id_times_feed] ON [dbo].[tblFeed_data_backup];
--   rollback   : ALTER INDEX [feed_idx_table_id_times_feed] ON [dbo].[tblFeed_data_backup] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_import_audit.IX_tblvoting_import_audit_action_id | 12,521 MB | 319,163,018 rows
-- KEY (action_id, insert_date)
-- 21,968,280 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_import_audit_action_id] ON [dbo].[tblvoting_import_audit] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_import_audit_action_id] ON [dbo].[tblvoting_import_audit];
--   rollback   : ALTER INDEX [IX_tblvoting_import_audit_action_id] ON [dbo].[tblvoting_import_audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblStock_values.idxStockValues_csinumberDate | 6,408 MB | 154,593,056 rows
-- KEY (csi_number, date) INCLUDE (symbol)
-- 231 index updates absorbed for zero reads.
ALTER INDEX [idxStockValues_csinumberDate] ON [dbo].[tblStock_values] DISABLE;
--   drop later : DROP INDEX [idxStockValues_csinumberDate] ON [dbo].[tblStock_values];
--   rollback   : ALTER INDEX [idxStockValues_csinumberDate] ON [dbo].[tblStock_values] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tbl13f_Holdings_scraped.NonClusteredIndex-20160921-151033 | 5,150 MB | 122,334,200 rows
-- KEY (CUSIP)
-- 5,040,770 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20160921-151033] ON [dbo].[tbl13f_Holdings_scraped] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160921-151033] ON [dbo].[tbl13f_Holdings_scraped];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160921-151033] ON [dbo].[tbl13f_Holdings_scraped] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblReporting_company.NonClusteredIndex-20211005-123935 | 2,078 MB | 40,809,571 rows
-- KEY (apg_letter, apg_page, apg_item, apg_run_no, source, sub_item)
-- 12,020,134 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20211005-123935] ON [dbo].[tblReporting_company] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20211005-123935] ON [dbo].[tblReporting_company];
--   rollback   : ALTER INDEX [NonClusteredIndex-20211005-123935] ON [dbo].[tblReporting_company] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblReporting_company.idx_Reporting_company_forDelete | 1,875 MB | 40,809,571 rows
-- KEY (apg_page, apg_item, source, apg_run_no)
-- 12,020,134 index updates absorbed for zero reads.
ALTER INDEX [idx_Reporting_company_forDelete] ON [dbo].[tblReporting_company] DISABLE;
--   drop later : DROP INDEX [idx_Reporting_company_forDelete] ON [dbo].[tblReporting_company];
--   rollback   : ALTER INDEX [idx_Reporting_company_forDelete] ON [dbo].[tblReporting_company] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblUser_PageLog.idx_user_id_query_String | 1,684 MB | 22,553,749 rows
-- KEY (user_id, query_string) INCLUDE (page_name)
-- 230,174 index updates absorbed for zero reads.
ALTER INDEX [idx_user_id_query_String] ON [dbo].[tblUser_PageLog] DISABLE;
--   drop later : DROP INDEX [idx_user_id_query_String] ON [dbo].[tblUser_PageLog];
--   rollback   : ALTER INDEX [idx_user_id_query_String] ON [dbo].[tblUser_PageLog] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblUser_PageLog.idx_user_pagelog_page_name | 1,551 MB | 22,553,749 rows
-- KEY (page_name) INCLUDE (user_id, access_date)
-- 230,174 index updates absorbed for zero reads.
ALTER INDEX [idx_user_pagelog_page_name] ON [dbo].[tblUser_PageLog] DISABLE;
--   drop later : DROP INDEX [idx_user_pagelog_page_name] ON [dbo].[tblUser_PageLog];
--   rollback   : ALTER INDEX [idx_user_pagelog_page_name] ON [dbo].[tblUser_PageLog] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblApp_log.idx_tblApp_Log_1 | 1,328 MB | 16,342,213 rows
-- KEY (app, date_time) INCLUDE (event)
-- 624,873 index updates absorbed for zero reads.
ALTER INDEX [idx_tblApp_Log_1] ON [dbo].[tblApp_log] DISABLE;
--   drop later : DROP INDEX [idx_tblApp_Log_1] ON [dbo].[tblApp_log];
--   rollback   : ALTER INDEX [idx_tblApp_Log_1] ON [dbo].[tblApp_log] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_Sync.IX_tVoting_Sync_AllComplete | 870 MB | 18,069,134 rows
-- KEY (InsertDate) INCLUDE (InvestorID, MeetingID, MeetingYear)
-- 201,356 index updates absorbed for zero reads. FILTERED: ([BySourceComplete]=(1) AND [FundVoteComplete]=(1) AND [FundVoteNonNPXComplete]=(1) AND [InvestorVoteComplete]=(1) AND [InvestorVoteNPXComplete]=(1) AND [InvestorVoteNonNPXComplete]=(1) AND [InvestorVoteNPXThresholdComplete]=(1)).
ALTER INDEX [IX_tVoting_Sync_AllComplete] ON [dbo].[tVoting_Sync] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_Sync_AllComplete] ON [dbo].[tVoting_Sync];
--   rollback   : ALTER INDEX [IX_tVoting_Sync_AllComplete] ON [dbo].[tVoting_Sync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblFundamental_metric_values_historic.NonClusteredIndex-20160318-100944 | 788 MB | 22,059,562 rows
-- KEY (value)
-- 18,790 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20160318-100944] ON [dbo].[tblFundamental_metric_values_historic] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160318-100944] ON [dbo].[tblFundamental_metric_values_historic];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160318-100944] ON [dbo].[tblFundamental_metric_values_historic] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_alert_companies_precalc.NonClusteredIndex-20190213-164606 | 753 MB | 27,741,417 rows
-- KEY (alert_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20190213-164606] ON [dbo].[tblV2a_alert_companies_precalc] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20190213-164606] ON [dbo].[tblV2a_alert_companies_precalc];
--   rollback   : ALTER INDEX [NonClusteredIndex-20190213-164606] ON [dbo].[tblV2a_alert_companies_precalc] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblFundamental_metric_values_historic.NonClusteredIndex-20160318-100853 | 477 MB | 22,059,562 rows
-- KEY (metric_id)
-- 18,790 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20160318-100853] ON [dbo].[tblFundamental_metric_values_historic] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160318-100853] ON [dbo].[tblFundamental_metric_values_historic];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160318-100853] ON [dbo].[tblFundamental_metric_values_historic] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_alert_inbox.idx_tblV2a_alert_inbox_v2_alerter_app | 475 MB | 19,356,530 rows
-- KEY (alert_id, table_id, filing_alert_type) INCLUDE (alert_inbox_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblV2a_alert_inbox_v2_alerter_app] ON [dbo].[tblV2a_alert_inbox] DISABLE;
--   drop later : DROP INDEX [idx_tblV2a_alert_inbox_v2_alerter_app] ON [dbo].[tblV2a_alert_inbox];
--   rollback   : ALTER INDEX [idx_tblV2a_alert_inbox_v2_alerter_app] ON [dbo].[tblV2a_alert_inbox] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblFundamental_metric_year_values.NonClusteredIndex-20170406-123706 | 441 MB | 5,928,341 rows
-- KEY (metric_id, CIK_Id, year) INCLUDE (value)
-- 311,460,101 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20170406-123706] ON [dbo].[tblFundamental_metric_year_values] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20170406-123706] ON [dbo].[tblFundamental_metric_year_values];
--   rollback   : ALTER INDEX [NonClusteredIndex-20170406-123706] ON [dbo].[tblFundamental_metric_year_values] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_alert_activists_precalc.idx_cover_activist_id | 397 MB | 12,811,282 rows
-- KEY (activist_id) INCLUDE (alert_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_cover_activist_id] ON [dbo].[tblV2a_alert_activists_precalc] DISABLE;
--   drop later : DROP INDEX [idx_cover_activist_id] ON [dbo].[tblV2a_alert_activists_precalc];
--   rollback   : ALTER INDEX [idx_cover_activist_id] ON [dbo].[tblV2a_alert_activists_precalc] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- raw_NPX_tblReporting_votes_Stage.Idx_raw_NPX_tblReporting_votes_Stage_1 | 383 MB | 21,965,815 rows
-- KEY (reporting_company_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [Idx_raw_NPX_tblReporting_votes_Stage_1] ON [dbo].[raw_NPX_tblReporting_votes_Stage] DISABLE;
--   drop later : DROP INDEX [Idx_raw_NPX_tblReporting_votes_Stage_1] ON [dbo].[raw_NPX_tblReporting_votes_Stage];
--   rollback   : ALTER INDEX [Idx_raw_NPX_tblReporting_votes_Stage_1] ON [dbo].[raw_NPX_tblReporting_votes_Stage] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_alert_activists_precalc.NonClusteredIndex-20190213-164352 | 348 MB | 12,811,282 rows
-- KEY (alert_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20190213-164352] ON [dbo].[tblV2a_alert_activists_precalc] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20190213-164352] ON [dbo].[tblV2a_alert_activists_precalc];
--   rollback   : ALTER INDEX [NonClusteredIndex-20190213-164352] ON [dbo].[tblV2a_alert_activists_precalc] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_data_external.idx_temporary_tblVoting_data_external | 233 MB | 917,587 rows
-- KEY (investor_identifier, meeting_identifier) INCLUDE (fund_name, proposal_identifier, Proposal_number, row_order, proposal_text, proponent, mgmt_rec)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_temporary_tblVoting_data_external] ON [dbo].[tblVoting_data_external] DISABLE;
--   drop later : DROP INDEX [idx_temporary_tblVoting_data_external] ON [dbo].[tblVoting_data_external];
--   rollback   : ALTER INDEX [idx_temporary_tblVoting_data_external] ON [dbo].[tblVoting_data_external] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_data_external.NonClusteredIndex-20220406-103604 | 205 MB | 917,587 rows
-- KEY (investor_identifier, fund_identifier) INCLUDE (company_identifier, company_name, meeting_identifier, meeting_date, Country, Meeting_type, Ticker, ISIN, SEDOL, CUSIP, fund_name)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20220406-103604] ON [dbo].[tblVoting_data_external] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20220406-103604] ON [dbo].[tblVoting_data_external];
--   rollback   : ALTER INDEX [NonClusteredIndex-20220406-103604] ON [dbo].[tblVoting_data_external] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_data_external.NonClusteredIndex-20220406-110818 | 96 MB | 917,587 rows
-- KEY (meeting_identifier) INCLUDE (fund_name)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20220406-110818] ON [dbo].[tblVoting_data_external] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20220406-110818] ON [dbo].[tblVoting_data_external];
--   rollback   : ALTER INDEX [NonClusteredIndex-20220406-110818] ON [dbo].[tblVoting_data_external] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_data_external.NonClusteredIndex-20220406-165846 | 93 MB | 917,587 rows
-- KEY (proposal_identifier, fund_name) INCLUDE (vote_instruction)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20220406-165846] ON [dbo].[tblVoting_data_external] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20220406-165846] ON [dbo].[tblVoting_data_external];
--   rollback   : ALTER INDEX [NonClusteredIndex-20220406-165846] ON [dbo].[tblVoting_data_external] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_Import.IX_stgDHI_CGS_Import_IssueStatus | 85 MB | 1,490,463 rows
-- KEY (IssueStatus) INCLUDE (PID, CUSIP, ISIN)
-- 844,153 index updates absorbed for zero reads. FILTERED: ([IssueStatus] IS NOT NULL).
ALTER INDEX [IX_stgDHI_CGS_Import_IssueStatus] ON [dbo].[stgDHI_CGS_Import] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_Import_IssueStatus] ON [dbo].[stgDHI_CGS_Import];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_Import_IssueStatus] ON [dbo].[stgDHI_CGS_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- raw_NPX_tblReporting_company_Stage.Idx_raw_NPX_tblReporting_company_Stage_1 | 79 MB | 2,803,803 rows
-- KEY (prod_reporting_company_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [Idx_raw_NPX_tblReporting_company_Stage_1] ON [dbo].[raw_NPX_tblReporting_company_Stage] DISABLE;
--   drop later : DROP INDEX [Idx_raw_NPX_tblReporting_company_Stage_1] ON [dbo].[raw_NPX_tblReporting_company_Stage];
--   rollback   : ALTER INDEX [Idx_raw_NPX_tblReporting_company_Stage_1] ON [dbo].[raw_NPX_tblReporting_company_Stage] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_Import.IX_stgDHI_CGS_Import_IssueLogDate | 61 MB | 1,490,463 rows
-- KEY (IssueLogDate)
-- 844,153 index updates absorbed for zero reads. FILTERED: ([IssueLogDate] IS NOT NULL).
ALTER INDEX [IX_stgDHI_CGS_Import_IssueLogDate] ON [dbo].[stgDHI_CGS_Import] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_Import_IssueLogDate] ON [dbo].[stgDHI_CGS_Import];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_Import_IssueLogDate] ON [dbo].[stgDHI_CGS_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSessions.idx_user_id_session_last | 57 MB | 1,667,706 rows
-- KEY (user_id) INCLUDE (session_last)
-- 271,275 index updates absorbed for zero reads.
ALTER INDEX [idx_user_id_session_last] ON [dbo].[tblSessions] DISABLE;
--   drop later : DROP INDEX [idx_user_id_session_last] ON [dbo].[tblSessions];
--   rollback   : ALTER INDEX [idx_user_id_session_last] ON [dbo].[tblSessions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_Import.IX_stgDHI_CGS_Import_RequestDate | 56 MB | 1,493,549 rows
-- KEY (RequestDate)
-- 844,153 index updates absorbed for zero reads.
ALTER INDEX [IX_stgDHI_CGS_Import_RequestDate] ON [dbo].[stgDHI_CGS_Import] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_Import_RequestDate] ON [dbo].[stgDHI_CGS_Import];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_Import_RequestDate] ON [dbo].[stgDHI_CGS_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblScraped_items.NonClusteredIndex-20160315-113448 | 34 MB | 2,154,738 rows
-- KEY (additional_detail)
-- 47,594 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20160315-113448] ON [dbo].[tblScraped_items] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160315-113448] ON [dbo].[tblScraped_items];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160315-113448] ON [dbo].[tblScraped_items] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_Sync_Status.IX_tVoting_Sync_Status_Investor_Year | 30 MB | 384,095 rows
-- KEY (InvestorID, MeetingYear, SyncType, RunID) INCLUDE (SyncStatus, StartTime, EndTime)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tVoting_Sync_Status_Investor_Year] ON [dbo].[tVoting_Sync_Status] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_Sync_Status_Investor_Year] ON [dbo].[tVoting_Sync_Status];
--   rollback   : ALTER INDEX [IX_tVoting_Sync_Status_Investor_Year] ON [dbo].[tVoting_Sync_Status] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_Sync_Status.IX_tVoting_Sync_Status_Run_Type | 29 MB | 384,095 rows
-- KEY (RunID, SyncType, SyncStatus) INCLUDE (InvestorID, MeetingYear, RowsInserted, RowsUpdated, RowsDeleted)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tVoting_Sync_Status_Run_Type] ON [dbo].[tVoting_Sync_Status] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_Sync_Status_Run_Type] ON [dbo].[tVoting_Sync_Status];
--   rollback   : ALTER INDEX [IX_tVoting_Sync_Status_Run_Type] ON [dbo].[tVoting_Sync_Status] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblISC_data_Xignite_old.NonClusteredIndex-20181025-164555 | 17 MB | 323,027 rows
-- KEY (instant_date, Isin) INCLUDE (value, cik)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20181025-164555] ON [dbo].[tblISC_data_Xignite_old] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20181025-164555] ON [dbo].[tblISC_data_Xignite_old];
--   rollback   : ALTER INDEX [NonClusteredIndex-20181025-164555] ON [dbo].[tblISC_data_Xignite_old] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCeresShareholderData.IX_tblCeresShareholderData_company_name_proposal_meeting_status | 15 MB | 145,225 rows
-- KEY (company_name, proposal, meeting_status)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tblCeresShareholderData_company_name_proposal_meeting_status] ON [dbo].[tblCeresShareholderData] DISABLE;
--   drop later : DROP INDEX [IX_tblCeresShareholderData_company_name_proposal_meeting_status] ON [dbo].[tblCeresShareholderData];
--   rollback   : ALTER INDEX [IX_tblCeresShareholderData_company_name_proposal_meeting_status] ON [dbo].[tblCeresShareholderData] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_audit.idx_tblCompany_audit_timestamp | 12 MB | 334,479 rows
-- KEY (audit_timestamp)
-- 94,323 index updates absorbed for zero reads.
ALTER INDEX [idx_tblCompany_audit_timestamp] ON [dbo].[tblCompany_audit] DISABLE;
--   drop later : DROP INDEX [idx_tblCompany_audit_timestamp] ON [dbo].[tblCompany_audit];
--   rollback   : ALTER INDEX [idx_tblCompany_audit_timestamp] ON [dbo].[tblCompany_audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_audit.idx_tblCompany_audit_PID | 12 MB | 326,093 rows
-- KEY (PID)
-- 94,323 index updates absorbed for zero reads. FILTERED: ([PID] IS NOT NULL).
ALTER INDEX [idx_tblCompany_audit_PID] ON [dbo].[tblCompany_audit] DISABLE;
--   drop later : DROP INDEX [idx_tblCompany_audit_PID] ON [dbo].[tblCompany_audit];
--   rollback   : ALTER INDEX [idx_tblCompany_audit_PID] ON [dbo].[tblCompany_audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_audit.idx_tblCompany_audit_action | 10 MB | 334,479 rows
-- KEY (audit_action)
-- 94,323 index updates absorbed for zero reads.
ALTER INDEX [idx_tblCompany_audit_action] ON [dbo].[tblCompany_audit] DISABLE;
--   drop later : DROP INDEX [idx_tblCompany_audit_action] ON [dbo].[tblCompany_audit];
--   rollback   : ALTER INDEX [idx_tblCompany_audit_action] ON [dbo].[tblCompany_audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tbl13f_Filer_Info_Scraped.Idx_13fFiler_info_amendment | 7 MB | 320,771 rows
-- KEY (Amendment_num)
-- 14,114 index updates absorbed for zero reads.
ALTER INDEX [Idx_13fFiler_info_amendment] ON [dbo].[tbl13f_Filer_Info_Scraped] DISABLE;
--   drop later : DROP INDEX [Idx_13fFiler_info_amendment] ON [dbo].[tbl13f_Filer_Info_Scraped];
--   rollback   : ALTER INDEX [Idx_13fFiler_info_amendment] ON [dbo].[tbl13f_Filer_Info_Scraped] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_FundVote_BySource_Exception.IX_tVoting_FundVote_BySource_Exception_meeting_date | 4 MB | 22,075 rows
-- KEY (meeting_date, resolution_status) INCLUDE (import_check_id, exception_reason, exception_category)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tVoting_FundVote_BySource_Exception_meeting_date] ON [dbo].[tVoting_FundVote_BySource_Exception] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_FundVote_BySource_Exception_meeting_date] ON [dbo].[tVoting_FundVote_BySource_Exception];
--   rollback   : ALTER INDEX [IX_tVoting_FundVote_BySource_Exception_meeting_date] ON [dbo].[tVoting_FundVote_BySource_Exception] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany.idx_status | 3 MB | 80,676 rows
-- KEY (status)
-- 14,995 index updates absorbed for zero reads.
ALTER INDEX [idx_status] ON [dbo].[tblCompany] DISABLE;
--   drop later : DROP INDEX [idx_status] ON [dbo].[tblCompany];
--   rollback   : ALTER INDEX [idx_status] ON [dbo].[tblCompany] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany.idx_industryid | 3 MB | 80,676 rows
-- KEY (industry_id)
-- 21,714 index updates absorbed for zero reads.
ALTER INDEX [idx_industryid] ON [dbo].[tblCompany] DISABLE;
--   drop later : DROP INDEX [idx_industryid] ON [dbo].[tblCompany];
--   rollback   : ALTER INDEX [idx_industryid] ON [dbo].[tblCompany] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblStock_split.NonClusteredIndex-20160920-121059 | 3 MB | 85,750 rows
-- KEY (split_date)
-- 234 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20160920-121059] ON [dbo].[tblStock_split] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160920-121059] ON [dbo].[tblStock_split];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160920-121059] ON [dbo].[tblStock_split] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblStock_split.idx_update_process | 3 MB | 85,750 rows
-- KEY (date_applied, split_date)
-- 234 index updates absorbed for zero reads.
ALTER INDEX [idx_update_process] ON [dbo].[tblStock_split] DISABLE;
--   drop later : DROP INDEX [idx_update_process] ON [dbo].[tblStock_split];
--   rollback   : ALTER INDEX [idx_update_process] ON [dbo].[tblStock_split] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_alerts.NonClusteredIndex-20190208-163220 | 3 MB | 6,464 rows
-- KEY (created, send_filing_alerts, alert_paused) INCLUDE (alert_id, company_query)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20190208-163220] ON [dbo].[tblV2a_alerts] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20190208-163220] ON [dbo].[tblV2a_alerts];
--   rollback   : ALTER INDEX [NonClusteredIndex-20190208-163220] ON [dbo].[tblV2a_alerts] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_FundVote_BySource_Exception.IX_tVoting_FundVote_BySource_Exception_category_status | 3 MB | 22,075 rows
-- KEY (exception_category, resolution_status) INCLUDE (import_check_id, fund_id, new_proposal_id, exception_reason, insert_date)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tVoting_FundVote_BySource_Exception_category_status] ON [dbo].[tVoting_FundVote_BySource_Exception] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_FundVote_BySource_Exception_category_status] ON [dbo].[tVoting_FundVote_BySource_Exception];
--   rollback   : ALTER INDEX [IX_tVoting_FundVote_BySource_Exception_category_status] ON [dbo].[tVoting_FundVote_BySource_Exception] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_FundVote_BySource_Exception.IX_tVoting_FundVote_BySource_Exception_import_check_id | 3 MB | 22,075 rows
-- KEY (import_check_id) INCLUDE (exception_reason, exception_category, resolution_status, insert_date)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tVoting_FundVote_BySource_Exception_import_check_id] ON [dbo].[tVoting_FundVote_BySource_Exception] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_FundVote_BySource_Exception_import_check_id] ON [dbo].[tVoting_FundVote_BySource_Exception];
--   rollback   : ALTER INDEX [IX_tVoting_FundVote_BySource_Exception_import_check_id] ON [dbo].[tVoting_FundVote_BySource_Exception] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_Sync_Status.IX_tVoting_Sync_Status_Pending | 2 MB | 29,558 rows
-- KEY (RunID, SyncType, SyncStatus, InvestorID, MeetingYear)
-- never touched at all since the DMV reset - no reads and no writes. FILTERED: ([SyncStatus] IN ('Pending', 'Failed')).
ALTER INDEX [IX_tVoting_Sync_Status_Pending] ON [dbo].[tVoting_Sync_Status] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_Sync_Status_Pending] ON [dbo].[tVoting_Sync_Status];
--   rollback   : ALTER INDEX [IX_tVoting_Sync_Status_Pending] ON [dbo].[tVoting_Sync_Status] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tvoting_votesync.IX_tvoting_votesync_fund_proposal | 2 MB | 25,296 rows
-- KEY (fund_id, proposal_id) INCLUDE (datasource_id, vote_cast, vote_id, year, operation_type, insert_date)
-- 56 index updates absorbed for zero reads.
ALTER INDEX [IX_tvoting_votesync_fund_proposal] ON [dbo].[tvoting_votesync] DISABLE;
--   drop later : DROP INDEX [IX_tvoting_votesync_fund_proposal] ON [dbo].[tvoting_votesync];
--   rollback   : ALTER INDEX [IX_tvoting_votesync_fund_proposal] ON [dbo].[tvoting_votesync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tvoting_votesync.IX_tvoting_votesync_datasource_year_operation | 2 MB | 25,296 rows
-- KEY (datasource_id, year, operation_type) INCLUDE (fund_id, proposal_id, vote_cast, vote_id, insert_date)
-- 56 index updates absorbed for zero reads.
ALTER INDEX [IX_tvoting_votesync_datasource_year_operation] ON [dbo].[tvoting_votesync] DISABLE;
--   drop later : DROP INDEX [IX_tvoting_votesync_datasource_year_operation] ON [dbo].[tvoting_votesync];
--   rollback   : ALTER INDEX [IX_tvoting_votesync_datasource_year_operation] ON [dbo].[tvoting_votesync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblrecent_downloads_pdf.IX_tblrecent_downloads_pdf_user_id_expired | 2 MB | 33,431 rows
-- KEY (user_id, expired) INCLUDE (created_date)
-- 3,904 index updates absorbed for zero reads.
ALTER INDEX [IX_tblrecent_downloads_pdf_user_id_expired] ON [dbo].[tblrecent_downloads_pdf] DISABLE;
--   drop later : DROP INDEX [IX_tblrecent_downloads_pdf_user_id_expired] ON [dbo].[tblrecent_downloads_pdf];
--   rollback   : ALTER INDEX [IX_tblrecent_downloads_pdf_user_id_expired] ON [dbo].[tblrecent_downloads_pdf] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tvoting_votesync.IX_tvoting_votesync_insert_date | 2 MB | 25,296 rows
-- KEY (insert_date) INCLUDE (datasource_id, fund_id, proposal_id, vote_cast, vote_id, operation_type)
-- 56 index updates absorbed for zero reads.
ALTER INDEX [IX_tvoting_votesync_insert_date] ON [dbo].[tvoting_votesync] DISABLE;
--   drop later : DROP INDEX [IX_tvoting_votesync_insert_date] ON [dbo].[tvoting_votesync];
--   rollback   : ALTER INDEX [IX_tvoting_votesync_insert_date] ON [dbo].[tvoting_votesync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblNews_company_link.idx_company_id | 2 MB | 56,229 rows
-- KEY (company_id_todel)
-- 3,137 index updates absorbed for zero reads.
ALTER INDEX [idx_company_id] ON [dbo].[tblNews_company_link] DISABLE;
--   drop later : DROP INDEX [idx_company_id] ON [dbo].[tblNews_company_link];
--   rollback   : ALTER INDEX [idx_company_id] ON [dbo].[tblNews_company_link] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_assets.NonClusteredIndex-20161013-121756 | 1 MB | 31,853 rows
-- KEY (assets_date)
-- 1,266 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20161013-121756] ON [dbo].[tblCompany_assets] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20161013-121756] ON [dbo].[tblCompany_assets];
--   rollback   : ALTER INDEX [NonClusteredIndex-20161013-121756] ON [dbo].[tblCompany_assets] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblDetails_Follower_Nightly.idxfollower_symbol | 1 MB | 25,464 rows
-- KEY (symbol)
-- 232 index updates absorbed for zero reads.
ALTER INDEX [idxfollower_symbol] ON [dbo].[tblDetails_Follower_Nightly] DISABLE;
--   drop later : DROP INDEX [idxfollower_symbol] ON [dbo].[tblDetails_Follower_Nightly];
--   rollback   : ALTER INDEX [idxfollower_symbol] ON [dbo].[tblDetails_Follower_Nightly] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_assets.idx_asset_currency | 1 MB | 31,853 rows
-- KEY (currency)
-- 1,266 index updates absorbed for zero reads.
ALTER INDEX [idx_asset_currency] ON [dbo].[tblCompany_assets] DISABLE;
--   drop later : DROP INDEX [idx_asset_currency] ON [dbo].[tblCompany_assets];
--   rollback   : ALTER INDEX [idx_asset_currency] ON [dbo].[tblCompany_assets] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_processed_sf_trigger_company_elements.covidx_tblV2a_processed_sf_trigger_company_elements_processed_sf_trigger | 1 MB | 18 rows
-- KEY (processed_sf_trigger_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [covidx_tblV2a_processed_sf_trigger_company_elements_processed_sf_trigger] ON [dbo].[tblV2a_processed_sf_trigger_company_elements] DISABLE;
--   drop later : DROP INDEX [covidx_tblV2a_processed_sf_trigger_company_elements_processed_sf_trigger] ON [dbo].[tblV2a_processed_sf_trigger_company_elements];
--   rollback   : ALTER INDEX [covidx_tblV2a_processed_sf_trigger_company_elements_processed_sf_trigger] ON [dbo].[tblV2a_processed_sf_trigger_company_elements] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblPublic_Company.IDX_CIK | 0 MB | 14,851 rows
-- KEY (CIK)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IDX_CIK] ON [dbo].[tblPublic_Company] DISABLE;
--   drop later : DROP INDEX [IDX_CIK] ON [dbo].[tblPublic_Company];
--   rollback   : ALTER INDEX [IDX_CIK] ON [dbo].[tblPublic_Company] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tvoting_investorsync.IX_tvoting_investorsync_status | 0 MB | 4,486 rows
-- KEY (investorsyncstatus, year) INCLUDE (investor_id, insert_date)
-- 8,216 index updates absorbed for zero reads.
ALTER INDEX [IX_tvoting_investorsync_status] ON [dbo].[tvoting_investorsync] DISABLE;
--   drop later : DROP INDEX [IX_tvoting_investorsync_status] ON [dbo].[tvoting_investorsync];
--   rollback   : ALTER INDEX [IX_tvoting_investorsync_status] ON [dbo].[tvoting_investorsync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tvoting_investorsync.IX_tvoting_investorsync_insert_date | 0 MB | 4,486 rows
-- KEY (insert_date) INCLUDE (investor_id, year, investorsyncstatus)
-- 8,216 index updates absorbed for zero reads.
ALTER INDEX [IX_tvoting_investorsync_insert_date] ON [dbo].[tvoting_investorsync] DISABLE;
--   drop later : DROP INDEX [IX_tvoting_investorsync_insert_date] ON [dbo].[tvoting_investorsync];
--   rollback   : ALTER INDEX [IX_tvoting_investorsync_insert_date] ON [dbo].[tvoting_investorsync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_Sync_Run.IX_tVoting_Sync_Run_Type_StartTime | 0 MB | 496 rows
-- KEY (SyncType, StartTime) INCLUDE (RunStatus, YearFilter, InvestorFilter, TotalInvestors, CompletedInvestors, FailedInvestors)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_tVoting_Sync_Run_Type_StartTime] ON [dbo].[tVoting_Sync_Run] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_Sync_Run_Type_StartTime] ON [dbo].[tVoting_Sync_Run];
--   rollback   : ALTER INDEX [IX_tVoting_Sync_Run_Type_StartTime] ON [dbo].[tVoting_Sync_Run] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblV2a_alert_companies.NonClusteredIndex-20190208-163708 | 0 MB | 3,361 rows
-- KEY (alert_company_id, alert_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20190208-163708] ON [dbo].[tblV2a_alert_companies] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20190208-163708] ON [dbo].[tblV2a_alert_companies];
--   rollback   : ALTER INDEX [NonClusteredIndex-20190208-163708] ON [dbo].[tblV2a_alert_companies] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblDropped_PID_Map.IX_tblDropped_PID_Map_PID | 0 MB | 381 rows
-- KEY (PID)
-- 5 index updates absorbed for zero reads.
ALTER INDEX [IX_tblDropped_PID_Map_PID] ON [dbo].[tblDropped_PID_Map] DISABLE;
--   drop later : DROP INDEX [IX_tblDropped_PID_Map_PID] ON [dbo].[tblDropped_PID_Map];
--   rollback   : ALTER INDEX [IX_tblDropped_PID_Map_PID] ON [dbo].[tblDropped_PID_Map] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tbllead_link_all.idx_tbllead_link_all_index1 | 0 MB | 201 rows
-- KEY (source_id, wp_form_id, lead_our_field_id) INCLUDE (wp_field_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tbllead_link_all_index1] ON [dbo].[tbllead_link_all] DISABLE;
--   drop later : DROP INDEX [idx_tbllead_link_all_index1] ON [dbo].[tbllead_link_all];
--   rollback   : ALTER INDEX [idx_tbllead_link_all_index1] ON [dbo].[tbllead_link_all] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVulnerability_exceptions.NonClusteredIndex-20161024-184617 | 0 MB | 1,242 rows
-- KEY (key_ratios_entry_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20161024-184617] ON [dbo].[tblVulnerability_exceptions] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20161024-184617] ON [dbo].[tblVulnerability_exceptions];
--   rollback   : ALTER INDEX [NonClusteredIndex-20161024-184617] ON [dbo].[tblVulnerability_exceptions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblASR_Campaign_Link.NonClusteredIndex-20160725-142217 | 0 MB | 1,225 rows
-- KEY (activist_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20160725-142217] ON [dbo].[tblASR_Campaign_Link] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160725-142217] ON [dbo].[tblASR_Campaign_Link];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160725-142217] ON [dbo].[tblASR_Campaign_Link] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblASR_Campaign_Link.NonClusteredIndex-20160725-142205 | 0 MB | 1,225 rows
-- KEY (Campaign_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20160725-142205] ON [dbo].[tblASR_Campaign_Link] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160725-142205] ON [dbo].[tblASR_Campaign_Link];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160725-142205] ON [dbo].[tblASR_Campaign_Link] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tDHI_CGS_ImportRun.IX_tDHI_CGS_ImportRun_ExecutionMode_Status | 0 MB | 211 rows
-- KEY (ExecutionMode, Status)
-- 219 index updates absorbed for zero reads.
ALTER INDEX [IX_tDHI_CGS_ImportRun_ExecutionMode_Status] ON [dbo].[tDHI_CGS_ImportRun] DISABLE;
--   drop later : DROP INDEX [IX_tDHI_CGS_ImportRun_ExecutionMode_Status] ON [dbo].[tDHI_CGS_ImportRun];
--   rollback   : ALTER INDEX [IX_tDHI_CGS_ImportRun_ExecutionMode_Status] ON [dbo].[tDHI_CGS_ImportRun] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_JudgementOutcomeLink.idx_tblSECLitigation_JudgementOutcomeLink_outcomeid | 0 MB | 67 rows
-- KEY (outcome_id, sec_litigation_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_JudgementOutcomeLink_outcomeid] ON [dbo].[tblSECLitigation_JudgementOutcomeLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_JudgementOutcomeLink_outcomeid] ON [dbo].[tblSECLitigation_JudgementOutcomeLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_JudgementOutcomeLink_outcomeid] ON [dbo].[tblSECLitigation_JudgementOutcomeLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tREF_VoteRule.idx_tREF_VoteRule_order | 0 MB | 86 rows
-- KEY (voterule_order, is_active) INCLUDE (voterule_id, vote_pattern, matched_vote_id)
-- 179 index updates absorbed for zero reads.
ALTER INDEX [idx_tREF_VoteRule_order] ON [dbo].[tREF_VoteRule] DISABLE;
--   drop later : DROP INDEX [idx_tREF_VoteRule_order] ON [dbo].[tREF_VoteRule];
--   rollback   : ALTER INDEX [idx_tREF_VoteRule_order] ON [dbo].[tREF_VoteRule] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblDirectorSkill_Internal.idx_tblDirectorSkill_Internal_skillname | 0 MB | 79 rows
-- KEY (skill_name, skillgroup_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblDirectorSkill_Internal_skillname] ON [dbo].[tblDirectorSkill_Internal] DISABLE;
--   drop later : DROP INDEX [idx_tblDirectorSkill_Internal_skillname] ON [dbo].[tblDirectorSkill_Internal];
--   rollback   : ALTER INDEX [idx_tblDirectorSkill_Internal_skillname] ON [dbo].[tblDirectorSkill_Internal] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblDirectorSkill_Internal.idx_tblDirectorSkill_Internal_skillgroupid | 0 MB | 79 rows
-- KEY (skillgroup_id, skill_name)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblDirectorSkill_Internal_skillgroupid] ON [dbo].[tblDirectorSkill_Internal] DISABLE;
--   drop later : DROP INDEX [idx_tblDirectorSkill_Internal_skillgroupid] ON [dbo].[tblDirectorSkill_Internal];
--   rollback   : ALTER INDEX [idx_tblDirectorSkill_Internal_skillgroupid] ON [dbo].[tblDirectorSkill_Internal] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblProxyStatement_ShareClass.NonClusteredIndex-20260810-164317 | 0 MB | 7 rows
-- KEY (scraped_filing_id, additional_filing_id)
-- 7 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20260810-164317] ON [dbo].[tblProxyStatement_ShareClass] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20260810-164317] ON [dbo].[tblProxyStatement_ShareClass];
--   rollback   : ALTER INDEX [NonClusteredIndex-20260810-164317] ON [dbo].[tblProxyStatement_ShareClass] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgCompensation_PayRatio.idx_stgCompensation_PayRatio_directorappointmentid | 0 MB | 1 rows
-- KEY (import_id, DirectorAppointment_id)
-- 348 index updates absorbed for zero reads.
ALTER INDEX [idx_stgCompensation_PayRatio_directorappointmentid] ON [dbo].[stgCompensation_PayRatio] DISABLE;
--   drop later : DROP INDEX [idx_stgCompensation_PayRatio_directorappointmentid] ON [dbo].[stgCompensation_PayRatio];
--   rollback   : ALTER INDEX [idx_stgCompensation_PayRatio_directorappointmentid] ON [dbo].[stgCompensation_PayRatio] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_JudgementOutcomeLink.idx_tblSECLitigation_JudgementOutcomeLink_seclitigationid | 0 MB | 67 rows
-- KEY (sec_litigation_id, outcome_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_JudgementOutcomeLink_seclitigationid] ON [dbo].[tblSECLitigation_JudgementOutcomeLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_JudgementOutcomeLink_seclitigationid] ON [dbo].[tblSECLitigation_JudgementOutcomeLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_JudgementOutcomeLink_seclitigationid] ON [dbo].[tblSECLitigation_JudgementOutcomeLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tVoting_Sync_Run.IX_tVoting_Sync_Run_Status | 0 MB | 10 rows
-- KEY (RunStatus, StartTime)
-- never touched at all since the DMV reset - no reads and no writes. FILTERED: ([RunStatus]='InProgress').
ALTER INDEX [IX_tVoting_Sync_Run_Status] ON [dbo].[tVoting_Sync_Run] DISABLE;
--   drop later : DROP INDEX [IX_tVoting_Sync_Run_Status] ON [dbo].[tVoting_Sync_Run];
--   rollback   : ALTER INDEX [IX_tVoting_Sync_Run_Status] ON [dbo].[tVoting_Sync_Run] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tDHI_CGS_ImportRun.IX_tDHI_CGS_ImportRun_Status | 0 MB | 211 rows
-- KEY (Status)
-- 219 index updates absorbed for zero reads.
ALTER INDEX [IX_tDHI_CGS_ImportRun_Status] ON [dbo].[tDHI_CGS_ImportRun] DISABLE;
--   drop later : DROP INDEX [IX_tDHI_CGS_ImportRun_Status] ON [dbo].[tDHI_CGS_ImportRun];
--   rollback   : ALTER INDEX [IX_tDHI_CGS_ImportRun_Status] ON [dbo].[tDHI_CGS_ImportRun] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_ReleaseTypeLink.idx_tblSECLitigation_ReleaseTypeLink_releaseid | 0 MB | 138 rows
-- KEY (release_id, releasetype_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_ReleaseTypeLink_releaseid] ON [dbo].[tblSECLitigation_ReleaseTypeLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_ReleaseTypeLink_releaseid] ON [dbo].[tblSECLitigation_ReleaseTypeLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_ReleaseTypeLink_releaseid] ON [dbo].[tblSECLitigation_ReleaseTypeLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblClarity_Metrics.NCDX_tblClarity_Metrics_ParentMetricID_MetricID | 0 MB | 419 rows
-- KEY (PARENT_METRIC_ID, METRIC_ID)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NCDX_tblClarity_Metrics_ParentMetricID_MetricID] ON [dbo].[tblClarity_Metrics] DISABLE;
--   drop later : DROP INDEX [NCDX_tblClarity_Metrics_ParentMetricID_MetricID] ON [dbo].[tblClarity_Metrics];
--   rollback   : ALTER INDEX [NCDX_tblClarity_Metrics_ParentMetricID_MetricID] ON [dbo].[tblClarity_Metrics] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tDHI_CGS_ImportRun.IX_tDHI_CGS_ImportRun_RunStartTime | 0 MB | 211 rows
-- KEY (RunStartTime)
-- 115 index updates absorbed for zero reads.
ALTER INDEX [IX_tDHI_CGS_ImportRun_RunStartTime] ON [dbo].[tDHI_CGS_ImportRun] DISABLE;
--   drop later : DROP INDEX [IX_tDHI_CGS_ImportRun_RunStartTime] ON [dbo].[tDHI_CGS_ImportRun];
--   rollback   : ALTER INDEX [IX_tDHI_CGS_ImportRun_RunStartTime] ON [dbo].[tDHI_CGS_ImportRun] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_ReleaseTypeLink.idx_tblSECLitigation_ReleaseTypeLink_releasetype_id | 0 MB | 138 rows
-- KEY (releasetype_id, release_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_ReleaseTypeLink_releasetype_id] ON [dbo].[tblSECLitigation_ReleaseTypeLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_ReleaseTypeLink_releasetype_id] ON [dbo].[tblSECLitigation_ReleaseTypeLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_ReleaseTypeLink_releasetype_id] ON [dbo].[tblSECLitigation_ReleaseTypeLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_DirectorLink.idx_tblSECLitigation_DirectorLink_seclitigationid | 0 MB | 101 rows
-- KEY (sec_litigation_id, director_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_DirectorLink_seclitigationid] ON [dbo].[tblSECLitigation_DirectorLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_DirectorLink_seclitigationid] ON [dbo].[tblSECLitigation_DirectorLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_DirectorLink_seclitigationid] ON [dbo].[tblSECLitigation_DirectorLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tREF_VoteRule.idx_tREF_VoteRule_pattern | 0 MB | 86 rows
-- KEY (vote_pattern, is_active) INCLUDE (voterule_id, matched_vote_id, rule_confidence)
-- 179 index updates absorbed for zero reads.
ALTER INDEX [idx_tREF_VoteRule_pattern] ON [dbo].[tREF_VoteRule] DISABLE;
--   drop later : DROP INDEX [idx_tREF_VoteRule_pattern] ON [dbo].[tREF_VoteRule];
--   rollback   : ALTER INDEX [idx_tREF_VoteRule_pattern] ON [dbo].[tREF_VoteRule] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_Release.idx_tblSECLitigation_Release_seclitigationid | 0 MB | 102 rows
-- KEY (sec_litigation_id, release_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_Release_seclitigationid] ON [dbo].[tblSECLitigation_Release] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_Release_seclitigationid] ON [dbo].[tblSECLitigation_Release];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_Release_seclitigationid] ON [dbo].[tblSECLitigation_Release] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_DirectorLink.idx_tblSECLitigation_DirectorLink_directorid | 0 MB | 101 rows
-- KEY (director_id, sec_litigation_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_DirectorLink_directorid] ON [dbo].[tblSECLitigation_DirectorLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_DirectorLink_directorid] ON [dbo].[tblSECLitigation_DirectorLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_DirectorLink_directorid] ON [dbo].[tblSECLitigation_DirectorLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgRPI_Individual.NCDX_stgRPI_Individual_DirectorID_ImportStatus | 0 MB | 0 rows
-- KEY (director_id, import_status) INCLUDE (rpindividual_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NCDX_stgRPI_Individual_DirectorID_ImportStatus] ON [dbo].[stgRPI_Individual] DISABLE;
--   drop later : DROP INDEX [NCDX_stgRPI_Individual_DirectorID_ImportStatus] ON [dbo].[stgRPI_Individual];
--   rollback   : ALTER INDEX [NCDX_stgRPI_Individual_DirectorID_ImportStatus] ON [dbo].[stgRPI_Individual] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_CorporateActions.IX_stgDHI_CGS_CorporateActions_Ticker | 0 MB | 0 rows
-- KEY (Ticker)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_stgDHI_CGS_CorporateActions_Ticker] ON [dbo].[stgDHI_CGS_CorporateActions] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_CorporateActions_Ticker] ON [dbo].[stgDHI_CGS_CorporateActions];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_CorporateActions_Ticker] ON [dbo].[stgDHI_CGS_CorporateActions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSECLitigation_CompanyLink.idx_tblSECLitigation_CompanyLink_companyid | 0 MB | 0 rows
-- KEY (pid, sec_litigation_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_tblSECLitigation_CompanyLink_companyid] ON [dbo].[tblSECLitigation_CompanyLink] DISABLE;
--   drop later : DROP INDEX [idx_tblSECLitigation_CompanyLink_companyid] ON [dbo].[tblSECLitigation_CompanyLink];
--   rollback   : ALTER INDEX [idx_tblSECLitigation_CompanyLink_companyid] ON [dbo].[tblSECLitigation_CompanyLink] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_audit.idx_tblCompany_audit_proc_id | 0 MB | 0 rows
-- KEY (audit_proc_id)
-- never touched at all since the DMV reset - no reads and no writes. FILTERED: ([audit_proc_id] IS NOT NULL).
ALTER INDEX [idx_tblCompany_audit_proc_id] ON [dbo].[tblCompany_audit] DISABLE;
--   drop later : DROP INDEX [idx_tblCompany_audit_proc_id] ON [dbo].[tblCompany_audit];
--   rollback   : ALTER INDEX [idx_tblCompany_audit_proc_id] ON [dbo].[tblCompany_audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_CorporateActions.IX_stgDHI_CGS_CorporateActions_CreatedDate | 0 MB | 0 rows
-- KEY (CreatedDate)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_stgDHI_CGS_CorporateActions_CreatedDate] ON [dbo].[stgDHI_CGS_CorporateActions] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_CorporateActions_CreatedDate] ON [dbo].[stgDHI_CGS_CorporateActions];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_CorporateActions_CreatedDate] ON [dbo].[stgDHI_CGS_CorporateActions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_CorporateActions.IX_stgDHI_CGS_CorporateActions_ImportBatchId | 0 MB | 0 rows
-- KEY (ImportBatchId)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_stgDHI_CGS_CorporateActions_ImportBatchId] ON [dbo].[stgDHI_CGS_CorporateActions] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_CorporateActions_ImportBatchId] ON [dbo].[stgDHI_CGS_CorporateActions];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_CorporateActions_ImportBatchId] ON [dbo].[stgDHI_CGS_CorporateActions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_CorporateActions.IX_stgDHI_CGS_CorporateActions_Unprocessed | 0 MB | 0 rows
-- KEY (ProcessedFlag) INCLUDE (CorporateActionId, ImportBatchId, PID, Ticker, Exchange, CUSIP, ISIN, ActionType, EffectiveDate, PreviousCUSIP, PreviousISIN)
-- never touched at all since the DMV reset - no reads and no writes. FILTERED: ([ProcessedFlag]=(0)).
ALTER INDEX [IX_stgDHI_CGS_CorporateActions_Unprocessed] ON [dbo].[stgDHI_CGS_CorporateActions] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_CorporateActions_Unprocessed] ON [dbo].[stgDHI_CGS_CorporateActions];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_CorporateActions_Unprocessed] ON [dbo].[stgDHI_CGS_CorporateActions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- stgDHI_CGS_CorporateActions.IX_stgDHI_CGS_CorporateActions_EffectiveDate | 0 MB | 0 rows
-- KEY (EffectiveDate)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_stgDHI_CGS_CorporateActions_EffectiveDate] ON [dbo].[stgDHI_CGS_CorporateActions] DISABLE;
--   drop later : DROP INDEX [IX_stgDHI_CGS_CorporateActions_EffectiveDate] ON [dbo].[stgDHI_CGS_CorporateActions];
--   rollback   : ALTER INDEX [IX_stgDHI_CGS_CorporateActions_EffectiveDate] ON [dbo].[stgDHI_CGS_CorporateActions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

```

---

## proxy_insight

53 unused indexes, 83.3 GB, carrying 7,638,893 index updates.

```sql
USE proxy_insight;
GO

-- tblfeed_data_backup.NonClusteredIndex-20161108-093609 | 33,289 MB | 611,641,943 rows
-- KEY (table_id, unique_id, Command) INCLUDE (times)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20161108-093609] ON [dbo].[tblfeed_data_backup] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20161108-093609] ON [dbo].[tblfeed_data_backup];
--   rollback   : ALTER INDEX [NonClusteredIndex-20161108-093609] ON [dbo].[tblfeed_data_backup] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_processed_by_invest_sync.idx_tblvotingdataprocessedbyinvestsync_proptype_meeting | 6,192 MB | 169,336,735 rows
-- KEY (proposal_type, meeting_id)
-- 331,789 index updates absorbed for zero reads.
ALTER INDEX [idx_tblvotingdataprocessedbyinvestsync_proptype_meeting] ON [dbo].[tblvoting_data_processed_by_invest_sync] DISABLE;
--   drop later : DROP INDEX [idx_tblvotingdataprocessedbyinvestsync_proptype_meeting] ON [dbo].[tblvoting_data_processed_by_invest_sync];
--   rollback   : ALTER INDEX [idx_tblvotingdataprocessedbyinvestsync_proptype_meeting] ON [dbo].[tblvoting_data_processed_by_invest_sync] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblOwnership_data_past_quarters.idx_cusip_period | 5,250 MB | 67,719,668 rows
-- KEY (CUSIP, period_of_report) INCLUDE (filer_name, value)
-- 2 index updates absorbed for zero reads.
ALTER INDEX [idx_cusip_period] ON [dbo].[tblOwnership_data_past_quarters] DISABLE;
--   drop later : DROP INDEX [idx_cusip_period] ON [dbo].[tblOwnership_data_past_quarters];
--   rollback   : ALTER INDEX [idx_cusip_period] ON [dbo].[tblOwnership_data_past_quarters] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_Rationale_New.IX_tblvoting_rationale_new_fund_proposal_vote_performance | 4,990 MB | 18,505,482 rows
-- KEY (fund_id, proposal_id, vote_cast, voting_rationale_new_id) INCLUDE (vote_reason)
-- 121,695 index updates absorbed for zero reads. FILTERED: ([vote_reason] IS NOT NULL).
ALTER INDEX [IX_tblvoting_rationale_new_fund_proposal_vote_performance] ON [dbo].[tblVoting_Rationale_New] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_rationale_new_fund_proposal_vote_performance] ON [dbo].[tblVoting_Rationale_New];
--   rollback   : ALTER INDEX [IX_tblvoting_rationale_new_fund_proposal_vote_performance] ON [dbo].[tblVoting_Rationale_New] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_ready_to_process_2021.IX_tblvoting_data_ready_to_process_2021_proposal_new_proposal_id | 4,861 MB | 55,336,856 rows
-- KEY (proposal, new_proposal_id)
-- 1,776 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_data_ready_to_process_2021_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2021] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_data_ready_to_process_2021_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2021];
--   rollback   : ALTER INDEX [IX_tblvoting_data_ready_to_process_2021_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2021] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_ready_to_process_2020.IX_tblvoting_data_ready_to_process_2020_proposal_new_proposal_id | 4,456 MB | 47,679,154 rows
-- KEY (proposal, new_proposal_id)
-- 2,111 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_data_ready_to_process_2020_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2020] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_data_ready_to_process_2020_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2020];
--   rollback   : ALTER INDEX [IX_tblvoting_data_ready_to_process_2020_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2020] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_ready_to_process_2019.IX_tblvoting_data_ready_to_process_2019_proposal_new_proposal_id | 4,354 MB | 46,810,725 rows
-- KEY (proposal, new_proposal_id)
-- 2,113 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_data_ready_to_process_2019_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2019] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_data_ready_to_process_2019_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2019];
--   rollback   : ALTER INDEX [IX_tblvoting_data_ready_to_process_2019_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2019] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblOwnership_data_past_quarters.test | 4,341 MB | 67,719,668 rows
-- KEY (quarter_end_date) INCLUDE (filer_id, CIK, period_of_report, CUSIP, shares)
-- 2 index updates absorbed for zero reads.
ALTER INDEX [test] ON [dbo].[tblOwnership_data_past_quarters] DISABLE;
--   drop later : DROP INDEX [test] ON [dbo].[tblOwnership_data_past_quarters];
--   rollback   : ALTER INDEX [test] ON [dbo].[tblOwnership_data_past_quarters] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_ready_to_process_2018.IX_tblvoting_data_ready_to_process_2018_proposal_new_proposal_id | 3,821 MB | 41,306,400 rows
-- KEY (proposal, new_proposal_id)
-- 2,078 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_data_ready_to_process_2018_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2018] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_data_ready_to_process_2018_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2018];
--   rollback   : ALTER INDEX [IX_tblvoting_data_ready_to_process_2018_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2018] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_ready_to_process_2017.IX_tblvoting_data_ready_to_process_2017_proposal_new_proposal_id | 3,496 MB | 37,377,524 rows
-- KEY (proposal, new_proposal_id)
-- 2,076 index updates absorbed for zero reads.
ALTER INDEX [IX_tblvoting_data_ready_to_process_2017_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2017] DISABLE;
--   drop later : DROP INDEX [IX_tblvoting_data_ready_to_process_2017_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2017];
--   rollback   : ALTER INDEX [IX_tblvoting_data_ready_to_process_2017_proposal_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2017] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblOwnership_data_past_quarters.cusip | 3,384 MB | 67,719,668 rows
-- KEY (period_of_report, CUSIP) INCLUDE (CIK)
-- 2 index updates absorbed for zero reads.
ALTER INDEX [cusip] ON [dbo].[tblOwnership_data_past_quarters] DISABLE;
--   drop later : DROP INDEX [cusip] ON [dbo].[tblOwnership_data_past_quarters];
--   rollback   : ALTER INDEX [cusip] ON [dbo].[tblOwnership_data_past_quarters] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- JB_Proposal.IX_voteResult_Id | 2,424 MB | 89,470,282 rows
-- KEY (voteResult_Id)
-- 4,971,698 index updates absorbed for zero reads.
ALTER INDEX [IX_voteResult_Id] ON [dbo].[JB_Proposal] DISABLE;
--   drop later : DROP INDEX [IX_voteResult_Id] ON [dbo].[JB_Proposal];
--   rollback   : ALTER INDEX [IX_voteResult_Id] ON [dbo].[JB_Proposal] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_data_ready_to_process_2021.idx_update_tblvoting_data_processed_new_proposal_id | 1,874 MB | 55,336,856 rows
-- KEY (new_proposal_id)
-- 1,776 index updates absorbed for zero reads.
ALTER INDEX [idx_update_tblvoting_data_processed_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2021] DISABLE;
--   drop later : DROP INDEX [idx_update_tblvoting_data_processed_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2021];
--   rollback   : ALTER INDEX [idx_update_tblvoting_data_processed_new_proposal_id] ON [dbo].[tblvoting_data_ready_to_process_2021] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblUser_PageLog.idxPageLoguser | 536 MB | 8,385,818 rows
-- KEY (user_id) INCLUDE (access_date, page_name, query_string)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxPageLoguser] ON [dbo].[tblUser_PageLog] DISABLE;
--   drop later : DROP INDEX [idxPageLoguser] ON [dbo].[tblUser_PageLog];
--   rollback   : ALTER INDEX [idxPageLoguser] ON [dbo].[tblUser_PageLog] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblProposals.idx_proposal_director_name_type | 431 MB | 4,939,801 rows
-- KEY (director_name, proposal_type) INCLUDE (proposal_detail)
-- 2,066,839 index updates absorbed for zero reads.
ALTER INDEX [idx_proposal_director_name_type] ON [dbo].[tblProposals] DISABLE;
--   drop later : DROP INDEX [idx_proposal_director_name_type] ON [dbo].[tblProposals];
--   rollback   : ALTER INDEX [idx_proposal_director_name_type] ON [dbo].[tblProposals] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblIdentifier_Audit.IX_tblIdentifier_Audit_identifier_value | 237 MB | 2,515,913 rows
-- KEY (identifier_value, identifier_type_ID, audit_date)
-- 44,811 index updates absorbed for zero reads.
ALTER INDEX [IX_tblIdentifier_Audit_identifier_value] ON [dbo].[tblIdentifier_Audit] DISABLE;
--   drop later : DROP INDEX [IX_tblIdentifier_Audit_identifier_value] ON [dbo].[tblIdentifier_Audit];
--   rollback   : ALTER INDEX [IX_tblIdentifier_Audit_identifier_value] ON [dbo].[tblIdentifier_Audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblUser_PageLog.NonClusteredIndex-20150401-101121 | 234 MB | 8,385,818 rows
-- KEY (query_string)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20150401-101121] ON [dbo].[tblUser_PageLog] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20150401-101121] ON [dbo].[tblUser_PageLog];
--   rollback   : ALTER INDEX [NonClusteredIndex-20150401-101121] ON [dbo].[tblUser_PageLog] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpResolutions_by_Managers_Country_votesbyinvest.idxtblResolution_by_manager_country_votesbyinvest | 231 MB | 4,095,410 rows
-- KEY (investor_id, country_id, occurs_meetings) INCLUDE (proposal_type_id, occurs, votes_for, votes_against, votes_split, votes_abstain, votes_withhold, votes_tna)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxtblResolution_by_manager_country_votesbyinvest] ON [dbo].[tmpResolutions_by_Managers_Country_votesbyinvest] DISABLE;
--   drop later : DROP INDEX [idxtblResolution_by_manager_country_votesbyinvest] ON [dbo].[tmpResolutions_by_Managers_Country_votesbyinvest];
--   rollback   : ALTER INDEX [idxtblResolution_by_manager_country_votesbyinvest] ON [dbo].[tmpResolutions_by_Managers_Country_votesbyinvest] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblIdentifier_Audit.IX_tblIdentifier_Audit_identifier_id | 186 MB | 2,515,913 rows
-- KEY (identifier_id, audit_date)
-- 44,811 index updates absorbed for zero reads.
ALTER INDEX [IX_tblIdentifier_Audit_identifier_id] ON [dbo].[tblIdentifier_Audit] DISABLE;
--   drop later : DROP INDEX [IX_tblIdentifier_Audit_identifier_id] ON [dbo].[tblIdentifier_Audit];
--   rollback   : ALTER INDEX [IX_tblIdentifier_Audit_identifier_id] ON [dbo].[tblIdentifier_Audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblUser_PageLog.NonClusteredIndex-20150401-100923 | 158 MB | 8,385,818 rows
-- KEY (user_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20150401-100923] ON [dbo].[tblUser_PageLog] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20150401-100923] ON [dbo].[tblUser_PageLog];
--   rollback   : ALTER INDEX [NonClusteredIndex-20150401-100923] ON [dbo].[tblUser_PageLog] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblUser_PageLog.idxUser_PageLog_id | 146 MB | 8,385,818 rows
-- KEY (page_log_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxUser_PageLog_id] ON [dbo].[tblUser_PageLog] DISABLE;
--   drop later : DROP INDEX [idxUser_PageLog_id] ON [dbo].[tblUser_PageLog];
--   rollback   : ALTER INDEX [idxUser_PageLog_id] ON [dbo].[tblUser_PageLog] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblIdentifier_Audit.IX_tblIdentifier_Audit_audit_type | 92 MB | 2,515,913 rows
-- KEY (audit_type, audit_date)
-- 44,811 index updates absorbed for zero reads.
ALTER INDEX [IX_tblIdentifier_Audit_audit_type] ON [dbo].[tblIdentifier_Audit] DISABLE;
--   drop later : DROP INDEX [IX_tblIdentifier_Audit_audit_type] ON [dbo].[tblIdentifier_Audit];
--   rollback   : ALTER INDEX [IX_tblIdentifier_Audit_audit_type] ON [dbo].[tblIdentifier_Audit] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_rationale_deco.NonClusteredIndex-20160229-163004 | 55 MB | 3,167,251 rows
-- KEY (investor_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20160229-163004] ON [dbo].[tblvoting_rationale_deco] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160229-163004] ON [dbo].[tblvoting_rationale_deco];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160229-163004] ON [dbo].[tblvoting_rationale_deco] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_rationale_deco.NonClusteredIndex-20160229-163022 | 55 MB | 3,167,251 rows
-- KEY (proposal_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20160229-163022] ON [dbo].[tblvoting_rationale_deco] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160229-163022] ON [dbo].[tblvoting_rationale_deco];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160229-163022] ON [dbo].[tblvoting_rationale_deco] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblvoting_rationale_deco.NonClusteredIndex-20160229-163052 | 55 MB | 3,167,251 rows
-- KEY (fund_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20160229-163052] ON [dbo].[tblvoting_rationale_deco] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160229-163052] ON [dbo].[tblvoting_rationale_deco];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160229-163052] ON [dbo].[tblvoting_rationale_deco] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblExec_compensation.Idx_Cov_tblExec_Compensation_director_id | 39 MB | 326,322 rows
-- KEY (director_id) INCLUDE (Total, Option_Awards, Salary, Bonus, Stock_Awards, All_Other_Compensation, NonEquity_Incentive_Plan, Change_in_Pension_Value, Severance, Awards, NonQualified_Deferred_Earnings, proxy_statement_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [Idx_Cov_tblExec_Compensation_director_id] ON [dbo].[tblExec_compensation] DISABLE;
--   drop later : DROP INDEX [Idx_Cov_tblExec_Compensation_director_id] ON [dbo].[tblExec_compensation];
--   rollback   : ALTER INDEX [Idx_Cov_tblExec_Compensation_director_id] ON [dbo].[tblExec_compensation] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblExec_compensation.Idx_Cov_tblExec_Compensation_proxy_statement_id | 37 MB | 326,322 rows
-- KEY (proxy_statement_id) INCLUDE (director_id, Total, Option_Awards, Salary, Bonus, Stock_Awards, All_Other_Compensation, NonEquity_Incentive_Plan, Change_in_Pension_Value, Severance, Awards, NonQualified_Deferred_Earnings)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [Idx_Cov_tblExec_Compensation_proxy_statement_id] ON [dbo].[tblExec_compensation] DISABLE;
--   drop later : DROP INDEX [Idx_Cov_tblExec_Compensation_proxy_statement_id] ON [dbo].[tblExec_compensation];
--   rollback   : ALTER INDEX [Idx_Cov_tblExec_Compensation_proxy_statement_id] ON [dbo].[tblExec_compensation] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_Rationale_Private.NonClusteredIndex-tblvoting_rationale_private_proposal | 16 MB | 297,589 rows
-- KEY (proposal_id)
-- 75 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-tblvoting_rationale_private_proposal] ON [dbo].[tblVoting_Rationale_Private] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-tblvoting_rationale_private_proposal] ON [dbo].[tblVoting_Rationale_Private];
--   rollback   : ALTER INDEX [NonClusteredIndex-tblvoting_rationale_private_proposal] ON [dbo].[tblVoting_Rationale_Private] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_Rationale_Private.NonClusteredIndex-tblvoting_rationale_private_investor | 15 MB | 297,589 rows
-- KEY (investor_id) INCLUDE (voting_rationale_private_id)
-- 75 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-tblvoting_rationale_private_investor] ON [dbo].[tblVoting_Rationale_Private] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-tblvoting_rationale_private_investor] ON [dbo].[tblVoting_Rationale_Private];
--   rollback   : ALTER INDEX [NonClusteredIndex-tblvoting_rationale_private_investor] ON [dbo].[tblVoting_Rationale_Private] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblVoting_Rationale_Private.NonClusteredIndex-tblvoting_rationale_private_fund | 12 MB | 297,589 rows
-- KEY (fund_id, investor_id) INCLUDE (voting_rationale_private_id)
-- 75 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-tblvoting_rationale_private_fund] ON [dbo].[tblVoting_Rationale_Private] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-tblvoting_rationale_private_fund] ON [dbo].[tblVoting_Rationale_Private];
--   rollback   : ALTER INDEX [NonClusteredIndex-tblvoting_rationale_private_fund] ON [dbo].[tblVoting_Rationale_Private] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblSessions.idx_user_id_session_last | 9 MB | 322,384 rows
-- KEY (user_id) INCLUDE (session_last)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_user_id_session_last] ON [dbo].[tblSessions] DISABLE;
--   drop later : DROP INDEX [idx_user_id_session_last] ON [dbo].[tblSessions];
--   rollback   : ALTER INDEX [idx_user_id_session_last] ON [dbo].[tblSessions] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpResolutions_by_Managers_Country_New_withSponsor.idxtmpResolutions_by_Managers_Country_New | 9 MB | 494,674 rows
-- KEY (investor_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxtmpResolutions_by_Managers_Country_New] ON [dbo].[tmpResolutions_by_Managers_Country_New_withSponsor] DISABLE;
--   drop later : DROP INDEX [idxtmpResolutions_by_Managers_Country_New] ON [dbo].[tmpResolutions_by_Managers_Country_New_withSponsor];
--   rollback   : ALTER INDEX [idxtmpResolutions_by_Managers_Country_New] ON [dbo].[tmpResolutions_by_Managers_Country_New_withSponsor] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpResolutions_by_Managers_Country_New_withSponsor.idxtmpResolutions_by_Managers_Country_New_type | 9 MB | 494,674 rows
-- KEY (proposal_type_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxtmpResolutions_by_Managers_Country_New_type] ON [dbo].[tmpResolutions_by_Managers_Country_New_withSponsor] DISABLE;
--   drop later : DROP INDEX [idxtmpResolutions_by_Managers_Country_New_type] ON [dbo].[tmpResolutions_by_Managers_Country_New_withSponsor];
--   rollback   : ALTER INDEX [idxtmpResolutions_by_Managers_Country_New_type] ON [dbo].[tmpResolutions_by_Managers_Country_New_withSponsor] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpCompany_match.idx_company_name | 3 MB | 49,696 rows
-- KEY (company_name)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_company_name] ON [dbo].[tmpCompany_match] DISABLE;
--   drop later : DROP INDEX [idx_company_name] ON [dbo].[tmpCompany_match];
--   rollback   : ALTER INDEX [idx_company_name] ON [dbo].[tmpCompany_match] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblProposal_match_text.NonClusteredIndex-20161124-115243 | 2 MB | 15,539 rows
-- KEY (proposal_match, importance, proposal)
-- 139 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20161124-115243] ON [dbo].[tblProposal_match_text] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20161124-115243] ON [dbo].[tblProposal_match_text];
--   rollback   : ALTER INDEX [NonClusteredIndex-20161124-115243] ON [dbo].[tblProposal_match_text] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblProposal_match_text.NonClusteredIndex-20161025-135249 | 1 MB | 15,539 rows
-- KEY (proposal_match)
-- 139 index updates absorbed for zero reads.
ALTER INDEX [NonClusteredIndex-20161025-135249] ON [dbo].[tblProposal_match_text] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20161025-135249] ON [dbo].[tblProposal_match_text];
--   rollback   : ALTER INDEX [NonClusteredIndex-20161025-135249] ON [dbo].[tblProposal_match_text] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblProposals_Matched_data.NonClusteredIndex-20200617-112859 | 1 MB | 52,541 rows
-- KEY (proposal_id, proposal_value)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20200617-112859] ON [dbo].[tblProposals_Matched_data] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20200617-112859] ON [dbo].[tblProposals_Matched_data];
--   rollback   : ALTER INDEX [NonClusteredIndex-20200617-112859] ON [dbo].[tblProposals_Matched_data] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tbluser_trial_log.NonClusteredIndex-20180913-110114 | 1 MB | 26,595 rows
-- KEY (type, user_id) INCLUDE (unique_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20180913-110114] ON [dbo].[tbluser_trial_log] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20180913-110114] ON [dbo].[tbluser_trial_log];
--   rollback   : ALTER INDEX [NonClusteredIndex-20180913-110114] ON [dbo].[tbluser_trial_log] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpNPORT.NonClusteredIndex-20191129-084255 | 1 MB | 19,259 rows
-- KEY (Company_Name)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20191129-084255] ON [dbo].[tmpNPORT] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20191129-084255] ON [dbo].[tmpNPORT];
--   rollback   : ALTER INDEX [NonClusteredIndex-20191129-084255] ON [dbo].[tmpNPORT] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblInvestor_against_generated.investor_against_idx | 1 MB | 32,243 rows
-- KEY (investor_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [investor_against_idx] ON [dbo].[tblInvestor_against_generated] DISABLE;
--   drop later : DROP INDEX [investor_against_idx] ON [dbo].[tblInvestor_against_generated];
--   rollback   : ALTER INDEX [investor_against_idx] ON [dbo].[tblInvestor_against_generated] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpResolutions_by_Managers_bydate.idxtmpresolutions_by_Managers_Country_New_type | 0 MB | 14,861 rows
-- KEY (proposal_type_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxtmpresolutions_by_Managers_Country_New_type] ON [dbo].[tmpResolutions_by_Managers_bydate] DISABLE;
--   drop later : DROP INDEX [idxtmpresolutions_by_Managers_Country_New_type] ON [dbo].[tmpResolutions_by_Managers_bydate];
--   rollback   : ALTER INDEX [idxtmpresolutions_by_Managers_Country_New_type] ON [dbo].[tmpResolutions_by_Managers_bydate] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpResolutions_by_Managers_bydate.idxtmpresolutions_by_Managers_Country_New | 0 MB | 14,861 rows
-- KEY (investor_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxtmpresolutions_by_Managers_Country_New] ON [dbo].[tmpResolutions_by_Managers_bydate] DISABLE;
--   drop later : DROP INDEX [idxtmpresolutions_by_Managers_Country_New] ON [dbo].[tmpResolutions_by_Managers_bydate];
--   rollback   : ALTER INDEX [idxtmpresolutions_by_Managers_Country_New] ON [dbo].[tmpResolutions_by_Managers_bydate] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpFund_Import.NonClusteredIndex-20210428-124839 | 0 MB | 2,644 rows
-- KEY (shares)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20210428-124839] ON [dbo].[tmpFund_Import] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20210428-124839] ON [dbo].[tmpFund_Import];
--   rollback   : ALTER INDEX [NonClusteredIndex-20210428-124839] ON [dbo].[tmpFund_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpFund_Import.NonClusteredIndex-20210428-123751 | 0 MB | 2,644 rows
-- KEY (field1, field2, field3, field4, field5, field6, field7, field8, field9, field10)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20210428-123751] ON [dbo].[tmpFund_Import] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20210428-123751] ON [dbo].[tmpFund_Import];
--   rollback   : ALTER INDEX [NonClusteredIndex-20210428-123751] ON [dbo].[tmpFund_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpresolutions_by_Managers_Country_VotesByInvest_daily.idxtblResolution_by_manager_country_votesbyinvest_daily | 0 MB | 3,267 rows
-- KEY (investor_id, country_id, occurs_meetings) INCLUDE (proposal_type_id, occurs, votes_for, votes_against, votes_split, votes_abstain, votes_withhold, votes_tna)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idxtblResolution_by_manager_country_votesbyinvest_daily] ON [dbo].[tmpresolutions_by_Managers_Country_VotesByInvest_daily] DISABLE;
--   drop later : DROP INDEX [idxtblResolution_by_manager_country_votesbyinvest_daily] ON [dbo].[tmpresolutions_by_Managers_Country_VotesByInvest_daily];
--   rollback   : ALTER INDEX [idxtblResolution_by_manager_country_votesbyinvest_daily] ON [dbo].[tmpresolutions_by_Managers_Country_VotesByInvest_daily] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblAppScrapeHistory.NonClusteredIndex-20200826-092001 | 0 MB | 2,735 rows
-- KEY (app, build, identifier)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20200826-092001] ON [dbo].[tblAppScrapeHistory] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20200826-092001] ON [dbo].[tblAppScrapeHistory];
--   rollback   : ALTER INDEX [NonClusteredIndex-20200826-092001] ON [dbo].[tblAppScrapeHistory] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpFund_Import.NonClusteredIndex-20210428-125229 | 0 MB | 2,644 rows
-- KEY (class)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20210428-125229] ON [dbo].[tmpFund_Import] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20210428-125229] ON [dbo].[tmpFund_Import];
--   rollback   : ALTER INDEX [NonClusteredIndex-20210428-125229] ON [dbo].[tmpFund_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpFund_Import.NonClusteredIndex-20210428-122656 | 0 MB | 2,644 rows
-- KEY (row_item)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20210428-122656] ON [dbo].[tmpFund_Import] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20210428-122656] ON [dbo].[tmpFund_Import];
--   rollback   : ALTER INDEX [NonClusteredIndex-20210428-122656] ON [dbo].[tmpFund_Import] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblMax_voting_ID.idx_reported_votes | 0 MB | 799 rows
-- KEY (min_reporting_votes_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_reported_votes] ON [dbo].[tblMax_voting_ID] DISABLE;
--   drop later : DROP INDEX [idx_reported_votes] ON [dbo].[tblMax_voting_ID];
--   rollback   : ALTER INDEX [idx_reported_votes] ON [dbo].[tblMax_voting_ID] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tmpVoteMatchImport.idximport_check_id | 0 MB | 1,893 rows
-- KEY (import_check_id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idximport_check_id] ON [dbo].[tmpVoteMatchImport] DISABLE;
--   drop later : DROP INDEX [idximport_check_id] ON [dbo].[tmpVoteMatchImport];
--   rollback   : ALTER INDEX [idximport_check_id] ON [dbo].[tmpVoteMatchImport] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCIK_TidyName.idx_CIKTidy_CIK | 0 MB | 3,778 rows
-- KEY (CIK)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [idx_CIKTidy_CIK] ON [dbo].[tblCIK_TidyName] DISABLE;
--   drop later : DROP INDEX [idx_CIKTidy_CIK] ON [dbo].[tblCIK_TidyName];
--   rollback   : ALTER INDEX [idx_CIKTidy_CIK] ON [dbo].[tblCIK_TidyName] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- tblCompany_assets.NonClusteredIndex-20160229-162551 | 0 MB | 1 rows
-- KEY (assets_date)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [NonClusteredIndex-20160229-162551] ON [dbo].[tblCompany_assets] DISABLE;
--   drop later : DROP INDEX [NonClusteredIndex-20160229-162551] ON [dbo].[tblCompany_assets];
--   rollback   : ALTER INDEX [NonClusteredIndex-20160229-162551] ON [dbo].[tblCompany_assets] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

-- JB_Link.IX_JB_VoteResult_Id | 0 MB | 0 rows
-- KEY (JB_VoteResult_Id)
-- never touched at all since the DMV reset - no reads and no writes.
ALTER INDEX [IX_JB_VoteResult_Id] ON [dbo].[JB_Link] DISABLE;
--   drop later : DROP INDEX [IX_JB_VoteResult_Id] ON [dbo].[JB_Link];
--   rollback   : ALTER INDEX [IX_JB_VoteResult_Id] ON [dbo].[JB_Link] REBUILD WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);

```

