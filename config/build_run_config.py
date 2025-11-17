#!/usr/bin/env python3
"""Generate config_run_auto.sas from a minimal YAML-like run configuration."""
from __future__ import annotations

import argparse
import datetime as dt
import pathlib
import sys
from typing import Any, Dict

KEY_MAP = {
    "run_id": "RUN_ID",
    "mode": "MODE",
    "study_id": "STUDY_ID",
    "sap_version": "SAP_VERSION",
    "data_cut_dt": "DATA_CUT_DT",
    "tlf_set": "TLF_SET",
    "include_sd": "INCLUDE_SD",
    "include_ad": "INCLUDE_AD",
    "include_tlf": "INCLUDE_TLF",
    "adam_source_lib": "ADAM_LIB",
    "sdtm_source_lib": "SDTM_LIB",
    "output_root": "OUTPUT_ROOT",
    "log_subdir": "LOG_SUBDIR",
    "qc_subdir": "QC_SUBDIR",
}


def _coerce_value(value: str) -> Any:
    value = value.strip()
    if value.lower() in {"true", "yes"}:
        return True
    if value.lower() in {"false", "no"}:
        return False
    for caster in (int, float):
        try:
            return caster(value)
        except ValueError:
            continue
    if (value.startswith('"') and value.endswith('"')) or (
        value.startswith("'") and value.endswith("'")
    ):
        return value[1:-1]
    return value


def load_simple_yaml(path: pathlib.Path) -> Dict[str, Any]:
    data: Dict[str, Any] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"Invalid line in {path}: '{raw_line}'")
        key, raw_value = line.split(":", 1)
        data[key.strip()] = _coerce_value(raw_value)
    return data


def format_value(value: Any) -> str:
    if isinstance(value, bool):
        return "Y" if value else "N"
    if isinstance(value, (dt.date, dt.datetime)):
        return value.isoformat()
    return str(value)


def render_macro_lines(config: Dict[str, Any]) -> str:
    lines = ["/* config_run_auto.sas – auto generated, do not edit by hand. */"]
    for yaml_key, macro_name in KEY_MAP.items():
        if yaml_key not in config:
            raise KeyError(f"Missing required key '{yaml_key}' in run config.")
        value = format_value(config[yaml_key])
        lines.append(f"%let {macro_name:<12}= {value};")
    lines.append("")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("env", type=pathlib.Path, help="Path to the YAML environment file")
    parser.add_argument(
        "--output", "-o", type=pathlib.Path, default=pathlib.Path("config/config_run_auto.sas"),
        help="Destination for the generated SAS file",
    )
    args = parser.parse_args(argv)

    env_path = args.env.resolve()
    if not env_path.exists():
        raise SystemExit(f"Run config '{env_path}' does not exist.")

    config = load_simple_yaml(env_path)
    sas_text = render_macro_lines(config)
    output_path = args.output.resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(sas_text + "\n", encoding="utf-8")

    print(f"[build_run_config] Wrote {output_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
