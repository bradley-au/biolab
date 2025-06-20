#!/bin/bash

# bio cli tools: aaindex data processing
# 2025 b. morgan (ref: https://www.genome.jp/aaindex)
# this script fetches protein data from the UniProt REST API
# results are filtered using provided (or default) control parameters, see below

# usage: ./aaindex.proteins.sh [minlen] [maxlen] [maxresults]
# example: ./proteins.sh 5 8 5
# Entry   Entry Name      Length  Sequence
# C0HJT2  NDBP8_TITSE     5       KIWRS
# P0DKJ0  P160B_ARATH     5       MFSPQ
# P0DOY5  HD101_HUMAN     5       GTTGT
# ... 

###### api control parameters 

MINLEN=${1:-5}                                       # minimum sequence length
MAXLEN=${2:-20}                                      # maximum sequence length
MAXRESULTS=${3:-100}                                 # total sequences to fetch
APIBASE="https://rest.uniprot.org/uniprotkb/search"  # data source

###### API query variables

QUERY="%28*%29+AND+%28reviewed%3Atrue%29+AND+%28length%3A%5B${MINLEN}+TO+${MAXLEN}%5D%29"
FIELDS="accession%2Cid%2Clength%2Csequence"
SORT="length+asc"
FORMAT="tsv"

###### execute the API request and fetch data
printf "\nfetching ${MAXRESULTS} protein sequences of length ${MINLEN} to ${MAXLEN} from ${APIBASE} ...\n\n"
curl -H "Accept: text/plain; format=tsv" "${APIBASE}?fields=${FIELDS}&format=${FORMAT}&query=${QUERY}&size=${MAXRESULTS}&sort=${SORT}" 2>/dev/null || {
    printf "FAIL\nerror: api request to ${APIBASE} failed, check parameters and/or debug the script:\n$(readlink -f ${BASH_SOURCE[0]:-${0}})\n\n"; exit 1; }

printf "\n"; exit 0

