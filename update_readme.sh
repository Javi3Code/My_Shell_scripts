#!/bin/bash

# mysh_update_feats: Updates the features section in the README.md file based on the shell script files in the specified directory.
#     Arguments:
#         None
#     Returns:
#         None
mysh_update_feats() {
    {
        local -a feats
        for file in $MY_SH_DIR/*.sh; do
            local title=$(sed -n '2s/# In_Readme: //p' "$file")
            [[ $title ]] && {
                local filename=$(basename "$file")
                local url="$MY_GH_SH_MAIN_URL/$filename"
                feats+=("\n### [$title]($url)\n")
                while IFS= read -r line; do
                    if echo "$line" | grep -q '^# \*pb\*'; then
                        feats+=("\n✔️ **$(sed -E 's/# \*pb\*([^:]+):.*/\1/' <<<"$line")**: $(sed -E 's/# \*pb\*([^:]+):([^*]+)\*\*.*/\2/' <<<"$line")\n")
                    fi
                done <"$file"
            }
        done
        __write_additional_info "${feats[@]}"
    } &
    __clean_additional_info >/dev/null 2>&1 &
    disown
}

# __clean_additional_info: Cleans the additional info section in the README.md file.
#     Arguments:
#         None
#     Returns:
#         None
__clean_additional_info() {
    sed -i '/\$\$ Features \$\$/,/------/{//!d}' $MY_SH_DIR/README.md
}

# __write_additional_info: Writes additional info to the README.md file.
#     Arguments:
#         - feats: An array containing the additional info lines to be written.
#     Returns:
#         None
__write_additional_info() {
    sed -i '/\$\$ Features \$\$/a\'"$*" $MY_SH_DIR/README.md
}
