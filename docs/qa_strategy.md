# QA Strategy

The portfolio demonstrates an industrialized QA loop inspired by double programming guidance.

* **Independent derivations.** Dedicated QC programs in `validation/` re-create SDTM and ADaM domains without reusing production macros.
* **Automated comparisons.** `%qc_compare` wraps PROC COMPARE with consistent options, capturing diffs to the `qc` library.
* **Integrity checks.** `checks_integrity.sas` monitors duplicate records, missing subject relationships, and other business rules that P21 may miss.
* **Controlled terminology surveillance.** `%ct_check` imports EVS-driven spreadsheets and flags out-of-spec values before submission.
* **Traceability into documentation.** Regulatory outlines pull QC artifacts so that cSDRG/ADRG narratives always reference objective evidence.
