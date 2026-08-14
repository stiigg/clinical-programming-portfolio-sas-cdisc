# Clinical Programming Portfolio — SAS and CDISC

A reproducible SAS clinical-programming portfolio that demonstrates a configuration-driven, metadata-oriented workflow for selected SDTM and ADaM derivations, TLF orchestration, run traceability, automated log review, comparison-based QC utilities, and submission-support documentation templates.

> **Portfolio / demonstration project**
>
> This repository is intended to demonstrate clinical-programming architecture and implementation patterns using synthetic or non-confidential data.
>
> It is not a validated production system and must not be used directly for a regulatory submission without study-specific specifications, controlled validation, governance, security controls, and independent review.

---

## Portfolio focus

This repository demonstrates an end-to-end workflow rather than only isolated SAS programs:

```text
Run configuration → Metadata → ETL and SAS macros → SDTM / ADaM / TLFs
                                                    ↓
                                Logs, provenance, QC checks, and documentation
```

Key areas demonstrated:

- Named run configurations for database locks, interim analyses, and exploratory runs
- Metadata-driven activation of selected domains and TLFs
- Reusable SAS macro components for derivations, population logic, endpoints, logging, and dispatch
- Centralised execution settings and output switches
- Cross-platform Windows and Unix/macOS launchers
- Run stamps, row-count logging, and SAS log scanning
- Comparison and regression-test scaffolding
- Demonstration templates for Define-XML-related metadata, cSDRG, and ADRG content

---

## Architecture

```text
                     Named run
                        │
                        ▼
                 batch/ launcher
                        │
                        ▼
       config/global_config.sas
                        │
                        ▼
         config/select_run.sas
                        │
                        ▼
          config/run_<RUN>.sas
                        │
                        ▼
      specs/ metadata repositories
                        │
                        ▼
       etl/ orchestration drivers
                        │
                        ▼
         macros/ reusable logic
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
       SDTM output   ADaM output   TLF output
          │             │             │
          └─────────────┼─────────────┘
                        ▼
               validation/ utilities
                        │
                        ▼
       QC summaries, logs, and evidence
                        │
                        ▼
      regulatory/ documentation templates
```

---

## Demonstration scenarios

The project uses synthetic or non-confidential demonstration data only. The scenarios are illustrative and do not represent a real clinical study or a regulatory submission package.

### Safety workflow

**Purpose:** Demonstrate a controlled workflow for selected safety-related SDTM and ADaM derivations, safety-population logic, output generation, and QC checks.

Possible components include:

- Source data handling for demographics, exposure, adverse events, and selected laboratory data
- Selected SDTM domains such as `DM`, `EX`, and `AE`
- Analysis datasets such as `ADSL` and `ADAE`
- Safety summaries and subject-level listings
- Run-level logs, row counts, and comparison-based QC evidence

### Efficacy workflow

**Purpose:** Demonstrate baseline, population, endpoint, and TLF orchestration patterns using synthetic data.

Possible components include:

- Baseline and analysis-population derivations
- Selected efficacy endpoints or change-from-baseline logic
- Centralised time-to-event derivation utilities where applicable
- Metadata-controlled TLF activation
- Output comparison and log-review evidence

> Only datasets, derivations, TLFs, and evidence that are implemented in the repository should be described as available. Update this section as implementation expands.

---

## Getting started

### Prerequisites

- Licensed SAS environment capable of executing Base SAS programs
- Git
- Windows command shell or Bash-compatible shell
- Python 3.x only if using the optional configuration utilities under `config/`

### Clone the repository

```bash
git clone https://github.com/stiigg/clinical-programming-portfolio-sas-cdisc.git
cd clinical-programming-portfolio-sas-cdisc
```

### Set the project root

Set the project root directly in SAS:

```sas
%let ROOT=/path/to/clinical-programming-portfolio-sas-cdisc;
```

Alternatively, use the batch launchers if they set the project root automatically.

### Select a named run

Review the run definitions under `config/`, for example:

```text
config/run_LOCK_MAIN.sas
config/run_INTERIM_2025M10.sas
config/run_SCLC_LOCK_2025Q4.sas
```

The requested run name is resolved by `config/select_run.sas`, which includes the corresponding `run_*.sas` file.

### Execute the pipeline

