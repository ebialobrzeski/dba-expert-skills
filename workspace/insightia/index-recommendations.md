# Insightia - Index Change Recommendations

Source: `workspace/insightia/` DMV exports from the primary and the readable secondary.
SQL Server 2022 Enterprise (16.0.4245.2) - `ONLINE = ON` and `RESUMABLE = ON` available.
AlwaysOn AG in place: large builds generate log that must ship to secondaries.

Effective evidence window: **105 days** (2026-05-20 -> 2026-09-02). The primary's DMVs go back to
2026-05-10 but the secondary's reset later, and the shorter window governs.

Execution order: create everything in Part 1 and 2 first, run one full business cycle,
then apply the drops in Part 3 and in `unused-indexes-to-drop.md`.

> **Readable secondary verified.** Usage was collected from the readable replica and unioned per
> index (join matched 163/163 activist and 88/88 proxy read-bearing indexes, zero unmatched).
> No index in any drop list is read on the secondary, so nothing is blocked. The secondary's own
> missing-index recommendations were reviewed and none warrant action - see Part 4.

---

## Part 1 - activist_insight: new indexes

```sql
USE activist_insight;
GO

-- Consolidates 3 separate DMV recommendations (R1 left-prefix + R3 include merge).
-- 489,111 combined seeks; table is 80,781 rows / 38 MB with only a clustered PK taking 444,205 scans.
-- Risk: LOW
CREATE NONCLUSTERED INDEX IX_tbladditional_filings_PID_additional_filing_type
    ON dbo.tbladditional_filings (PID, additional_filing_type)
    INCLUDE (filing_date, filing_url)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- Key order deliberately REVERSED from the DMV suggestion of (is_saved, user_id).
-- equality_columns is emitted in table column order, not selectivity order, and is_saved is a bit.
-- Highest improvement measure in the estate: 196,778 seeks, 99.42% impact. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblcompany_search_user_id_is_saved
    ON dbo.tblcompany_search (user_id, is_saved)
    INCLUDE ([Name])
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- FK column with no index: 909,659 rows, clustered PK shows 0 seeks and 58,824 scans.
-- 57,141 seeks, 99.73% impact, single int key. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblType_345_form_detail_derivative_holdings_type_345_form_detail_id
    ON dbo.tblType_345_form_detail_derivative_holdings (type_345_form_detail_id)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- Same pattern on the sibling table: 1,446,273 rows, 0 seeks / 58,824 scans.
-- 57,141 seeks, 99.73% impact. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblType_345_form_detail_non_derivative_holdings_type_345_form_detail_id
    ON dbo.tblType_345_form_detail_non_derivative_holdings (type_345_form_detail_id)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- 892,071 rows with only a clustered PK: 192,556 scans, 0 seeks.
-- 116,642 seeks, 99.69% impact. Three int columns = 12-byte key. Risk: LOW
-- Also absorbs the secondary's (pid, director_id) INCLUDE (committee_summary_id) request.
CREATE NONCLUSTERED INDEX IX_tblcommittee_membership_pid_director_id_committee_summary_id
    ON dbo.tblcommittee_membership (pid, director_id, committee_summary_id)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- Existing index is (user_id, news_id) so news_id cannot seek.
-- 68,511 seeks, 91.48% impact on a 1,395,573-row heap. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tbluser_news_log_news_id
    ON dbo.tbluser_news_log (news_id)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- R3 merge of NonClusteredIndex-20220329-153834 and -162211 (same key, different includes).
-- Replaces two indexes with one; drop the originals in Part 3 after validation. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblcompany_search_company_search_id_covering
    ON dbo.tblcompany_search (company_search_id)
    INCLUDE (market_cap_min, market_cap_max, pid)
    WITH (ONLINE = ON, MAXDOP = 4);
GO
```

---

## Part 2 - proxy_insight: new indexes

