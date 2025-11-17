#!/bin/sh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/outputs/logs"
RUN_NAME="${1:-}"

if [ -z "$RUN_NAME" ]; then
  echo "Usage: $0 RUN_NAME (e.g. LOCK_MAIN)"
  exit 1
fi

mkdir -p "$LOG_DIR"
SAS_EXE=${SAS_EXE:-sas}

"$SAS_EXE" -sysin "$PROJECT_ROOT/etl/run_all.sas" \
          -set ROOT "$PROJECT_ROOT" \
          -set RUN "$RUN_NAME" \
          -log "$LOG_DIR/${RUN_NAME}_master.log" \
          -print "$LOG_DIR/${RUN_NAME}_master.lst" \
          -nosplash -noterminal
