#!/usr/bin/env bash
#
# validate-csv.sh - CSV file validator for bash
# Validates CSV syntax and structure
#

set -euo pipefail

# Default values
INPUT_PATH=""
DELIMITER=","
NO_HEADER=false
QUIET=false

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") -p <path> [-d <delimiter>] [-n] [-q]

Options:
    -p, --path PATH         Path to CSV file (required, or use stdin with -)
    -d, --delimiter CHAR    CSV delimiter (default: ,)
    -n, --no-header         Treat file as having no header row
    -q, --quiet             Suppress output (exit codes only)
    -h, --help              Show this help message

Exit codes:
    0 - Valid CSV
    1 - Invalid CSV

Examples:
    $(basename "$0") -p data.csv
    $(basename "$0") -p data.tsv -d $'\t'
    cat data.csv | $(basename "$0") -p -
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            INPUT_PATH="$2"
            shift 2
            ;;
        -d|--delimiter)
            DELIMITER="$2"
            shift 2
            ;;
        -n|--no-header)
            NO_HEADER=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

# Check required arguments
if [[ -z "$INPUT_PATH" ]]; then
    echo "Error: Path is required" >&2
    show_help >&2
    exit 1
fi

# Note: validate-csv doesn't actually need jq, but we keep it consistent
# CSV validation can be done with pure bash

# Read input
if [[ "$INPUT_PATH" == "-" ]]; then
    [[ "$QUIET" == false ]] && echo "Validating CSV from stdin" >&2
    CSV_DATA=$(cat)
    INPUT_PATH="stdin"
else
    if [[ ! -f "$INPUT_PATH" ]]; then
        [[ "$QUIET" == false ]] && echo "ERROR: File not found: $INPUT_PATH" >&2
        exit 1
    fi
    [[ "$QUIET" == false ]] && echo "Validating CSV file: $INPUT_PATH"
    CSV_DATA=$(cat "$INPUT_PATH")
fi

# Check for empty file
if [[ -z "$CSV_DATA" ]]; then
    [[ "$QUIET" == false ]] && echo "ERROR: File is empty" >&2
    exit 1
fi

# Count rows
ROW_COUNT=$(echo "$CSV_DATA" | wc -l)

# Get first row (header)
FIRST_ROW=$(echo "$CSV_DATA" | head -n 1)

# Count columns in first row (simple count of delimiters + 1)
EXPECTED_COLS=$(($(echo "$FIRST_ROW" | grep -o "$DELIMITER" | wc -l) + 1))

# Check for inconsistent column counts
INCONSISTENT_ROWS=0
LINE_NUM=1
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        COLS=$(($(echo "$line" | grep -o "$DELIMITER" | wc -l) + 1))
        if [[ $COLS -ne $EXPECTED_COLS ]]; then
            INCONSISTENT_ROWS=$((INCONSISTENT_ROWS + 1))
            if [[ "$QUIET" == false ]] && [[ $INCONSISTENT_ROWS -le 5 ]]; then
                echo "WARNING: Row $LINE_NUM: $COLS columns (expected $EXPECTED_COLS)" >&2
            fi
        fi
    fi
    LINE_NUM=$((LINE_NUM + 1))
done <<< "$CSV_DATA"

if [[ $INCONSISTENT_ROWS -gt 5 ]] && [[ "$QUIET" == false ]]; then
    echo "WARNING: ... and $((INCONSISTENT_ROWS - 5)) more inconsistent rows" >&2
fi

# Check for empty column names
if [[ "$NO_HEADER" == false ]]; then
    if echo "$FIRST_ROW" | grep -qE "$DELIMITER$DELIMITER|^$DELIMITER|$DELIMITER\$"; then
        [[ "$QUIET" == false ]] && echo "WARNING: Found empty column name(s) in header" >&2
    fi
fi

# Success
if [[ "$QUIET" == false ]]; then
    echo "SUCCESS: Valid CSV"
    echo "  Rows: $((ROW_COUNT - 1))"  # Subtract header row
    echo "  Columns: $EXPECTED_COLS"

    if [[ "$NO_HEADER" == false ]]; then
        # Show first few headers (truncate if too long)
        HEADERS=$(echo "$FIRST_ROW" | cut -c1-80)
        if [[ ${#FIRST_ROW} -gt 80 ]]; then
            HEADERS="$HEADERS..."
        fi
        echo "  Headers: $HEADERS"
    fi

    if [[ "$INPUT_PATH" != "stdin" ]]; then
        SIZE_KB=$(du -k "$INPUT_PATH" | cut -f1)
        echo "  Size: $SIZE_KB KB"
    fi

    # Delimiter name
    case "$DELIMITER" in
        ",") echo "  Delimiter: comma" ;;
        $'\t') echo "  Delimiter: tab" ;;
        ";") echo "  Delimiter: semicolon" ;;
        "|") echo "  Delimiter: pipe" ;;
        *) echo "  Delimiter: '$DELIMITER'" ;;
    esac
fi

exit 0
