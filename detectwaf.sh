#!/bin/bash

printUrls() {
    local tip="$1"
    local fileName="$2"

    echo -n "" >"$fileName"

    shift 2
    local urls=("$@")

    echo -e "$tip"
    for url in "${urls[@]}"; do
        echo "$url" | tee -a "$fileName"
    done
}

wafw00fFile() {
    local result
    local -a wafUrl
    local -a noWafUrl
    result=$(wafw00f -i "$1" -f csv -o -)

    prefix=$(echo "$1" | cut -d "." -f1)
    wafFile="${prefix}_WAF.txt"
    noWafFile="${prefix}_noWAF.txt"

    while IFS="," read -r url detected firewall manufacturer; do
        if [[ "$detected" == "True" ]]; then
            wafUrl+=("$url,$firewall,$manufacturer")
        elif [[ "$detected" == "False" ]]; then
            noWafUrl+=("$url")
        fi
    done <<<"$result"

    printUrls "WAF Detected:" "$wafFile" "${wafUrl[@]}"
    printUrls "\nNo WAF Detected:" "$noWafFile" "${noWafUrl[@]}"
}

wafw00fPipe() {
    local result
    local -a wafUrl
    local -a noWafUrl

    prefix=$(date +%F_%T)
    wafFile="${prefix}_WAF.txt"
    noWafFile="${prefix}_noWAF.txt"

    for ((i = 1; i <= $#; i++)); do
        result=$(wafw00f "${!i}" -f csv -o -)
        while IFS="," read -r url detected firewall manufacturer; do
            if [[ "$detected" == "True" ]]; then
                wafUrl+=("$url,$firewall,$manufacturer")
            elif [[ "$detected" == "False" ]]; then
                noWafUrl+=("$url")
            fi
        done <<<"$result"
    done

    printUrls "WAF Detected:" "$wafFile" "${wafUrl[@]}"
    printUrls "\nNo WAF Detected:" "$noWafFile" "${noWafUrl[@]}"
}

if [ ! -t 0 ]; then
    declare -a urls
    while IFS= read -r line; do
        urls+=("$line")
    done
    wafw00fPipe "${urls[@]}"
else
    input=$1
    if [ -z "$input" ]; then
        echo "Usage: $0 <input file>"
        exit 1
    elif [ ! -f "$input" ]; then
        echo "Error: $input does not exist or is not a file"
        exit 1
    else
        wafw00fFile "$input"
    fi
fi
