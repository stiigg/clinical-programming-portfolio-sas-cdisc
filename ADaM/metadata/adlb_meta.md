# ADLB Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** LB  
**Keys:** USUBJID, PARAMCD, AVISITN, ADT

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| UNIT  | Char | Derived | Map LBORRESU via metadata/codelists.csv | Harmonized units |
| HIGHFL | Num | Derived | Compare AVAL to LBSTNRHI | 1=High, 0=Otherwise |
| LOWFL  | Num | Derived | Compare AVAL to LBSTNRLO | 1=Low, 0=Otherwise |

## Known Assumptions / Exceptions
- Normal range thresholds expected in SDTM; when missing, flags remain zero.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
