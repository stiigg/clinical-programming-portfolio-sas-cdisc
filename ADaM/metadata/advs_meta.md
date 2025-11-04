# ADVS Metadata

**Spec version:** SpecID=YYYYMMDD  
**Source SDTM:** VS  
**Keys:** USUBJID, PARAMCD, AVISITN, ADT

## Derivation Summary
| Variable | Type | Origin (SDTM/Derived) | Rule | Notes |
|---------|------|------------------------|------|------|
| UNIT  | Char | Derived | Map VSORRESU via metadata/codelists.csv | Harmonized units |
| BASE  | Num  | Derived | `%baseline_bds` macro for baseline visit | Requires sorted data |
| CHG   | Num  | Derived | Difference between AVAL and BASE | Null when BASE missing |

## Known Assumptions / Exceptions
- Baseline identified using AVISIT="BASELINE"; adjust visit labels if sponsor uses alternatives.

## Reviewer Checklist
- [ ] SpecDiff clean
- [ ] QC Flags = 0
- [ ] Audit log present in /logs
