#!/bin/bash

mysh_update_feats() {
    __clean_additional_info
    local -a feats
    for file in $MY_SH_DIR/*.sh; do
        local title=$(sed -n '2s/# In_Readme: //p' "$file")
        if [[ $title ]]; then
            local filename=$(basename "$file")
            local url="$MY_GH_SH_MAIN_URL/$filename"
            feats+=("\n### [$title]($url)")
            while IFS= read -r line; do
                if [[ $line == \#*pb* ]]; then
                    feats+=("\n✔️ **$(sed -E 's/# \*pb\*([^:]+):.*/\1/' <<<"$line")**: $(sed -E 's/# \*pb\*[^:]+:(.*)\*\*/\1/' <<<"$line")\n")
                fi
            done <"$file"
        fi
    done
    __write_additional_info "${feats[@]}"
}

__clean_additional_info() {
    sed -i '/\$\$ Features \$\$/,/------/{//!d}' $MY_SH_DIR/README.md
}

__write_additional_info() {
    sed -i '/\$\$ Features \$\$/a\'"$*" $MY_SH_DIR/README.md
}
