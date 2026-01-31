# ⚡ NOR_EV_Chargers: Norway EV Infrastructure Analysis

An end-to-end data engineering and analytics dashboard visualizing the growth and distribution of electric vehicle charging stations across Norway. This project uses **dbt** for data transformation and **Evidence** for high-performance data storytelling.

🚀 **[View the Live Dashboard](https://pauliusc99.github.io/NOR_EV_Chargers/)**

---

## 📥 Data Sources

This project harmonizes two primary datasets to provide geographical and longitudinal insights:

* **NOBIL API:** Contains comprehensive data on EV charging stations (location, connector types, ownership, and accessibility). The dataset includes historical records from **2010 to the present day**, enabling growth trend analysis.
* **Kartverket (Norwegian Mapping Authority):** Administrative boundary data for Norwegian counties (*fylker*) and municipalities, used to join geographic station data with regional metadata.

---

## 🛠️ Tech Stack

- **Data Warehouse:** [DuckDB](https://duckdb.org/)
- **Transformation:** [dbt-duckdb](https://github.com/jwills/dbt-duckdb)
- **Frontend/BI:** [Evidence.dev](https://evidence.dev/) (Markdown + SQL)
- **Deployment:** GitHub Actions & GitHub Pages
- **Environment:** Node.js v22 & Python 3.10+

---

## 📂 Project Structure

```text
nor_ev_chargers/
├── .github/           # GitHub Actions CI/CD workflows
├── ev_chargers_dbt/   # dbt project (SQL models, seeds, and schema)
├── dashboard/         # Evidence project (UI and data visualization)
│   └── dev.duckdb     # Local analytical database powering the UI
└── README.md          # Project documentation
```
## ⚙️ Setup & Installation

### 1. Set Up the Data Pipeline (dbt)

The transformation layer requires dbt-core and the dbt-duckdb adapter (which includes the DuckDB engine).

```Bash
# 1. Navigate to the dbt directory
cd ev_chargers_dbt

# 2. Install dbt and DuckDB adapter
pip install dbt-core dbt-duckdb

# 3. Execute the pipeline
dbt run    # Run models
dbt test   # Validate data
dbt build  # Run and test all (recommended)
```
### 2. Set Up the Dashboard (Evidence)
After the dbt build is complete and the dev.duckdb file is present in the dashboard folder:

```Bash
# 1. Navigate to the dashboard directory
cd ../dashboard

# 2. Install dependencies
npm install

# 3. Process data sources and start the server
npm run sources
npm run dev
```
The dashboard will be available at:

http://localhost:3001/NOR_EV_Chargers

## Note:
The sources in dbt are given using absolute paths. Go to ev_chargers_dbt/models/raw and configure the two yaml files with correct paths.
