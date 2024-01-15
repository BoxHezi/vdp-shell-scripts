#!/usr/bin/env bash

ENDPOINT="https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/main/chaos-bugbounty-list.json"

targets=$(gron "$ENDPOINT" | grep -E "name|domains|url" | gron -u)
targetsNum=$(echo "$targets" | jq -r ".programs" | jq length)

chaosDir="./chaos-targets"
# check if chaosDir is exist
if [ ! -d "$chaosDir" ]; then
    mkdir "$chaosDir"
fi

for ((i = 0; i < targetsNum; i++)); do
    tempJSON=$(echo "$targets" | jq -r ".programs[$i]")

    name=$(echo "$tempJSON" | jq -r ".name")
    domains=$(echo "$tempJSON" | jq -r ".domains[]")

    if [[ "$domains" == "" ]]; then
        # ignore targets which doesn't contains domain
        echo "${name} contains 0 domain"
        continue
    fi

    url=$(echo "$tempJSON" | jq -r ".url")

    outfile="$chaosDir/$name.txt"
    echo "$url" | tee "$outfile"
    echo "$domains" | tee -a "$outfile"
done
