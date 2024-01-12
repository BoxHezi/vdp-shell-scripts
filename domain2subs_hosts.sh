#!/bin/bash

printTimeTaken() {
    local tip=$1  # subdomains or hosts
    local start=$2
    local end=$3
    local findingNum=$4
    local taken=$((end - start))

    echo "Find $findingNum $tip in $(gdate -d@$taken -u +%T) seconds"
}

find_subs() {
    domain=$1
    outname=$2

    while true; do
        startTime=$(gdate +%s)
        echo "$domain" | subfinder -silent | tee "$outname"
        if [ -s "$outname" ]; then
            endTime=$(gdate +%s)
            findingNum=$(wc <"$outname" -l)
            printTimeTaken "subdomains" "$startTime" "$endTime" "$findingNum" | tee -a "$outname"
            # return if file is not empty
            return 1
        fi
    done
}

find_hosts() {
    subs=$1
    outname=$2

    while true; do
        startTime=$(gdate +%s)
        dnsx -resp -silent <"$subs" | tee "$outname"
        if [ -s "$outname" ]; then
            endTime=$(gdate +%s)
            findingNum=$(wc <"$outname" -l)
            printTimeTaken "hosts" "$startTime" "$endTime" "$findingNum" | tee -a "$outname"
            # return if file is not empty
            return 1
        fi
    done
}

fromFile() {
    input=$1
    while IFS= read -r t; do
        echo "Processing target: $t"
        local subs_outname="subs_${t}.txt"
        local hosts_outname="hosts_${t}.txt"

        find_subs "$t" "$subs_outname"
        find_hosts "$subs_outname" "$hosts_outname"
        echo ""
    done < <(awk -F ' ' '{print $1}' "$input")
}

fromPipe() {
    totalTimeStart=$(gdate +%s)
    for ((i = 1; i <= $#; i++)); do
        domain="${!i}"
        echo "Processing target: $domain"
        local subs_outname="subs_${domain}.txt"
        local hosts_outname="hosts_${domain}.txt"

        find_subs "$domain" "$subs_outname"
        find_hosts "$subs_outname" "$hosts_outname"
        echo ""
    done
    totalTimeEnd=$(gdate +%s)
    totalTaken=$((totalTimeEnd - totalTimeStart))
    echo -e "\nTotal Time Taken: $(gdate -d@$totalTaken -u +%T) for $# domains"
}

if [ ! -t 0 ]; then
    declare -a targets
    while IFS= read -r line; do
        targets+=("$line")
    done
    fromPipe "${targets[@]}"
else
    targetsFile=$1
    if [ -z "$targetsFile" ]; then
        echo "Useage: $0 <input file>"
        exit 1
    elif [ ! -f "$targetsFile" ]; then
        echo "Error: $targetsFile does not exist or is not a file."
        exit 1
    else
        fromFile "$targetsFile"
    fi
fi
