# ADTTE Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** DS  
**Keys:** USUBJID, ASEQ

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| ADT   | Num  | Derived | Event date or censor date | Derived from DSSTDTC or TRTSDT |
| CNSR  | Num  | Derived | 0 if event present, 1 otherwise | Aligns with CDISC guidance |
| AVAL  | Num  | Derived | Days from TRTSDT to ADT + 1 | Requires TRTSDT from ADSL |

## Known Assumptions / Exceptions
- Currently supports DEATH and PROGRESSION events; extend metadata for additional endpoints.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
