# Pipeline Flow

1. **Initialize Environment**
   * `%cdisc_init` pulls `config/config_study.sas` and `config/config_global.sas`.
   * Libraries are assigned for `raw`, `sdtm`, `adam`, `qc`, and `meta`.
   * Macro search paths and project metadata variables are set.

2. **Raw ➜ SDTM (`etl/raw_to_sdtm.sas`)**
   * `%process_domains(type=SDTM)` reads `specs/spec_toc.csv` to determine active domains.
   * Domain macros such as `%sdtm_dm` and `%sdtm_ae` import CSV extracts, tag study-level metadata, and apply shared derivations.
   * `%sdtm_standard_checks` runs baseline QC (key uniqueness, frequency checks) for every domain.

3. **SDTM ➜ ADaM (`etl/sdtm_to_adam.sas`)**
   * `%process_domains(type=ADaM)` loops over ADaM domains declared in the spec.
   * `%adam_adsl` and `%adam_adae` derive analysis ready variables and controlled terminology flags.
   * `%ct_check` enforces NCI EVS-controlled values with outputs stored in `qc.ct_issues`.

4. **Validation Layer (`validation/`)**
   * `sdtm_qc_main.sas` and `adam_qc_main.sas` regenerate datasets using alternate logic and compare via `%qc_compare`.
   * `checks_integrity.sas` surfaces relational issues (duplicate AEs, missing ADSL subjects).
   * `generate_qc_report.sas` compiles QC artifacts into a reviewer-friendly table.

5. **Regulatory Layer (`regulatory/`)**
   * `generate_define.sas` snapshots metadata to feed define.xml tools.
   * `generate_cSDRG_outline.sas` and `generate_ADRG_outline.sas` auto-populate reviewer guide outlines with QC references.
   * Templates under `regulatory/templates/` provide Markdown outlines for cSDRG and ADRG narrative completion.

6. **Automation (`batch/`)**
   * `run_all_windows.bat` and `run_all_unix.sh` orchestrate the full stack for CI/CD schedulers.
   * Logs land in `outputs/logs/` and can be parsed using `%scan_log` from `macros/cdisc_logging.sas`.
