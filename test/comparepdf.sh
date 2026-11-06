#!/usr/bin/env bash
# comparepdf.sh -- decide whether two PDFs are equivalent, or take the
# fingerprint of one.
#
#   usage: comparepdf.sh <a.pdf> <b.pdf>
#          comparepdf.sh --digest <file.pdf>
#          comparepdf.sh --help
#
#   exit 0  equivalent, or digest printed on stdout
#   exit 1  not equivalent (the first differing byte offset is reported)
#   exit 2  usage error, unreadable file, or a file that is not a valid PDF
#
# The two modes share one definition of what "equivalent" means, so a pair of
# files compare equal if and only if their digests match. There is no second
# implementation to drift out of step with the first.
#
#
# WHAT THIS DOES
#
# Two PDFs built from the same drawing commands still differ in a couple of
# spots that have nothing to do with page content: the creation timestamp and
# the file identifier, both stamped fresh on every run. Everything else --
# object emission order, dictionary contents, content-stream operators, numeric
# formatting, stream lengths, xref offsets -- is expected to match exactly,
# byte for byte.
#
# So: blank out those two fields in a scratch copy of each file, then either do
# a plain binary comparison of the results, or hash one of them.
#
#
# WHY THE SUBSTITUTIONS PRESERVE LENGTH
#
# Each replacement writes exactly as many characters as it consumes. That is not
# incidental. A PDF's xref table records the byte offset of every object in the
# file, so a normaliser that changed the file's length would invalidate those
# recorded offsets and make the rest of the comparison meaningless. Blanking in
# place leaves every offset in the file still true, which is what makes a naive
# byte-for-byte `cmp` the right tool for the job.
#
#
# WHAT GETS BLANKED
#
#   1. Date strings shaped like (D:YYYYMMDDHHMMSSZ). This covers /CreationDate
#      and /ModDate wherever they appear in the file. The fourteen digits become
#      zeros; the surrounding literal is left alone.
#
#   2. The trailer's /ID array, which carries two 32-character hex strings. Both
#      become runs of zeros.
#
#   3. The XMP metadata packet's <xmp:CreateDate>, which is the same instant as
#      /CreationDate written in ISO 8601 (YYYY-MM-DDTHH:MM:SSZ) rather than PDF
#      date syntax. It only appears in documents that carry XMP metadata at all
#      -- a title, or a tagged document -- which is exactly why it is easy to
#      miss: leave it alone and a comparison passes all day and then fails once
#      because the two runs straddled a second boundary.
#
# Nothing else is touched. If a difference survives this, it is a real
# difference in the document.
#
# One deliberate design note: if any of these patterns ever stops matching --
# say a writer starts emitting dates with a numeric UTC offset instead of a
# trailing Z -- then nothing gets substituted and the comparison fails. That is
# the right failure direction. A normaliser that quietly stops normalising
# should be loud about it rather than silently permissive.
#
#
# WHY EVERY INPUT IS STRUCTURE-CHECKED FIRST
#
# Both modes run `qpdf --check` over an input before touching it, and refuse
# anything that does not come back clean. The point is not security -- a digest
# is not made safer by validating what goes into it -- it is that the failure
# you get should name the actual problem.
#
# A port under development writes all sorts of things to its output path: an
# empty file because nothing was flushed, a Lua stack trace because an error
# went to the wrong stream, half a document because a buffer was never drained.
# Hash any of those and you learn only that the digest did not match, which is
# true of every wrong answer and therefore tells you nothing. Run them past
# qpdf first and you get "can't find PDF header" or "file is damaged" instead,
# which points straight at the stage that broke.
#
# Only a clean bill of health counts. qpdf exits 0 when a file checks out, 3
# when it can still read the file but had to recover from damage, and 2 when it
# cannot make sense of it at all. Correct output here is a byte-for-byte match
# with a reference that checks out clean, so anything short of exit 0 is a
# defect worth reporting rather than papering over -- a recovered-from xref is
# still a broken xref.

set -euo pipefail

usage() {
    cat <<'EOF'
usage: comparepdf.sh <a.pdf> <b.pdf>       compare two PDFs for equivalence
       comparepdf.sh --digest <file.pdf>   print one PDF's normalised SHA-256
       comparepdf.sh --help                this message

exit 0  equivalent, or digest printed
exit 1  not equivalent
exit 2  usage error, unreadable file, or not a valid PDF
EOF
}

die() { echo "comparepdf: $*" >&2; exit 2; }

# Every input has to clear three hurdles before it is allowed to matter:
# readable at all, non-empty, and structurally sound as a PDF. The size check
# is not redundant with qpdf -- it just produces a blunter message for the
# single most common early-development case, an output file that never got
# written to.
require_pdf() {
    local f=$1
    [ -e "$f" ] || die "no such file: '$f'"
    [ -f "$f" ] || die "not a regular file: '$f'"
    [ -r "$f" ] || die "cannot read '$f'"
    [ -s "$f" ] || die "'$f' is empty"

    local out rc=0
    out=$(qpdf --check "$f" 2>&1) || rc=$?
    if [ "$rc" -ne 0 ]; then
        # qpdf is chatty on success and terse on failure; the first line
        # carrying a diagnostic is the one worth repeating.
        local why
        why=$(printf '%s\n' "$out" | grep -m1 -E 'WARNING|ERROR' || true)
        die "'$f' is not a valid PDF (qpdf --check exit $rc)${why:+: $why}"
    fi
}

# LC_ALL=C keeps sed byte-oriented instead of trying to decode the file as text
# in the ambient locale. A PDF is binary in places, and that matters.
normalise() {
    LC_ALL=C sed \
        -e 's/(D:[0-9]\{14\}Z)/(D:00000000000000Z)/g' \
        -e 's|/ID \[<[0-9a-fA-F]\{32\}> <[0-9a-fA-F]\{32\}>\]|/ID [<00000000000000000000000000000000> <00000000000000000000000000000000>]|g' \
        -e 's|<xmp:CreateDate>[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z</xmp:CreateDate>|<xmp:CreateDate>0000-00-00T00:00:00Z</xmp:CreateDate>|g' \
        "$1" >"$2"
}

command -v qpdf     >/dev/null 2>&1 || die "qpdf not found on PATH"
command -v sha256sum >/dev/null 2>&1 || die "sha256sum not found on PATH"

case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;

    --digest)
        [ "$#" -eq 2 ] || { usage >&2; exit 2; }
        require_pdf "$2"

        work="$(mktemp -d)"
        trap 'rm -rf "$work"' EXIT
        normalise "$2" "$work/n.pdf"

        # Just the hex, so the caller can compare it against a stored value
        # without having to strip a filename off the end.
        sha256sum "$work/n.pdf" | awk '{print $1}'
        exit 0
        ;;

    --*)
        die "unknown option '$1'"
        ;;
esac

[ "$#" -eq 2 ] || { usage >&2; exit 2; }

require_pdf "$1"
require_pdf "$2"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

normalise "$1" "$work/a.pdf"
normalise "$2" "$work/b.pdf"

if cmp -s "$work/a.pdf" "$work/b.pdf"; then
    exit 0
fi

# Not equivalent. Report where they first diverge. The offset is into the
# normalised copies, but because the substitutions preserve length it is also
# the offset into the originals.
detail="$(cmp "$work/a.pdf" "$work/b.pdf" 2>&1 | sed -n 's/.*differ: /differ at /p')" || true
echo "comparepdf: $1 vs $2: ${detail:-not equivalent}" >&2
exit 1
