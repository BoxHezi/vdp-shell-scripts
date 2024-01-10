#!/bin/bash

find_subs() {
    domain=$1
    outname=$2

    while true; do
        echo "$domain" | subfinder -silent | tee "$outname"
        if [ -s "$outname" ]; then
            # return if file is not empty
            return 1
        fi
    done
}

find_hosts() {
    subs=$1
    outname=$2

    while true; do
        dnsx -resp -silent <"$subs" | tee "$outname"
        if [ -s "$outname" ]; then
            # return if file is not empty
            return 1
        fi
    done
}

main() {
    while IFS= read -r t; do
        subs_outname="subs_${t}.txt"
        hosts_outname="hosts_${t}.txt"

        find_subs "$t" "$subs_outname"
        find_hosts "$subs_outname" "$hosts_outname"
        echo ""
    done < <(awk -F ' ' '{print $1}' "$targets")
}

# read command line argument
targets=$1

# check if targets is provided
if [ -z "$targets" ]; then
    echo "Please provide a file containing target domains."
    exit 1
# check if file exists
elif [ ! -f "$targets" ]; then
    echo "File $targets does not exist."
    exit 1
else
    main
fi