```sql
USE proxy_insight;
GO

-- Two recommendations are R2 borderline, but at 3,232 rows / 6 MB one covering index serves both.
-- Clustered PK is absorbing 1,935,109 scans. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblNoActionLetter_Outcome_Date_act
    ON dbo.tblNoActionLetter (Outcome, Date_act)
    INCLUDE (PID, PIType, Date_Staff_response)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- R3 merge of two recommendations; equality column leads, inequality second.
-- 77,802 rows, clustered PK only, 87,716 scans and 0 seeks. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblpolicychange_investor_profile_id_date_of_change
    ON dbo.tblpolicychange (investor_profile_id, date_of_change)
    INCLUDE (summary_change, area_field, section_field)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- 10,315 seeks, 74.21% impact. Existing index leads on proxy_statement_id so it cannot serve this.
-- Two narrow columns on a 3.4M-row table. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblProxy_equity_outstanding_column_header_type
    ON dbo.tblProxy_equity_outstanding (column_header_type)
    INCLUDE (column_header)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- Table is a 1,489,773-row heap taking 32,628 scans with no nonclustered support.
-- 11,607 seeks, 47.38% impact. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblProxy_executive_compensation_proxy_statement_id
    ON dbo.tblProxy_executive_compensation (proxy_statement_id)
    WITH (ONLINE = ON, MAXDOP = 4);
GO

-- Replaces index id=8, whose 8-column key buries COMPANY_NAME in position 2 so it never seeks
-- (500 MB for 20 seeks). 7,768 seeks, 99.86% impact. Drop id=8 in Part 3. Risk: LOW
CREATE NONCLUSTERED INDEX IX_tblGlass_LewisData_COMPANY_NAME_MEETING_DATE_MEETING_TYPE
    ON dbo.tblGlass_LewisData (COMPANY_NAME, MEETING_DATE, MEETING_TYPE)
    INCLUDE (pid, meeting_id, Meet_Checked)
    WITH (ONLINE = ON, RESUMABLE = ON, MAXDOP = 4);
GO
```

---

## Part 3 - Consolidation drops (run only after Parts 1-2 have run a full cycle)

Redundant because another index already covers them. Disable first - it is instant and reversible.
Rollback for each is the `CreateScript` column in the index usage export.

```sql
USE activist_insight;
GO

-- Replaced by: tbl13f_Holdings_scraped_filerid OR NonClusteredIndex-20171003-100706 (both exist).
-- R1 left-prefix: (Filer_id) leads both, so either serves its 332 reads. Reclaims 3.1 GB.
ALTER INDEX Idx_13f_holdings_filerid ON dbo.tbl13f_Holdings_scraped DISABLE;
GO

-- Replaced by: idxStockValues_csinumberDate (already exists).
-- R1 left-prefix on (csi_number), and it carries the same INCLUDE (symbol). Reclaims 4.7 GB.
ALTER INDEX idxStockValues_csinumber ON dbo.tblStock_values DISABLE;
GO

-- Replaced by: idx_cover_alert_id_pid (already exists).
-- R3: same key (alert_id) and this index's includes are a strict subset. 753 MB, 0 reads.
ALTER INDEX [NonClusteredIndex-20190213-164606] ON dbo.tblV2a_alert_companies_precalc DISABLE;
GO

-- Replaced by: idxmetric_cik__as (already exists).
-- R1 left-prefix on (metric_id). 477 MB, 0 reads.
ALTER INDEX [NonClusteredIndex-20160318-100853] ON dbo.tblFundamental_metric_values_historic DISABLE;
GO

-- Replaced by: IX_tblcompany_search_company_search_id_covering (created in Part 1).
-- R3 merge: same key (company_search_id), union of both include lists.
ALTER INDEX [NonClusteredIndex-20220329-153834] ON dbo.tblcompany_search DISABLE;
ALTER INDEX [NonClusteredIndex-20220329-162211] ON dbo.tblcompany_search DISABLE;
GO
```

