#!/bin/bash

# --- 1. DYNAMIC PATH DISCOVERY ---
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
GRADER_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
SIM_ROOT=$(cd "$GRADER_DIR/.." && pwd)

QUEST01_ROOT="$SIM_ROOT/.01-edu-tests/quest01"
GO_ROOT="$SIM_ROOT/.01-edu-tests/go-tests"

# --- 2. FIND THE STUDENT WORKSPACE (piscine-go) ---
CURRENT_DIR=$(pwd)
if [ -d "./piscine-go" ]; then
    STUDENT_DIR="$CURRENT_DIR/piscine-go"
elif [[ "$CURRENT_DIR" == *"piscine-go"* ]]; then
    STUDENT_DIR=$(echo "$CURRENT_DIR" | sed 's/\(piscine-go\).*/\1/')
elif [ -d "$SIM_ROOT/piscine-go" ]; then
    # Fallback: Use the piscine-go folder inside the simulator root
    STUDENT_DIR="$SIM_ROOT/piscine-go"
else
    echo -e "\033[31m[ERROR]\033[0m Could not find 'piscine-go' directory."
    exit 1
fi

EX=${1%/}
if [ -z "$EX" ]; then
    echo -e "\033[33mUsage:\033[0m checker [exercise_name]"
    exit 1
fi

export DOMAIN="localhost"
export GITEA_ID="12345"

# --- 3. ROUTING: QUEST 01 (SHELL) ---
SHELL_TEST_SRC=$(find "$QUEST01_ROOT" -name "${EX}_test.sh" | head -n 1)
if [ -n "$SHELL_TEST_SRC" ]; then
    echo -e "\033[34m[SIMULATOR]\033[0m Testing Shell: $EX"
    if [ ! -d "$STUDENT_DIR/$EX" ]; then echo -e "\033[31m[FAIL]\033[0m Folder '$EX' missing."; exit 1; fi
    SANDBOX=$(mktemp -d); mkdir -p "$SANDBOX/student" "$SANDBOX/solutions"
    cp "$STUDENT_DIR/$EX/$EX.sh" "$SANDBOX/student/" 2>/dev/null || cp "$STUDENT_DIR/$EX/"*.sh "$SANDBOX/student/" 2>/dev/null
    SOL_FILE=$(find "$QUEST01_ROOT" -name "$EX.sh" | grep "solutions" | head -n 1)
    [ -f "$SOL_FILE" ] && cp "$SOL_FILE" "$SANDBOX/solutions/"
    cp "$SHELL_TEST_SRC" "$SANDBOX/run_test.sh"
    echo '[{"name":"ChouMi","id":70},{"name":"Batman","id":80}]' > "$SANDBOX/mock.json"
    cat << 'EOF' > "$SANDBOX/curl"; #!/bin/bash
cat "$(dirname "$0")/mock.json"
EOF
    chmod +x "$SANDBOX/curl"; ORIG_PATH=$PATH; export PATH="$SANDBOX:$PATH"
    cd "$SANDBOX" && sed -i 's/set -euo pipefail/set -uo pipefail/g' run_test.sh
    bash run_test.sh > trace.txt 2>&1
    RESULT=$?; export PATH=$ORIG_PATH
    if [ $RESULT -eq 0 ]; then
        echo -e "\033[32m[SUCCESS]\033[0m $EX passed!"
        rm -f "$STUDENT_DIR/$EX/trace.txt" 2>/dev/null
    else
        echo -e "\033[31m[FAIL]\033[0m $EX failed."
        cat trace.txt; cp trace.txt "$STUDENT_DIR/$EX/trace.txt"
    fi
    rm -rf "$SANDBOX"; exit 0

# --- 4. ROUTING: GO QUESTS ---
else
    GO_SOL=$(find "$GO_ROOT/solutions" -maxdepth 1 \( -name "$EX" -o -name "$EX.go" \) | head -n 1)
    if [ -n "$GO_SOL" ]; then
        EX_CLEAN=$(basename "$GO_SOL" | sed 's/\.go//')
        echo -e "\033[34m[SIMULATOR]\033[0m Testing Go: $EX_CLEAN"
        if [ ! -d "$STUDENT_DIR/$EX" ]; then echo -e "\033[31m[FAIL]\033[0m Folder '$EX' missing."; exit 1; fi
        STUDENT_MAIN="$STUDENT_DIR/$EX/main.go"
        if [ ! -f "$STUDENT_MAIN" ]; then echo -e "\033[31m[FAIL]\033[0m No main.go found."; exit 1; fi
        SAND_STUDENT=$(mktemp -d); SAND_SOLUTION=$(mktemp -d)
        cp "$STUDENT_DIR/$EX/"*.go "$SAND_STUDENT/"
        cd "$SAND_STUDENT"
        sed -i 's/^package .*/package main/g' *.go; sed -i 's/piscine\.//g' *.go; sed -i '/"piscine"/d' *.go
        go mod init student &>/dev/null; go get github.com/01-edu/z01@latest &>/dev/null
        student_out=$(go run . 2>&1)
        cp "$STUDENT_MAIN" "$SAND_SOLUTION/"
        if [ -d "$GO_SOL" ]; then cp "$GO_SOL/"*.go "$SAND_SOLUTION/"; else cp "$GO_SOL" "$SAND_SOLUTION/"; fi
        cd "$SAND_SOLUTION"
        sed -i 's/^package .*/package main/g' *.go; sed -i 's/piscine\.//g' *.go; sed -i '/"piscine"/d' *.go
        go mod init solution &>/dev/null; go get github.com/01-edu/z01@latest &>/dev/null
        expected_out=$(go run . 2>/dev/null)
        echo "------------------ GO TRACE ------------------"
        if [ "$student_out" == "$expected_out" ] && [ -n "$student_out" ]; then
            echo -e "$student_out"
            echo "----------------------------------------------"
            echo -e "\033[32m[SUCCESS]\033[0m $EX_CLEAN passed!"
            rm -f "$STUDENT_DIR/$EX/trace.txt" 2>/dev/null
        else
            echo -e "Expected:\n$expected_out\nGot:\n$student_out"
            echo "----------------------------------------------"
            echo -e "\033[31m[FAIL]\033[0m $EX_CLEAN output mismatch."
            echo -e "Expected:\n$expected_out\nGot:\n$student_out" > "$STUDENT_DIR/$EX/trace.txt"
        fi
        rm -rf "$SAND_STUDENT" "$SAND_SOLUTION"
    else
        echo -e "\033[31m[ERROR]\033[0m Exercise '$EX' not found."
    fi
fi