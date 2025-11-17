# Clinical Programming Portfolio (SAS + CDISC)

This repository now mirrors a miniature CRO workflow built around metadata-driven SDTM/ADaM/TF generation, independent QC, and regulatory deliverables.

## Getting Started

1. **Clone the repo**.
2. Define the repo root for SAS (`%let ROOT=/path/to/clinical-programming-portfolio-sas-cdisc;`) or let the batch scripts pass it in automatically.
3. Choose a run definition under [`config/run_*.sas`](config) (e.g., `run_LOCK_MAIN.sas` or `run_INTERIM_2025M10.sas`). Add more files for each data cut or exploratory batch.
4. Execute the pipeline by passing the run name to the launcher:
   * Windows: `batch\run_all_windows.bat LOCK_MAIN`
   * macOS/Linux: `bash batch/run_all_unix.sh LOCK_MAIN`

[`config/global_config.sas`](config/global_config.sas) establishes the study-wide libraries and options, while [`config/select_run.sas`](config/select_run.sas) routes the `RUN` argument to the matching `config/run_*.sas` file. SAS logs are written to `outputs/logs/<run>/` and automatically scanned at the end of each run.

## Repository Layout

* `config/` – Study-wide SAS configuration (`global_config.sas`), run dispatcher (`select_run.sas`), and one `run_*.sas` per data cut.
* `specs/` – Metadata repository (dataset, variable, value-level, codelist, TLF specs, etc.).
* `macros/` – Reusable building blocks (`%sdtm_dm`, `%adam_adae`, population/endpoints, TLF dispatcher, logging, etc.).
* `etl/` – Drivers/orchestrators that loop through metadata and execute domain macros.
* `validation/` – Independent QC programs, regression harness, log scanners, and QC reporting.
* `regulatory/` – Scripts plus Markdown templates for define.xml narratives, cSDRG, and ADRG deliverables.
* `batch/` – Cross-platform launchers for the entire pipeline.
* `outputs/` – Destination libraries for SDTM, ADaM, QC artifacts, logs, and regulatory files.
* `docs/` – Architecture narratives, pipeline flow diagrams, QA strategy, and CDISC conventions.

## Talking Points

* **Run configs as a single source of truth:** The SAS files in `config/run_*.sas` capture data cut, SAP version, mode, and output switches. `config/select_run.sas` simply `%INCLUDE`s the right file based on `RUN=`, so no driver hardcodes lock-week parameters or relies on Python/YAML transforms.
* **Specs steer execution:** SDTM domains are still activated via [`specs/spec_toc.csv`](specs/spec_toc.csv), while [`specs/spec_tlf.csv`](specs/spec_tlf.csv) now controls which TLFs run per LOCK/INTERIM/EXPLORATORY set.
* **Metadata-driven macros:** ETL programs import specs and call standardized macros for each domain, with `%tlf_dispatch` routing TLF metadata to the right reusable program.
* **Centralized populations/endpoints:** `%derive_pop_flags`, `%get_pop_where`, and `%derive_time_to_event` keep population and endpoint logic in one location so SAP changes propagate instantly.
* **Provenance + QC:** `%run_init`, `%stamp_dataset`, `%footnote_run`, row-count logging, log scanning, and [`validation/compare_runs.sas`](validation/compare_runs.sas) make every run traceable and regression-friendly.
* **Regulatory ready:** Reviewer guide outlines and define.xml snapshots are generated directly from metadata artifacts.
