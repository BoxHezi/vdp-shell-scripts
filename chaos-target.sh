#!/usr/local/bin/bash

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

    tempName=$(echo "$tempJSON" | jq -r ".name")
    tempDomains=$(echo "$tempJSON" | jq -r ".domains[]")

    if [[ "$tempDomains" == "" ]]; then
        # ignore targets which doesn't contains domain
        echo "$tempName"
        continue
    fi

    url=$(echo "$tempJSON" | jq -r ".url")

    outfile="$chaosDir/$tempName.txt"
    echo "$url" | tee "$outfile"
    echo "$tempDomains" | tee -a "$outfile"
done
