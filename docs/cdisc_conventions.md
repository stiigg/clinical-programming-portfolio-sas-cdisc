# CDISC Conventions

* **Standards.** SDTM IG 3.4 and ADaM IG 1.1 are assumed.  Update `config/global_config.sas` when migrating to new standards.
* **Variable casing.** All production datasets use uppercase variable names, complying with FDA expectations.
* **Origins.** Mapping spreadsheets capture ORIGIN values (CRF, DERIVED, ASSIGNED) for traceability into define.xml.
* **Date handling.** ISO8601 character dates are retained alongside numeric SAS dates (`RFSTDTC` + `RFSTD`).
* **Controlled terminology.** EVS extractions live under `data/reference/`.  `%ct_check` enforces compliance during ADaM creation.
* **Spec governance.** No derivation occurs unless the domain is active in `specs/spec_toc.csv`.
