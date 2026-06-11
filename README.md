# NHL Analytics Pipeline

> *"Can you run a franchise on this data?"*  
> A production-grade data engineering pipeline that ingests 19 years of NHL game data and surfaces five quantified commercial recommendations for franchise decision-makers.

---

## What This Is

A solo end-to-end rebuild of an NHL analytics pipeline, built to practice production data engineering patterns. The pipeline answers five real franchise decisions — modelled as if I were the front office of a $100M NHL franchise.

**Stack:** Python · Polars · DuckDB · dbt-duckdb · Jupyter  
**Architecture:** Medallion (Bronze → Silver → Gold)  
**Data:** 7 CSV source files · 5M+ event rows · 19 seasons (2000–2019)

---

## The Five Business Decisions

| # | The Call | Mart | Business Question |
|---|----------|------|-------------------|
| 1 | The Trade | `mart_player_season` | Which undervalued players to target? |
| 2 | The Drill | `mart_shot_zones` | Which shot zones to train players in? |
| 3 | The Penalty | `mart_penalty_cost` | When do penalties actually cost games? |
| 4 | The Arena | `mart_venue_advtg` | Where to schedule playoff games? |
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
- Pre-2010 seasons have **100% missing shot coordinates** — `mart_shot_zones` scoped to 2010+ for reliable analysis
- 633 games have `tbc` outcomes (winner unrecorded) — filtered at staging level
- **41% of goal events (61,740 of 148,992) are missing x/y coordinates** — a structural data quality finding documented end-to-end

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