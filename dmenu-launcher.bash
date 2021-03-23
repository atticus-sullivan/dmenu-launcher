#!/bin/bash

set -x

readarray -t array < <(cat /media/daten/coding/dmenu-launcher/programs.dat | sort | tr -s "\t" " ")

resp=$(for ele in "${array[@]}"
do
	if [[ "$ele" == \#* ]]
	then continue
	fi

	name="${ele%% *}"
	cmd="${ele#${name} }"
	echo "$name"
done | dmenu -i -f)

echo $resp

[[ -z "$resp" ]] && exit 1

# cmd=$(awk -F" " '$1 == '"$resp"'{print $0}' < <(cat /media/daten/coding/dmenu-launcher/programs.dat | tr -s "\t" " ") | cut -d" " -f 2- | cut -d" " -f 2-)
cmd=$(awk '$0 ~ /^'"$resp"' /{print $0}' <<<$(cat /media/daten/coding/dmenu-launcher/programs.dat | tr -s "\t" " ") | cut -d" " -f 2-)

[[ -z "$cmd" ]] && cmd="$resp"
eval "$cmd" &
