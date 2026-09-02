---
name: review-missing-indexes
description: Guided workflow for reviewing SQL Server missing-index recommendations against existing index usage and schema, applying duplicate and consolidation rules, and producing index change scripts with ONLINE and rollback guidance. Use when the user asks to review missing indexes, walk through index tuning, provides missing-index DMV output, or an execution plan shows a missing index hint.
---

# Skill: Review Missing Indexes for SQL Server (Guided)

Load `.github/skills/standard/standard.md` alongside this skill. Every recommendation follows its
P0.2 (rollback scripts), P0.3 (risk level), P1.6 (write impact), P2.3 (edition awareness) and
P2.5 (consolidation) rules.

## When to use
- "Review missing index statistics" / "walk me through index tuning"
- User provides `sys.dm_db_missing_index_*` output or an execution plan with a missing index hint
- Periodic index review for a product database
- Following expensive-query or execution-plan analysis that flagged scans

## Goal
Turn raw optimizer missing-index wishes into a small, non-redundant set of index changes by
cross-checking them against existing index definitions, usage statistics, and the product schema.

---

## Procedure

Work through these steps in order. Do not skip to recommendations before Steps 1-4 have data.

### Step 0 - Establish context
Ask for, or confirm from provided data:
- **Product / application name** - drives the `workspace/` and `assets/` folder names below
- **Edition and version** - determines ONLINE eligibility:
  ```sql
  SELECT
      Edition        = SERVERPROPERTY('Edition'),
      ProductVersion = SERVERPROPERTY('ProductVersion'),
      EngineEdition  = SERVERPROPERTY('EngineEdition'),  -- 3 = Enterprise/Developer, 5 = Azure SQL DB
      StartTime      = (SELECT sqlserver_start_time FROM sys.dm_os_sys_info);
  ```
- **Workload type** - OLTP, OLAP, or mixed
- **Operational constraints** - maintenance window, AlwaysOn AG, replication/CDC, 24/7 requirement
- **Readable secondaries** - ask directly whether any replica is readable and whether read-only
  routing or reporting connections target it. This determines whether primary-only usage data is
  sufficient to judge an index unused (see Step 2).

If `sqlserver_start_time` is recent (days rather than a full business cycle), state up front that
both DMVs are incomplete and that drop recommendations are provisional.

### Step 1 - Collect missing index statistics
Ask the user to run `queries/sqlserver/index-missing.sql` in the target database.
Ranking is by `ImprovementMeasure`; treat it as relative ordering only, never as a promised gain.

### Step 2 - Collect index usage statistics and definitions
Ask the user to run `queries/sqlserver/index-usage-stats.sql` in the same database.
This is mandatory, not optional - missing-index output alone cannot show what already exists.
It supplies `KeyColumnsNormalized`, `IncludeColumnsNormalized`, `IndexSignature`, sizes, read/write
counts, and ready-made `CreateScript` / `DropScript` values for rollback.

**If the database is in an Availability Group with any readable secondary, run it on every readable
replica as well, not just the primary.** `sys.dm_db_index_usage_stats` is instance-local and is not
replicated: reads served on a secondary through read-only routing are recorded *only* on that
secondary. An index that looks completely unused on the primary can be carrying the entire reporting
workload on a secondary. Classifying it as unused from primary-only data will drop an index that is
in active use.

When collecting from secondaries:
- Label each export with its replica name so the analysis can union them per index.
- An index counts as unused only when reads are zero on **every** replica.
- Secondary counters reset on replica restart and on failover, and are lost when the replica leaves
  the AG - so a secondary's window is often shorter than the primary's. Report the shortest window
  across all replicas as the effective evidence window.
- Writes (`user_updates`) are only meaningful on the primary; secondaries show the read side.

### Step 3 - Schema availability
Check `assets/<product-name>/schemas/` for a stored schema for this product.
- **Present**: use it to validate column names, data types, key widths, and foreign keys.
- **Absent**: ask the user to provide the schema (DDL script, `sys.indexes`/`sys.columns` extract,
  or a database project). Explain why: without it, recommendations risk duplicating an existing
  index or missing an opportunity to extend one instead of adding another.
- When a schema is supplied for a product not yet stored, save it under
  `assets/<product-name>/schemas/` so later reviews reuse it. Confirm the product name first.

