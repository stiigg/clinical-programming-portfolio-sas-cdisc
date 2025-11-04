# ADAE Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** AE, DM  
**Keys:** USUBJID, AESEQ

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| AESEV_STD | Char | Derived | Map AESEV using metadata/codelists.csv | Controlled terminology |
| AESER_STD | Char | Derived | Map AESER using metadata/codelists.csv | Seriousness normalized |
| ASTDT     | Num  | Derived | Input(AESTDTC, yymmdd10.) | ISO8601 conversion |

## Known Assumptions / Exceptions
- Serious adverse event flags default to original SDTM values when mappings absent.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
