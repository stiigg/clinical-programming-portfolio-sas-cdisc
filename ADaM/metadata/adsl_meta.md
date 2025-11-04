# ADSL Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** DM, EX  
**Keys:** USUBJID

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| TRTSDT  | Num  | Derived                | Minimum of EXSTDTC or RFSTDTC | `TRTSDT_SRC`/`TRTSDT_IMPFL` capture source and imputation |
| TRTEDT  | Num  | Derived                | Maximum of EXENDTC or RFENDTC | `TRTEDT_SRC`/`TRTEDT_IMPFL` capture source and imputation |
| RANDDT  | Num  | Derived                | Conversion of RFXSTDTC        | Traceability stored in `RANDDT_SRC` |
| AGE     | Num  | Derived                | Floor((TRTSDT or RANDDT) - BRTHDT)/365.25 | Falls back to reported AGE when dates missing |
| AGEGR1  | Char | Derived                | Bucketized AGE (<18, 18-64, 65-74, 75+) | Supports age subgroup analyses |
| EFFFL   | Char | Derived                | `Y` if RANDDT populated       | |
| PPSFL   | Char | Derived                | `Y` if PPWHY missing; synchronized with PPFL | |
| ITTFL   | Char | Derived                | `%popflags` macro             | |
| SAFFL   | Char | Derived                | `%popflags` macro             | Uses derived TRTSDT |
| PPFL    | Char | Derived                | `%popflags` macro             | Retained for compatibility |
| PPWHY   | Char | SDTM.DM / Derived      | Direct pull of PPWHY from DM; blanked when PPFL = 'Y' | |

## Known Assumptions / Exceptions
- Exposure data may be absent; baseline dates fallback to DM references and imputation flags capture the decision.
- Age derivation prioritizes actual exposure/randomization date; reported AGE is only used when event dates are missing.
- Population flags leverage `%popflags` macro; PPSFL mirrors PPFL for ADaM-compliant naming.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
