# Clinical Programming Portfolio (SAS + CDISC)

This repository now mirrors a miniature CRO workflow built around metadata-driven SDTM/ADaM production, independent QC, and regulatory deliverables.

## Getting Started

1. **Clone the repo** and update [`config/config_study.sas`](config/config_study.sas) with the absolute path to your local checkout.
2. (Optional) Adjust [`config/env_example.yaml`](config/env_example.yaml) if you orchestrate runs from Python/CI.
3. Execute the full pipeline in batch:
   * Windows: `batch\run_all_windows.bat`
   * macOS/Linux: `bash batch/run_all_unix.sh`

SAS logs are written to `outputs/logs/`. Use `%scan_log` from [`macros/cdisc_logging.sas`](macros/cdisc_logging.sas) to highlight warnings and errors.

## Repository Layout

* `config/` – Study/global SAS configuration plus environment examples.
* `data/` – Raw extracts, interim staging, and reference metadata (EVS CT, visit schedule).
* `specs/` – Authoritative SDTM and ADaM specifications, plus the domain table of contents.
* `macros/` – Reusable building blocks (`%sdtm_dm`, `%adam_adae`, `%ct_check`, logging/QC helpers, etc.).
* `etl/` – Drivers that loop through metadata and execute domain macros.
* `validation/` – Independent QC programs, integrity checks, and QC reporting.
* `regulatory/` – Scripts plus Markdown templates for define.xml narratives, cSDRG, and ADRG deliverables.
* `batch/` – Cross-platform launchers for the entire pipeline.
* `outputs/` – Destination libraries for SDTM, ADaM, QC artifacts, logs, and regulatory files.
* `docs/` – Architecture narratives, pipeline flow diagrams, QA strategy, and CDISC conventions.

## Talking Points

* **Specs as the source of truth:** No domain is processed unless it is activated in [`specs/spec_toc.csv`](specs/spec_toc.csv).
* **Metadata-driven macros:** ETL programs import specs and call standardized macros for each domain.
* **Paranoid QC:** Validation programs double-program key datasets and promote PROC COMPARE outputs to `qc/`.
* **Regulatory ready:** Reviewer guide outlines and define.xml snapshots are generated directly from metadata artifacts.
