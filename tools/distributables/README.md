# JSON/CSV Conversion Tools

PowerShell utilities for converting and validating JSON and CSV files.

## Tools

### j2c.ps1 - JSON to CSV Converter

Converts JSON files to CSV format with intelligent handling of nested objects and arrays.

**Features:**
- Nested object flattening with dot notation
- Multiple array handling strategies
- Schema discovery across varying object structures
- Stdout support for piping
- Custom delimiters

**Basic Usage:**
```powershell
# Convert to file (explicit output)
.\j2c.ps1 -InputPath data.json -OutputPath output.csv

# Output to stdout
.\j2c.ps1 -InputPath data.json

# Redirect to file (progress goes to stderr)
.\j2c.ps1 -InputPath data.json > output.csv

# Suppress progress messages
.\j2c.ps1 -InputPath data.json 2>$null > output.csv

# Pipe to another command
.\j2c.ps1 -InputPath data.json | Select-String "pattern"
```

**Array Handling:**
```powershell
# Stringify arrays as JSON (default)
.\j2c.ps1 -InputPath data.json

# Concatenate array values with semicolons
.\j2c.ps1 -InputPath data.json -ArrayHandling Concatenate

# Separate rows (1-to-many)
.\j2c.ps1 -InputPath data.json -ArrayHandling Separate
```

**Advanced Options:**
```powershell
# Limit flattening depth
.\j2c.ps1 -InputPath data.json -MaxDepth 2

# Custom delimiter
.\j2c.ps1 -InputPath data.json -Delimiter ";"
```

**Wrapper:** `ConvertTo-Csv.ps1` provides the same functionality with a longer, more PowerShell-style name.

### validate-json.ps1 - JSON Validator

Validates JSON file syntax and structure.

**Usage:**
```powershell
# Basic validation
.\validate-json.ps1 -Path data.json

# Check for empty keys (PowerShell limitation)
.\validate-json.ps1 -Path data.json -CheckEmptyKeys

# Quiet mode (exit codes only)
.\validate-json.ps1 -Path data.json -Quiet
if ($LASTEXITCODE -eq 0) { Write-Host "Valid!" }
```

### validate-csv.ps1 - CSV Validator

Validates CSV file syntax and structure.

**Usage:**
```powershell
# Basic validation
.\validate-csv.ps1 -Path data.csv

# Custom delimiter
.\validate-csv.ps1 -Path data.tsv -Delimiter "`t"

# Quiet mode
.\validate-csv.ps1 -Path data.csv -Quiet
```

## Important Notes
### Empty Keys in JSON

JSON with empty property names (`""`) is technically valid per RFC 8259, but PowerShell's `ConvertFrom-Json` cannot handle it. The scripts will detect this and fail with a clear error message.


## Examples

### Nested Object Flattening

**Input** (`nested.json`):
```json
{
  "user": {
    "name": "Jane",
    "contact": {
      "email": "jane@example.com",
      "phone": "555-1234"
    }
  }
}
```

**Output**:
```csv
user.name,user.contact.email,user.contact.phone
Jane,jane@example.com,555-1234
```

### Array Handling

**Input** (`with-arrays.json`):
```json
{
  "name": "Project",
  "tags": ["urgent", "backend", "api"]
}
```

**Stringify (default)**:
```csv
name,tags
Project,"[""urgent"",""backend"",""api""]"
```

**Concatenate**:
```csv
name,tags
Project,"urgent; backend; api"
```

### Schema Discovery

**Input** (`varying.json`):
```json
[
  {"id": 1, "name": "Alice", "role": "Admin"},
  {"id": 2, "name": "Bob", "department": "Sales"},
  {"id": 3, "name": "Charlie", "role": "User", "department": "IT"}
]
```

**Output** (all unique fields become columns):
```csv
id,name,role,department
1,Alice,Admin,
2,Bob,,Sales
3,Charlie,User,IT
```

## Bash Versions

Bash versions of all scripts are also available with the same functionality:

- `j2c.sh` - JSON to CSV converter
- `validate-json.sh` - JSON validator
- `validate-csv.sh` - CSV validator

**Usage:**
```bash
# Make executable (first time only)
chmod +x tools/*.sh

# JSON to CSV
./tools/j2c.sh -i data.json -o output.csv
cat data.json | ./tools/j2c.sh -i - > output.csv

# Validate JSON
./tools/validate-json.sh -p data.json -e
cat data.json | ./tools/validate-json.sh -p -

# Validate CSV
./tools/validate-csv.sh -p data.csv
./tools/validate-csv.sh -p data.tsv -d $'\t'

# Run bash tests
./tools/tests/test-bash-scripts.sh
```

## Requirements

**PowerShell versions:**
- PowerShell 5.1+ or PowerShell Core 7+
- Windows, Linux, or macOS
- Pester (for testing only)

**Bash versions:**
- Bash 4.0+
- `jq` command-line JSON processor (install with `apt-get install jq` or `brew install jq`)
- Linux, macOS, WSL, or Git Bash on Windows