```sql
USE proxy_insight;
GO

-- Replaced by: [Potentially RemoveNonClusteredIndex-20150619-101054] on the same table.
-- R1 left-prefix: (new_proposal_id) leads (new_proposal_id, fund_id) and neither has includes.
ALTER INDEX idx_update_tblvoting_data_processed_new_proposal_id ON dbo.tblvoting_data_ready_to_process_2018 DISABLE;
GO

-- Replaced by: [Potentially RemoveNonClusteredIndex-20181123-102821] on each of these tables.
-- R1 left-prefix, same as above. 2018 uses a differently named successor, handled separately.
-- The 2017 table is deliberately excluded - its includes are NOT a superset.
ALTER INDEX idx_update_tblvoting_data_processed_new_proposal_id ON dbo.tblvoting_data_ready_to_process_2019 DISABLE;
ALTER INDEX idx_update_tblvoting_data_processed_new_proposal_id ON dbo.tblvoting_data_ready_to_process_2020 DISABLE;
ALTER INDEX idx_update_tblvoting_data_processed_new_proposal_id ON dbo.tblvoting_data_ready_to_process_2021 DISABLE;
GO

-- Replaced by: IX_tblGlass_LewisData_COMPANY_NAME_MEETING_DATE_MEETING_TYPE (created in Part 2).
-- 8-column key buries COMPANY_NAME in position 2; 500 MB for only 20 seeks against 11,446 scans.
ALTER INDEX [NonClusteredIndex-20171130-130338] ON dbo.tblGlass_LewisData DISABLE;
GO
```

> **Caution on the four `tblvoting_data_ready_to_process_*` successors:** the replacement indexes are
> themselves named `Potentially Remove...`, so someone previously flagged them as removal candidates.
> They are the wider covering indexes here and currently carry the reads, so they must be kept if the
> narrower ones are disabled. Confirm nobody has a competing ticket to drop them.

---

## Part 4 - Secondary replica review

The readable secondary is lightly used: 4,989,543 reads on activist_insight and only **13,827 reads
on proxy_insight** across 105 days. Most of its missing-index recommendations show exactly 57 seeks,
which is the signature of a scheduled job (roughly one run every 44 hours), not user traffic.

**No new index is justified by secondary demand.** For scale, the largest secondary recommendation on
activist_insight has an improvement measure of 2,297 against the primary's top of 1,061,834.

Two worth recording as explicitly rejected:

| Table | Secondary recommendation | Decision |
|---|---|---|
| `tblvoting_import_check` (proxy) | inequality `import_status_id` + 8 includes, IM 37,222, **10 seeks** | Rejected. `idx_tblvoting_import_check_importstatusid_comprehensive` already covers all but `proposal_num` and `source_name`. Growing a 12 GB index for 10 seeks is indefensible. |
| `tblDirector_appointments` (activist) | `(typeNo)` + 5 includes, IM 2,297, 57 seeks | Rejected. Table already carries 5 nonclustered indexes; id=6 leads on `typeNo` and takes 1,154 secondary reads. |

Also note: index creation must happen on the primary and carries write cost there. Secondary
recommendations never show that side of the ledger.

---

## Part 5 - NEW FINDING: tblvoting_import_check is severely over-indexed

Surfaced only by looking at read/write ratio - it never appeared in the unused-index scan because
every index has *some* reads.

**118,408,620 rows. 14 nonclustered indexes totalling ~78 GB, on top of a 67.7 GB clustered index
(~146 GB in total). Eight of the fourteen lead on `import_status_id`. Most carry ~22.3 million
index updates each.**

Worst offenders by read/write ratio:

| id | Index | Size | Reads (105d) | Updates |
|---|---|---|---|---|
| 44 | `idx_..._datasourceid_year_importstatusid_investorid_investorname` | 9,116 MB | **760** | 22,279,491 |
| 49 | `idx_..._PID_rule_importstatusid` | 9,705 MB | 11,435 | 22,313,399 |
| 2 | `(import_status_id, dataSource_id, year, investor_id)` | 10,152 MB | 27,112 | 22,281,661 |

Two concrete actions:

