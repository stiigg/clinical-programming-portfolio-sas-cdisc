# ADSL Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** DM, EX  
**Keys:** USUBJID

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| TRTSDT  | Num  | Derived                | Minimum of EXSTDTC or RFSTDTC | Aligns with treatment start |
| RANDDT  | Num  | Derived                | Conversion of RFXSTDTC        | Requires ISO8601 input |
| ITTFL   | Char | Derived                | `%popflags` macro             | | 

## Known Assumptions / Exceptions
- Exposure data may be absent; baseline dates fallback to DM references.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
