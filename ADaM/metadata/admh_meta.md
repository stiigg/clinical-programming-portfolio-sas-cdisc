# ADMH Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** MH  
**Keys:** USUBJID, SRCSEQ

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| CATFL | Char | Derived | Map MHCAT to standardized flag | Defaults to 'N' |
| MHSTDAT | Num | Derived | Input(MHSTDTC, yymmdd10.) | ISO8601 conversion |
| MHENDAT | Num | Derived | Input(MHENDTC, yymmdd10.) | ISO8601 conversion |

## Known Assumptions / Exceptions
- Only category-based indicators are derived; sponsor-specific flags may be added as needed.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
