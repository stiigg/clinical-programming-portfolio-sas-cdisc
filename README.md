# Clinical Programming Portfolio (SAS + CDISC)

This repository now mirrors a miniature CRO workflow built around metadata-driven SDTM/ADaM/TF generation, independent QC, and regulatory deliverables.

## Getting Started

1. **Clone the repo** and update [`config/config_study.sas`](config/config_study.sas) with the absolute path to your local checkout.
2. Pick a run configuration YAML in [`config/`](config) (e.g., `env_lock_2025Q1.yaml`). The file controls study mode, SAP version, TLF set, and output locations.
3. Generate `config_run_auto.sas` and execute the pipeline:
   * Windows: `batch\run_all_windows.bat env_lock_2025Q1.yaml`
   * macOS/Linux: `bash batch/run_all_unix.sh env_lock_2025Q1.yaml`

The batch scripts call [`config/build_run_config.py`](config/build_run_config.py) to translate the YAML into `%LET` statements that every driver includes via `config_run_auto.sas`. SAS logs are written to `outputs/logs/` and automatically scanned at the end of each run.

## Repository Layout

* `config/` – Study/global SAS configuration plus concrete environment YAMLs.
* `specs/` – Metadata repository (dataset, variable, value-level, codelist, TLF specs, etc.).
* `macros/` – Reusable building blocks (`%sdtm_dm`, `%adam_adae`, population/endpoints, TLF dispatcher, logging, etc.).
* `etl/` – Drivers/orchestrators that loop through metadata and execute domain macros.
* `validation/` – Independent QC programs, regression harness, log scanners, and QC reporting.
* `regulatory/` – Scripts plus Markdown templates for define.xml narratives, cSDRG, and ADRG deliverables.
* `batch/` – Cross-platform launchers for the entire pipeline.
* `outputs/` – Destination libraries for SDTM, ADaM, QC artifacts, logs, and regulatory files.
* `docs/` – Architecture narratives, pipeline flow diagrams, QA strategy, and CDISC conventions.

## Talking Points

* **Run configs as a single source of truth:** The YAML files in `config/` capture data cut, SAP version, mode, and output switches. They are converted into SAS macro variables via `build_run_config.py`, so no driver hardcodes lock-week parameters.
* **Specs steer execution:** SDTM domains are still activated via [`specs/spec_toc.csv`](specs/spec_toc.csv), while [`specs/spec_tlf.csv`](specs/spec_tlf.csv) now controls which TLFs run per LOCK/INTERIM/EXPLORATORY set.
* **Metadata-driven macros:** ETL programs import specs and call standardized macros for each domain, with `%tlf_dispatch` routing TLF metadata to the right reusable program.
* **Centralized populations/endpoints:** `%derive_pop_flags`, `%get_pop_where`, and `%derive_time_to_event` keep population and endpoint logic in one location so SAP changes propagate instantly.
* **Provenance + QC:** `%run_init`, `%stamp_dataset`, `%footnote_run`, row-count logging, log scanning, and [`validation/compare_runs.sas`](validation/compare_runs.sas) make every run traceable and regression-friendly.
* **Regulatory ready:** Reviewer guide outlines and define.xml snapshots are generated directly from metadata artifacts.
