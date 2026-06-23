# NHL Analytics Pipeline

> *"Can you run a franchise on this data?"*  
> A production-grade data engineering pipeline that ingests 19 years of NHL game data and surfaces five quantified commercial recommendations for franchise decision-makers.

---

## What This Is

A solo end-to-end rebuild of an NHL analytics pipeline, built to practice production data engineering patterns. The pipeline answers five real franchise decisions — modelled as if I were the front office of a $1.5B NHL franchise.

**Stack:** Python · Polars · DuckDB · dbt-duckdb · Jupyter  
**Architecture:** Medallion (Bronze → Silver → Gold)  
**Data:** 7 CSV source files · 5M+ event rows · 19 seasons (2000–2019)

---

## By the Numbers

- **5,050,529** play-by-play events across **23,735** games and **19 seasons**
- **7** staging views · **10** gold models (3 dims · 2 facts · 5 marts)
- **~2 min** full rebuild on a laptop (Polars ingest + dbt build)
- **46.3%** of goal records missing coordinates — a structural era boundary in NHL data collection

---

## The Five Business Decisions

| # | The Call | Mart | Business Question |
|---|----------|------|-------------------|
| 1 | The Trade | `mart_player_season` | Which undervalued players to target? |
| 2 | The Drill | `mart_shot_zones` | Which shot zones to train players in? |
| 3 | The Penalty | `mart_penalty_cost` | When do penalties actually cost games? |
| 4 | The Arena | `mart_venue_advtg` | How much does home ice actually matter? |
| 5 | The Future | `mart_team_traject` | Which franchises are rising or falling? |

---

## Architecture

```
Raw CSVs (Bronze)
    ↓  Polars ingestion with NA handling
Staging Views (Silver)
    ↓  dbt — type casting, deduplication, standardisation
Gold Tables
    ├── dim_game · dim_player · dim_team
    ├── fct_play · fct_game_teams_stats
    └── mart_player_season · mart_shot_zones · mart_penalty_cost
        mart_venue_advtg · mart_team_traject
```

---

## Key Findings

**Source data quality issues discovered and fixed:**

- `raw.game_plays`, `raw.game_penalties`, `raw.game_skater_stats` all contain duplicate rows in 2018–2019 seasons — fixed with `QUALIFY ROW_NUMBER()` deduplication in staging
- Pre-2010 seasons have **100% missing shot coordinates** (0 of 58,949 goal records located) — `mart_shot_zones` scoped to 2010+ for reliable analysis
- 633 games have `tbc` outcomes (winner unrecorded) — filtered at staging level
- **46.3% of goal events (61,737 of 133,345) are missing x/y coordinates** — corrected from an initial 41.4% (61,740 of 148,992) after fixing a duplicate-row bug in `raw.game`
- `mart_shot_zones` zone definition refined: `slot` split into `low_slot` (x ≥ 69, |y| ≤ 22) and `high_slot` (54 ≤ x ≤ 68, |y| ≤ 22) per NHL convention — surfaces a clean conversion gradient (low_slot 19.45% → high_slot 12.04% → wings ~3%)

---

## How to Run

**Prerequisites:** Python 3.11, WSL Ubuntu (Windows) or Linux/Mac

**1. Clone and set up environment**

```bash
git clone https://github.com/yhtande/nhl-practice.git
cd nhl-practice
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**2. Ingest raw data (Bronze layer)**

```bash
python python/ingest.py
```

**3. Run dbt (Silver + Gold layers)**

```bash
cd nhl_dbt
dbt run
dbt test
```

**4. Explore in Jupyter**

```bash
cd ..
jupyter notebook --no-browser
```

---

## Project Structure

```
nhl-practice/
├── python/              # Polars ingestion scripts
├── nhl_dbt/
│   └── models/
│       ├── staging/     # Silver layer — 7 staging views
│       └── gold/        # Gold layer — dims, facts, marts
├── notebook/            # Exploration and verification notebooks
├── requirements.txt
└── .gitignore
```

---

## What I Learned

- Medallion architecture with dbt + DuckDB end-to-end
- Source data deduplication with `QUALIFY ROW_NUMBER()` in DuckDB
- Debugging fan-out joins and tracing duplicates from raw → staging → gold
- Designing mart grain for business questions vs technical convenience
- dbt schema tests, model descriptions, and documentation generation
- Caught and fixed a duplicate-row bug in `raw.game` that inflated post-2010 goal counts by ~11% — surfaced only by hand-validating absolute counts against raw source data, not by structural dbt tests. Rate-based metrics survive uniform multiplication; absolute counts don't.
