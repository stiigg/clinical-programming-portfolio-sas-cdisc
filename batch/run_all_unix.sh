#!/bin/sh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$PROJECT_ROOT/config"
LOG_DIR="$PROJECT_ROOT/outputs/logs"
mkdir -p "$LOG_DIR"

RUN_ENV="${1:-env_lock_2025Q1.yaml}"
python3 "$CONFIG_DIR/build_run_config.py" "$CONFIG_DIR/$RUN_ENV"

SAS_EXE=${SAS_EXE:-sas}
"$SAS_EXE" -sysin "$PROJECT_ROOT/etl/run_all.sas" \
          -log "$LOG_DIR/run_all.log" \
          -nosplash -noterminal
