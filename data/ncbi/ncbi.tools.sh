#!/bin/env bash

DATA_APIBASE="https://api.ncbi.nlm.nih.gov/datasets/v2"
DATA_APIDATA="${DATA_APIBASE}/gene/download"
DATA_DATATYPE="application/zip"
DATA_CONTENT="application/json"

which jq &>/dev/null || { echo "Error: 'jq' command is required but not installed."; return 1; }    

# ncbi.api.gene.download <gene_id> [<gene_id> ...]
# download gene data from NCBI Datasets API
# example: ncbi.api.gene.download 59067 50615

function ncbi.api.gene.download() {

    local gene_ids=("$@")
    local type="accept: ${DATA_DATATYPE}"
    local content="content-type: ${DATA_CONTENT}"
    local out="gene.zip"
    
    [[ ${#gene_ids[@]} -eq 0 ]] && { echo "use: ${FUNCNAME[0]} <gene_id> [<gene_id> ...]"; return 1; }

    printf "\nattempting api call to ${DATA_APIDATA} with gene_ids: %s\n" "${gene_ids[*]} ..."

    curl -s -X POST "${DATA_APIDATA}" -H "${type}" -H "${content}" --output "gene.zip" \
        -d "{\"gene_ids\":$(printf '%s' "${gene_ids[@]}" 2>/dev/null | jq -Rsc 'split(" ")')}" && 
            printf "OK\n\n" || { echo "Error: Failed to download gene data."; return 1; } 
    
    printf "\ndata downloaded successfully: ${out}\n\n"; }
    

printf "\n"; return 0;