### Step 4 - Input drop-off
Ask the user to place every relevant file - query results, execution plans, schema, and any notes
on workload or constraints - in `workspace/<product-name>/`. File names are free-form; classify
each file by inspecting its content. Confirm what was found before analysing.

### Step 5 - Analyse
Apply the consolidation rules below to the union of existing indexes (Step 2) and recommendations
(Step 1), per table. Never propose an index whose columns cannot be confirmed from the schema or
the provided output.

### Step 6 - Recommend
Emit the change set using the output format at the end of this file.

### Step 7 - Write the deliverables
Always produce two markdown files in `workspace/<product-name>/`, in addition to the chat summary:

1. **`index-recommendations.md`** - new indexes, consolidations, rejected recommendations, and
   anything flagged for separate evaluation.
2. **`unused-indexes-to-drop.md`** - every zero-read index, kept separate so the removal work can be
   scheduled and approved independently of the additions.

Rules for both files:
- **Plain, runnable T-SQL.** No placeholders, no pseudo-code, no invented index or column names -
  every identifier must come from the provided exports or schema.
- **1-3 comment lines per statement**, giving the evidence (seeks, impact, size, rows, updates), the
  rule applied (R1-R5) and the risk level. Do not restate what the SQL already says.
- Group by database with `USE <database>;` / `GO` headers so each script runs as-is.
- Order statements by execution sequence: create -> validate -> disable -> drop.
- Lead every removal with `ALTER INDEX ... DISABLE` and keep `DROP INDEX` as a commented follow-up,
  with the rollback rebuild on the next line.
- **When a removal is a consolidation (R1 or R3), the first comment line must name the index that
  replaces it** - e.g. `-- Replaced by IX_tbl_col_a_col_b`. The successor comes before the evidence
  and the rule reference, so a reviewer sees the coverage guarantee first and can verify it without
  reading the rest of the entry. Removals that are not consolidations (unused, cost/benefit) have no
  successor, so they open with the evidence instead.

When the unused-index list runs to dozens of entries, generate the file from the export data with a
script rather than transcribing by hand - the `CreateScript` and `DropScript` columns produced by
`index-usage-stats.sql` already contain exact, verified text.

---

## Consolidation rules

### R1 - Left-prefix redundancy
An index is redundant when another index has the same leading key columns in the same order plus
more. The wider index serves the narrower one's workload; the reverse is **not** true.

```sql
CREATE INDEX Index1 ON T (Col1);        -- redundant
CREATE INDEX Index2 ON T (Col1, Col2);  -- covers Index1's seeks as well
```

When the recommendation is the wider index and the narrower one already exists: **create the wider
index first, validate, then drop the narrower one.** Never sequence the drop before the create.

Detection: `Index2.KeyColumnsNormalized LIKE Index1.KeyColumnsNormalized + '%'` (compare on a
column-boundary match, not raw substring - `col1` must not match `col10`).

### R2 - Borderline duplicates (keep both)
When keys share a prefix but diverge after it, both indexes are required. No action.

```sql
CREATE INDEX Index1 ON T (Col1, Col3);
CREATE INDEX Index2 ON T (Col1, Col2);  -- neither covers the other beyond Col1
```

Do not propose a three-column merge here unless the missing-index data shows demand for that exact
key order.

### R3 - INCLUDE merge
Indexes whose keys are equal or in a left-prefix relationship, differing only in INCLUDE lists,
merge into one: **widest key + union of includes, minus any column promoted into the key.**

```sql
-- Before
CREATE INDEX Index1  ON T (Col1) INCLUDE (Col2, Col3);
CREATE INDEX Index1b ON T (Col1) INCLUDE (Col3);
CREATE INDEX Index2  ON T (Col1, Col2);

-- After
CREATE INDEX Index2 ON T (Col1, Col2) INCLUDE (Col3);
```

`Col2` moves from INCLUDE into the key, so it drops out of the include list. Use
`IncludeColumnsNormalized` (sorted) for the comparison so include ordering does not create false
distinctions. Watch total row width - a merged index whose includes balloon the leaf level can cost
more than the two it replaces.

