# Architecture Overview

This repository is organized as a miniature, audit-ready clinical programming environment.  The tree aligns to the metadata-driven workflow used across CROs and sponsors.

```
clinical-programming-portfolio-sas-cdisc/
├─ config/                  # SAS and automation configuration
├─ data/                    # Raw, interim, and reference data sources
├─ specs/                   # SDTM/ADaM/CT specifications (single source of truth)
├─ macros/                  # Reusable transformation, QC, and compliance macros
├─ etl/                     # Drivers orchestrating SDTM/ADaM derivations
├─ validation/              # Independent QC, integrity checks, and summaries
├─ regulatory/              # define.xml + reviewer guide scaffolding
├─ batch/                   # OS-level launchers for CI/CD style execution
├─ outputs/                 # SDTM, ADaM, QC, regulatory deliverables, logs
└─ docs/                    # Narrative documentation for interviews and audits
```

Key principles:

* **Specs are sovereign.** Every domain processed by the pipeline is declared in `specs/spec_toc.csv` and mapped via text-based metadata under version control.
* **Macros form the nervous system.** All SDTM and ADaM derivations live in `macros/` and are invoked by the ETL drivers.
* **Validation is independent.** The `validation/` folder doubles programs, runs PROC COMPARE, and aggregates QC findings.
* **Regulatory outputs are first-class.** define.xml, ADRG, and cSDRG outlines are generated from the same metadata stack used for datasets.
