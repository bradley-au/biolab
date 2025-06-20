#!/bin/bash
# bio cli tools: aaindex data processing
# 2025 b. morgan (ref: https://www.genome.jp/aaindex)

###### global variables, functions, defaults

SCRIPT_FILE="$(readlink -f ${BASH_SOURCE[0]:-${0}})"                  # full path to .sh file
SCRIPT_REL=$(echo "${SCRIPT_FILE}" | sed "s|${PWD}||g" 2>/dev/null)   # relative path to .shs file
SCRIPT_PATH="$(dirname "${SCRIPT_FILE}" 2>/dev/null)"                 # full path to script directory
DATA_URI="https://www.genome.jp/ftp/db/community/aaindex/aaindex1"    # remote data download location
DATA_PATH="${SCRIPT_PATH}"                                            # local data directory
OPSH_PATH="${SHELL:-${0:-$(which sh 2>/dev/null)}}"                   # path to operator shell binary
OPSH_INFO="${BASH_VERSION:-$(${OPSH_PATH} --version 2>/dev/null)}"    # shell details string
OPSH_VER="$(echo ${OPSH_INFO} | grep -oE "[0-9]\.[0-9]\.?[0-9]?")"    # shell version    
msg=(); code=0; exitcmd="return";                                     # execution mode control variables

###### environment, runtime validations

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && { msg=( "don't run directly, use source" ); exitcmd="exit"; code=1; }
[[ -z "${OPSH_VER}" ]] && { msg+=( "unexpected shell output (${OPSH_PATH}), use bash v5 or later" ); code=1; }
[[ "${OPSH_VER//.*/}" -lt 5 ]] && { msg+=( "unsupported shell (${OPSH_VER}), use bash v5 or later" ); code=1; }

###### functions

# --- print a script usage message

{ function aaindex.print.usage() {
    printf "\n\nload: source %s\nlist: %s.list\n run: %s.<action>.[subject]\n\n" \
        "${SCRIPT_FILE}" "${SCRIPT_FILE##*/}" "${SCRIPT_FILE##*/}" >&2
    printf "ex. source .%s; aaindex.data.download %s\n\n" "${SCRIPT_REL}"; return 0; }

function aaindex.print.env() { 
    printf "\nloading aaindex data tools ... "; sleep 1; 
    printf "OK (%s %s)\n\n" "${OPSH_PATH##*/}" "${OPSH_VER}" 2>&1; return 0; }

# --- data file download using system cli tool(s)

function aaindex.data.download () { 
    local uri="${1:-${DATA_URI}}"; local file="${uri##*/}"
    local out="${DATA_PATH}/${file}"; local cmd="wget -O ${out} ${uri}"
    [[ -e "${out}" ]] && read -p "${out} exists. overwrite? (Y/n) " conf
    [[ -z ${conf} ]] || [[ "${conf}" =~ (Y|y) ]] && { printf "\ndownloading ${uri} ... ";
        ${cmd} 2>/dev/null && printf "OK\n\n${file} download complete: ${out}\n\n" && return 0 || { 
            printf "FAIL\nerror: ${cmd}\n"; return 1; }; } || {
                echo -e "download cancelled\n"; return 1; } }
    
# --- parse nonstandard aaindex data into a standard machine readable structure

function aaindex.data.convert.json () {
    
    local file="${1:-aaindex1}"
    local input="${1:-${DATA_PATH}}"
    local output="${DATA_PATH}/${input##*/}"
    
    # nonstandard data layout, deserves an ugly solution :)
    cat "${input}/${file}" | tr -d '"' | sed -E 's/(^H) (.+)$/\"\2\": {/g' | 
        sed -E 's/(^[ADRTJCI])+[ \n\t]?(.*)[^ADRTJCI\n\t$ ]?/ \"\1\": \"\2 /g' | tr -d '\n' | 
            sed 's/\/\//\n/g' | sed -E 's/([ ]+\"+[ADRTJCI ]+\":)/\n\t\1/g' | tr -s ' ' |
                sed 's/[ARNDCQEGHI]+.*\/[LKMFPSTWYV]//g' | sed 's/ [A-Z].*\/[A-Z]" //g' | 
                    sed 's/$/",/g' > "${output}.json" && 
                    
    echo -e "\ndata conversion complete: ${output}.json\n\n" && return 0 || { 
        echo - "\nerror: data conversion failed, check input file: ${input}\n\n"; return 1; } }

# --- data file download using system cli tool(s)

function aaindex.list () { 
    
    local key="${SCRIPT_FILE##*/}"; local cmd=""
    local cmds=( $(grep "function $(echo "${key}" | cut -d'.' -f1)" "${SCRIPT_FILE}" 2>/dev/null) )
    
    (( ${?} == 0 )) && [[ ! -z ${cmds[@]} ]] || { 
        echo "error: i/o error (grep ${SCRIPT_FILE})"; return 1; }
    
    printf "\n=== %s commands ===\n\n" "${key}" 

    for cmd in ${cmds[@]}; do echo "${cmd}" | 
        grep -oE "([a-z]*\.[a-z]*)+" 2>/dev/null; done; printf "\n"; return 0; }

} 2>/dev/null # end functions

###### script default commands/output, run on source/exec

(( ${code} == 0 )) || { printf "\n"; for m in "${msg[@]}"; do printf "${m}\n"; done; 
    aaindex.print.usage 2>/dev/null; printf "\n"; ${exitcmd} 1; } 

aaindex.print.env 2>/dev/null