Windows:

```bat
batch\run_all_windows.bat LOCK_MAIN
```

macOS/Linux:

```bash
bash batch/run_all_unix.sh LOCK_MAIN
```

### Review outputs

Review the run-specific artefacts under `outputs/`, including logs, QC material, generated datasets, TLF output, and documentation templates where implemented.

```text
outputs/logs/<run-id>/
outputs/qc/<run-id>/
outputs/regulatory/<run-id>/
```

Actual locations and outputs depend on the selected run configuration.

---

## Repository layout

| Directory | Purpose |
|---|---|
| `batch/` | Windows and Unix/macOS shell launchers for named pipeline runs |
| `config/` | Global SAS configuration, run dispatcher, SAS run-control files, YAML profiles, and Python configuration utilities |
| `data/` | Synthetic or non-confidential demonstration input data |
| `docs/` | Architecture notes, implementation details, QA approach, conventions, and limitations |
| `etl/` | Metadata-reading drivers and pipeline orchestration programs |
| `macros/` | Reusable SAS macro components for transformations, derivations, population logic, TLF routing, and logging |
| `outputs/` | Generated outputs, logs, QC material, and documentation artefacts; normally excluded from version control |
| `regulatory/` | Demonstration scripts and templates for Define-XML-related metadata, cSDRG, and ADRG documentation |
| `specs/` | Controlled metadata specifications for datasets, variables, value-level metadata, codelists, and TLFs |
| `validation/` | Log scanners, comparison utilities, regression-test scaffolding, and QC reporting |

---

## Configuration and metadata

### Run control

SAS files under `config/run_*.sas` provide named execution settings, including the data cut, SAP version, execution mode, and output switches. This prevents drivers from embedding run-specific parameters.

`config/select_run.sas` resolves the requested `RUN=` value and includes the associated run-control file.

### Metadata-driven execution

The pipeline externalises selected operational decisions into version-controlled metadata files:

- `specs/spec_toc.csv` controls configured domain activation
- `specs/spec_tlf.csv` controls TLF activation by run type or execution set
- Additional specifications support datasets, variables, value-level metadata, and codelists

ETL drivers read these specifications and invoke the relevant reusable SAS macros.

### Optional YAML and Python utilities

The `config/` directory also contains YAML environment profiles and Python utilities. These support an optional structured configuration approach for validation, generation, or cross-checking of SAS run-control parameters.

The active, authoritative configuration method should be documented here once finalised.

---

## Quality-control approach

The repository demonstrates quality-oriented engineering practices:

- Run initialisation and named execution profiles
- Dataset provenance stamps and output footnotes
- Row-count logging
- Automated SAS log scanning
- Output comparison and regression-test utilities
- Version-controlled configuration and metadata

These utilities are demonstration scaffolding. They do not replace a study-specific validation plan, independent programming, formal code review, controlled change management, or a validated regulated-computing environment.

---

## Data handling

- Do not commit participant-level data, client data, proprietary study data, or confidential sponsor artefacts.
- Use synthetic, mock, or explicitly licensed public data only.
- Do not commit raw logs without reviewing them for identifiers, free text, local paths, host names, usernames, or other sensitive information.
- Generated SAS datasets, listings, logs, PDFs, RTF files, and temporary outputs should normally be excluded through `.gitignore`.

---

## Scope and limitations

This repository does not claim:

- Complete SDTM, ADaM, or TLF coverage
- Conformance with every CDISC model or implementation-guide version
- A fully validated Define-XML generation process
- Complete automated cSDRG or ADRG generation
- A production-ready regulatory submission package
- Replacement of study-specific SOPs, validation, governance, or independent QC

---

## Roadmap

- [ ] Document the authoritative SAS/YAML configuration model
- [ ] Add YAML schema and pre-run validation checks
- [ ] Generate configuration manifests for named runs
- [ ] Add example synthetic input data and expected output summaries
- [ ] Publish a data-flow and metadata-lineage diagram
- [ ] Add sanitised log-scan and QC-comparison examples
- [ ] Add automated non-SAS repository checks
- [ ] Add a project licence
- [ ] Add a first tagged release

---

## Contact

Maintained by Christian Baghai.

Use GitHub Issues for questions, suggestions, and technical discussion.
