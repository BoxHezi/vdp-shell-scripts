# vdp-shell-scripts

## Requirements

- [subfinder](https://github.com/projectdiscovery/subfinder)
- [dnsx](https://github.com/projectdiscovery/dnsx)
- [wafw00f](https://github.com/EnableSecurity/wafw00f)
- [gron](https://github.com/tomnomnom/gron)
- [jq](https://github.com/jqlang/jq)

### `domain2subs_hosts.sh`

input:

- files contains domains

output:

- `subs_<domain>.txt` contains subdomains
- `hosts_<domain>.txt` contains hosts

### `detectwaf.sh`

input:

- file contains urls

output:

- `<input filename>_WAF.txt` contains urls with WAF detected
- `<input filename>_noWAF.txt` contains urls without WAF detected

input:

- stdin

output:

- `<date +%F_%T>_WAF.txt` contains urls with WAF detected
- `<date +%F_%T>_noWAF.txt` contains urls without WAF detected

### `chaos-target.sh`

input:

- None

output:

- `<name>.txt` contains target domains, and url to bugbounty description