```sql
USE proxy_insight;
GO

-- R3 strict duplicate: same key as ..._comprehensive, and its only INCLUDE (row_number) is already
-- in that index's include list. 2.3 MB of space but 22,276,457 index updates for nothing. Risk: LOW
ALTER INDEX idx_tblvoting_import_check_rownumber_importstatus ON dbo.tblvoting_import_check DISABLE;
GO

-- Cost/benefit, not a duplicate rule: 9.1 GB and 22.3M updates to serve 760 reads in 105 days
-- (about 7 per day). Confirm the owning process first - the name suggests a specific import path.
-- Risk: MEDIUM
ALTER INDEX idx_tblvoting_import_check_datasourceid_year_importstatusid_investorid_investorname
    ON dbo.tblvoting_import_check DISABLE;
GO
```

Optional R3 merge, **measure before committing**: `idx_..._importstatusid_legacyunmatched` (1,686 MB)
shares the `(import_status_id)` key with `..._comprehensive` and differs only by four extra include
columns (`validate_by`, `authorise_by`, `release_by`, `source_name`). Adding those four to the
12 GB comprehensive index would let the 1.7 GB one be dropped - but the growth may exceed the saving,
so this is roughly space-neutral and only wins by removing one index's write maintenance.

The remaining `import_status_id` indexes have genuinely divergent INCLUDE lists (R2), so they cannot
be collapsed on the rules alone. This table needs its own review driven by query-level evidence -
capture the actual statements from Query Store rather than working from DMV aggregates.

---

## Rejected recommendations - do not implement

| Table | Recommendation | Why rejected |
|---|---|---|
| `tblCommittee_Allowance_Payments` (activist) | 3 key + 11-13 include columns | 94.6M rows / 14 GB table for 479 seeks in 105 days (~4/day). R5 width limit and cost/benefit both fail. |
| `tblvoting_data_processed_by_invest_sync` (proxy) | 3 recommendations on vote_cast / match_* | Best is 23.4% impact / 1,841 seeks. Each index on this 169M-row table costs 5-6 GB and 331k+ updates. |
| `tblvoting_data_ready_to_process_2021` (proxy) | `(meeting_id)` | 99.96% impact but only 179 seeks, on a 55M-row / 17.8 GB table. Revisit after the dead indexes are cleared. |
| `tblNotified_stakes` (activist) | `(date_notified, insert_date)` | Inequality-only key so only the first column seeks, on a 26,321-row / 9.4 MB table. Marginal. |

---

## Do NOT drop despite looking redundant

```sql
-- proxy_insight.dbo.tblvoting_import_check
-- idx_tblvoting_import_check_importstatusid_comprehensive (12 GB) is a left-prefix match for three
-- wider indexes, but its 18-column INCLUDE list is not covered by any of them and it has 167,068 reads.
-- Key-prefix alone never justifies a drop - the INCLUDE list must also be a superset.
```

---

## Evaluate separately - clustered key on tblvoting_data_processed_by_invest_sync

Not a recommendation. Risk: **HIGH**.

Access pattern does not match the clustered key:
- clustered `(investor_id, proposal_id)`: 13,077 seeks but **798,022 lookups**
- `idx_..._proposal_id`: 849,565 seeks
- `idx_..._meeting_id`: 366,491 seeks

Queries enter by `proposal_id` / `meeting_id` then pay a lookup into a clustered key they rarely seek.
Changing it rewrites the 8.3 GB clustered index and all ~32 GB of nonclustered indexes (the clustered
key is their row locator), across an AG. The clustered index is also UNIQUE, so uniqueness would need
a separate constraint. Requires a restore to test, measured before/after, and its own change window.

---

## Verification

- Capture query duration, logical reads and plan shape via Query Store before each change.
- Sequence: create -> one full business cycle -> disable -> another cycle -> drop.
- Use `RESUMABLE = ON` for anything over a few GB so a build can be paused at the window boundary:
  `ALTER INDEX <name> ON <table> PAUSE;` / `RESUME;`
- Watch the AG redo queue on secondaries during large builds.
- Re-check the secondary after any failover: its usage counters reset, so a post-failover export
  restarts the evidence window.
- The 105-day window covers a quarter but not an annual cycle.