### R4 - Clustered index swap
If usage statistics show heavy `user_lookups` on the clustered index (index_id 1) alongside strong
`user_seeks` concentrated on a single nonclustered index, raise changing the clustered key as an
option worth evaluating - the access pattern suggests the current clustered key does not match how
the table is queried.

Present this as an option with evidence, not a directive. It is **HIGH risk**: the table is fully
rebuilt, every nonclustered index is rewritten (the clustered key is their row locator), and it
needs a maintenance window unless Enterprise ONLINE is available.

### R5 - Width limits
- Avoid more than **5 key columns** unless the impact data clearly justifies it; state the
  justification when exceeding it.
- Flag `KeyWidthBytes` approaching the 900-byte (clustered / pre-2016 nonclustered) or 1700-byte
  (nonclustered, 2016+) limit.
- Do not blindly accept the optimizer's INCLUDE list - it often lists every column in the SELECT.
  Trim includes that only serve one low-frequency query.

### Guards (never violate)
- Never classify an index as unused from primary-only data when a readable secondary exists - see
  Step 2. Read-only routed workloads register usage only on the replica that served them.
- Never drop or merge a primary key, unique constraint, or unique index.
- Never drop an index supporting foreign key enforcement without confirming the FK's access path.
- Treat filtered indexes separately - two indexes with identical keys but different
  `filter_definition` values are **not** duplicates.
- Never drop indexes required by replication, CDC, or Change Tracking.
- Columnstore, XML, spatial, and full-text indexes are out of scope for R1-R3.
- Disabled indexes (`IsDisabled = 1`) show no usage by definition - do not classify them as unused.

---

## Validation before recommending
- Does an existing index already satisfy the recommendation (exact or left-prefix)? Then extend or
  skip, do not create.
- Is the table small enough that a scan is cheap? Report row count and skip marginal indexes.
- Is the read/write ratio poor (`ReadWriteRatio` low, high `user_updates`)? Quantify the write cost.
- Do multiple recommendations on the same table collapse into one index under R1/R3?
- Are the `equality_columns` selective? A leading low-selectivity column wastes the index.
- Would updating statistics or rewriting the query resolve it without a new index?

---

## Constraints
- Do not implement every missing-index recommendation - they are per-query wishes with no awareness
  of each other or of existing indexes.
- Never guess column names, data types, or existing indexes not present in the provided data.
- Always pair a DROP with its rollback CREATE script and sequence it after the replacement is
  validated in production.
- State the DMV collection window whenever recommending a drop.
- Recommend testing in a non-production environment first.

---

## Output format

The chat response is a summary; the runnable scripts live in the two files from Step 7. Keep the
chat output readable and let the files carry the full statement list.

Follow the output template in `.github/skills/standard/standard.md`, with these specifics:

### Summary
- Recommendations reviewed, existing indexes analysed, tables affected
- Net index count change (created / merged / dropped)
- DMV collection window and whether it covers a full business cycle
- Edition and therefore whether `ONLINE = ON` is available

### Recommended changes (ordered: create -> validate -> drop)
For each change:
- **Table**
- **Action**: CREATE / MERGE (create + drop) / DROP / EVALUATE
- **Script**: full statement. On Enterprise or Developer edition append
  `WITH (ONLINE = ON, MAXDOP = 0)`; otherwise note the blocking rebuild and the required window.
- **Rule applied**: R1 / R2 / R3 / R4 / R5 or "new index"
- **Evidence**: impact measure, seeks/scans, row count, existing index it replaces
- **Write cost**: `user_updates` on the table and the read/write ratio
- **Risk**: LOW / MEDIUM / HIGH with reasoning
- **Rollback**: the `CreateScript` for anything dropped

### Keep as-is
Existing or recommended indexes deliberately left alone, with the rule that spared them (usually R2).

### Evaluate separately
Clustered-key swap candidates (R4) and anything needing more data.

### Verification
- Metrics to capture before and after (query duration, logical reads, plan shape)
- How long to run with the new index before executing any drop
- Query Store or plan-cache comparison approach

### Follow-up
- Whether a longer DMV collection period is needed
- Whether the schema should be stored under `assets/<product-name>/schemas/` for next time
- Related diagnostics: `queries/sqlserver/expensive-queries.sql`,
  `.github/skills/sqlserver/review-index-usage.md`
