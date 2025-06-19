#!/bin/bash
# filepath: /Users/bradley/Developer/c/bio/random.protein/aaindex1_to_csv.sh

INPUT="/Users/bradley/Developer/data/tools/aaindex/aaindex1"
OUTPUT="aaindex1.csv"

gawk '
BEGIN {
    FS = ""
    OFS = ","
    keys = "A D R T J C I"
    split(keys, keyarr)
    for (i in keyarr) header[keyarr[i]] = 1
    record_count = 0
}
function print_record() {
    if (record_count == 0) {
        # Print header
        for (k in keyarr) {
            printf "%s%s", keyarr[k], (k < length(keyarr) ? OFS : ORS)
        }
    }
    for (k in keyarr) {
        val = (k in rec) ? rec[k] : ""
        gsub(/"/, "\"\"", val)
        printf "\"%s\"%s", val, (k < length(keyarr) ? OFS : ORS)
    }
    delete rec
    record_count++
}
{
    if ($1 ~ /^[ADRJTCI]$/ && $2 ~ /[ \t]/) {
        curr_key = $1
        rec[curr_key] = substr($0, 3)
    } else if ($0 == "//") {
        print_record()
        curr_key = ""
    } else if (curr_key != "") {
        rec[curr_key] = rec[curr_key] " " $0
    }
}
END {
    if (length(rec) > 0) print_record()
}
' "$INPUT" > "$OUTPUT"