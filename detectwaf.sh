#!/bin/bash

wafw00fFile() {
    prefix=$(echo "$1" | cut -d "." -f1)
    local result
    result=$(wafw00f -i "$1" -f csv -o -)

    local -a wafUrl
    local -a noWafUrl

    wafFile="${prefix}_WAF.txt"
    noWafFile="${prefix}_noWAF.txt"
    echo -n "" >"$wafFile"
    echo -n "" >"$noWafFile"

    while IFS="," read -r url detected firewall manufacturer; do
        if [[ "$detected" == "True" ]]; then
            wafUrl+=("$url,$firewall,$manufacturer")
        elif [[ "$detected" == "False" ]]; then
            noWafUrl+=("$url")
        fi
    done <<<"$result"

    echo "WAF Detected: "
    for i in "${wafUrl[@]}"; do
        echo "$i" | tee -a "$wafFile"

    done

    echo -e "\nNo WAF Detected: "
    for i in "${noWafUrl[@]}"; do
        echo "$i" | tee -a "$noWafFile"
    done
}

wafw00fPipe() {
    local result
    local -a wafUrl
    local -a noWafUrl
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

    echo "WAF Detected: "
    for i in "${wafUrl[@]}"; do
        echo "$i"
    done

    echo -e "\nNo WAF Detected: "
    for i in "${noWafUrl[@]}"; do
        echo "$i"
    done
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
