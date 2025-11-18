# QA Strategy

The portfolio demonstrates an industrialized QA loop inspired by double programming guidance.

* **Independent derivations.** Dedicated QC programs in `validation/` re-create SDTM and ADaM domains without reusing production macros.
* **Automated comparisons.** `%qc_compare` wraps PROC COMPARE with consistent options, capturing diffs to the `qc` library.
* **Integrity checks.** `checks_integrity.sas` monitors duplicate records, missing subject relationships, and other business rules that P21 may miss.
* **Controlled terminology surveillance.** `%ct_check` imports EVS-driven spreadsheets and flags out-of-spec values before submission.
* **Traceability into documentation.** Regulatory outlines pull QC artifacts so that cSDRG/ADRG narratives always reference objective evidence.

## QC tiers for TLFs

Risk-scored metadata is now the control plane for TLF QC. `specs/spec_tlf.csv` records the intended QC tier, method, and CtQ flag for each output alongside the production parameters that already drove `%tlf_dispatch`. The tiers align to common regulatory expectations:

| Tier | Definition | Default method | Example |
| ---- | ---------- | --------------- | ------- |
| 1 | Critical endpoints that support primary/secondary SAP objectives or CtQ deliverables | `DOUBLE_PROG` | OS, PFS, key safety tables |
| 2 | Important but supporting summaries | `IND_REVIEW` | Interim listings, sensitivity outputs |
| 3 | Exploratory or low-risk outputs | `TARGETED` | Biomarker experiments |

`RUN_SET` partitions the metadata by run (e.g., `LOCK_MAIN`, `INTERIM_2025M10`) so that every batch has an explicit QC plan baked in.

## Metadata-driven execution

`etl/etl_tlf.sas` ingests the TLF spec, filters it to the requested `RUN_SET`, and writes `qc.qc_plan_<RUN_SET>` for audit purposes. `%tlf_dispatch` then loops over `work.tlf_runlist`, logs each output with the associated tier/method, and invokes the appropriate reusable macro (e.g., `efficacy_generic`).

The QC metadata is consumed by `validation/run_qc_by_tier.sas`:

1. Tier 1 + `DOUBLE_PROG` entries must have a matching `_qc` program in `validation/`. The driver `%include`s that code, writes QC datasets (e.g., `qc.qc_T14_1`), and runs `%qc_compare_tlf` to capture PROC COMPARE results in the `qc` library.
2. Tier 2 outputs log their independent-review requirement, enabling assignment tracking outside of SAS if desired.
3. Tier 3 outputs log that only targeted QC (structure + spot checks) is expected.

All QC artifacts roll up into `qc.qc_summary_<RUN_SET>` and an exported CSV under `outputs/qc/`, so the same metadata that defines risk now proves what was executed.

## Referencing the strategy

* QC metadata → `specs/spec_tlf.csv`
* Load & dispatch → `etl/etl_tlf.sas`, `%tlf_dispatch`
* Tier logic → `validation/qc_compare_tlf.sas`, `validation/run_qc_by_tier.sas`
* Sample QC programs → `validation/prog_*_qc.sas`

This mirrors published RBQM automation patterns (e.g., CDISC 360 pilots) and creates a clean chain from SAP priority → metadata → automated QC evidence.
