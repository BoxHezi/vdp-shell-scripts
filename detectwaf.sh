#!/bin/bash

main() {
    prefix=$(echo "$1" | cut -d '.' -f1)

    result=$(wafw00f -i "$1" -f csv -o -)
    declare -a wafUrl
    declare -a noWafUrl

    echo -n "" >"${prefix}_WAF.txt"
    echo -n "" >"${prefix}_noWAF.txt"

    while IFS="," read -r url detected firewall manufacturer; do
        if [[ "$detected" == "True" ]]; then
            wafUrl+=("$url,$firewall,$manufacturer")
            echo "$url,$firewall,$manufacturer" >>"${prefix}_WAF.txt"
        elif [[ "$detected" == "False" ]]; then
            noWafUrl+=("$url")
            echo "$url" >>"${prefix}_noWAF.txt"
        fi
    done <<<"$result"

    echo "WAF Detected: "
    for i in "${wafUrl[@]}"; do
        echo "$i"
    done

    echo -e "\nNo WAF Detected: "
    for i in "${noWafUrl[@]}"; do
        echo "$i"
    done
}

input=$1
if [ -z "$input" ]; then
    echo "Usage: $0 <input file>"
    exit 1
elif [ ! -f "$input" ]; then
    echo "Error: $input does not exist or is not a file"
    exit 1
else
    main "$input"
fi
