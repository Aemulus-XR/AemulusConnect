#!/usr/bin/env bash
#
# validate-json.sh - JSON file validator for bash
# Validates JSON syntax and structure
#

set -euo pipefail

# Default values
INPUT_PATH=""
CHECK_EMPTY_KEYS=false
QUIET=false

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") -p <path> [-e] [-q]

Options:
    -p, --path PATH         Path to JSON file (required, or use stdin with -)
    -e, --check-empty       Check for empty keys
    -q, --quiet             Suppress output (exit codes only)
    -h, --help              Show this help message

Exit codes:
    0 - Valid JSON
    1 - Invalid JSON

Examples:
    $(basename "$0") -p data.json
    $(basename "$0") -p data.json -e
    cat data.json | $(basename "$0") -p -
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            INPUT_PATH="$2"
            shift 2
            ;;
        -e|--check-empty)
            CHECK_EMPTY_KEYS=true
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

# Check if jq is available
if ! command -v jq &> /dev/null; then
    if [[ "$QUIET" == false ]]; then
        cat >&2 << 'EOF'
Error: jq is required but not installed

This script requires the 'jq' command-line JSON processor.

Installation instructions:
  • Ubuntu/Debian:  sudo apt-get install jq
  • macOS:          brew install jq
  • Fedora/RHEL:    sudo dnf install jq
  • Windows:        choco install jq
  • Or download from: https://jqlang.github.io/jq/download/

EOF
    fi
    exit 127  # Command not found
fi

# Read input
if [[ "$INPUT_PATH" == "-" ]]; then
    [[ "$QUIET" == false ]] && echo "Validating JSON from stdin" >&2
    JSON_DATA=$(cat)
    INPUT_PATH="stdin"
else
    if [[ ! -f "$INPUT_PATH" ]]; then
        [[ "$QUIET" == false ]] && echo "ERROR: File not found: $INPUT_PATH" >&2
        exit 1
    fi
    [[ "$QUIET" == false ]] && echo "Validating JSON file: $INPUT_PATH"
    JSON_DATA=$(cat "$INPUT_PATH")
fi

# Check for empty file
if [[ -z "$JSON_DATA" ]]; then
    [[ "$QUIET" == false ]] && echo "ERROR: File is empty" >&2
    exit 1
fi

# Check for empty keys if requested
if [[ "$CHECK_EMPTY_KEYS" == true ]]; then
    if echo "$JSON_DATA" | grep -q '""[[:space:]]*:'; then
        [[ "$QUIET" == false ]] && echo "WARNING: Found empty string as property name ('')" >&2
        [[ "$QUIET" == false ]] && echo "  This is valid JSON but not supported by PowerShell" >&2
    fi
fi

# Validate JSON with jq
if echo "$JSON_DATA" | jq empty 2>/dev/null; then
    if [[ "$QUIET" == false ]]; then
        echo "SUCCESS: Valid JSON"

        # Get type and stats
        JSON_TYPE=$(echo "$JSON_DATA" | jq -r 'type')

        case "$JSON_TYPE" in
            array)
                ITEM_COUNT=$(echo "$JSON_DATA" | jq 'length')
                echo "  Type: Array"
                echo "  Items: $ITEM_COUNT"
                ;;
            object)
                PROP_COUNT=$(echo "$JSON_DATA" | jq 'keys | length')
                echo "  Type: Object"
                echo "  Properties: $PROP_COUNT"
                ;;
            *)
                echo "  Type: $JSON_TYPE"
                ;;
        esac

        LINE_COUNT=$(echo "$JSON_DATA" | wc -l)
        echo "  Lines: $LINE_COUNT"

        if [[ "$INPUT_PATH" != "stdin" ]]; then
            SIZE_KB=$(du -k "$INPUT_PATH" | cut -f1)
            echo "  Size: $SIZE_KB KB"
        fi
    fi
    exit 0
else
    ERROR_MSG=$(echo "$JSON_DATA" | jq empty 2>&1 || true)
    [[ "$QUIET" == false ]] && echo "ERROR: Invalid JSON" >&2
    [[ "$QUIET" == false ]] && echo "  $ERROR_MSG" >&2
    exit 1
fi
