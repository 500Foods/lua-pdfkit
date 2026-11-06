#!/usr/bin/env bash
# Compare Lua output with vendored PDFKit 0.20.2.
#
#   test/compare.sh A          one family, both programs
#   test/compare.sh 01         same family, by development number
#   test/compare.sh A 03       more than one
#   test/compare.sh all
#
# Installs vendor/pdfkit dependencies and builds js/ when either is missing.
# Needs node, the bundled Yarn, qpdf, and Lua 5.5.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -d vendor/pdfkit/node_modules || ! -f vendor/pdfkit/js/pdfkit.js ]]; then
    echo "installing vendored PDFKit 0.20.2 ..."
    ( cd vendor/pdfkit && node .yarn/releases/yarn-4.16.0.cjs install && node .yarn/releases/yarn-4.16.0.cjs build )
fi

export NODE_PATH="$ROOT/vendor:$ROOT/vendor/pdfkit/node_modules"
mkdir -p test/out

letters=(A B C D E F G H I J K L M N O P)
numbers=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16)

run_pair() {
    local name="$1" lua="$2" js="$3"
    local lpdf="test/out/${name}.lua.pdf"
    local jpdf="test/out/${name}.js.pdf"
    lua "$lua" "$lpdf"
    node "$js" "$jpdf"
    test/comparepdf.sh "$lpdf" "$jpdf"
    echo "ok  $name"
}

run_letter() {
    local L="$1"
    local i
    for i in "${!letters[@]}"; do
        if [[ "${letters[$i]}" == "$L" ]]; then
            local n="${numbers[$i]}"
            run_pair "example_${L}" "test/programs/example_${L}.lua" "test/programs/example_${L}.js"
            run_pair "test_${n}" "test/programs/test_${n}.lua" "test/programs/test_${n}.js"
            return
        fi
    done
    echo "compare: unknown family '$L'" >&2
    exit 2
}

if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

args=("$@")
if [[ "$1" == "all" ]]; then
    args=("${letters[@]}")
fi

for arg in "${args[@]}"; do
    case "$arg" in
        [A-P]) run_letter "$arg" ;;
        0[1-9]|1[0-6])
            n=$((10#$arg))
            run_letter "${letters[$((n - 1))]}"
            ;;
        *)
            echo "compare: unknown family '$arg'" >&2
            exit 2
            ;;
    esac
done
