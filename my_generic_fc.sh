#!/bin/bash
#
# Title: Useful functions for semi-regular use
# Description: A collection of useful functions for semi-regular use
# Author: Javi3Code
# Date: Saturday May 13, 2023
#
export MY_GH_REPO_DIR=~/dev-tools/projects
export MY_SH_DIR=$MY_GH_REPO_DIR/shell_scripts
export MY_DOWNLOADS_DIR=~/Descargas

# Clean the Downloads folder
¡cleandw() {
    find $MY_DOWNLOADS_DIR -mindepth 1 -maxdepth 1 -exec rm -r {} +
}

# Batch process all the zip files in the Downloads folder
¡batch_zZmv() {
    for zip_file in "$MY_DOWNLOADS_DIR"/*.zip; do
        ¡zZmv -f "$(basename "$zip_file")" -t rep -o dw
    done
}

# Move and extract a zip file to the target folder and then remove the original zip file
¡zZmv() {
    while getopts "t:o:f:" opt; do
        case ${opt} in
        t)
            local target=$(__zZmv_args_parser "$OPTARG")
            ;;
        o)
            local src=$(__zZmv_args_parser "$OPTARG")
            ;;
        f)
            local zipSrc="$OPTARG"
            ;;
        esac
    done
    zipPathAbs=$src/$zipSrc
    echo "Usage: zZmv -d $target -t $src -o$zipPathAbs"
    7z x "$zipPathAbs" -o"$src" && mv "$src/${zipSrc%.*}" "$target" && rm "$zipPathAbs"
}

# Create symbolic links for all shell scripts and _completions dirs in the specified directory to the Zsh configuration directory
¡symlnk() {
    while IFS= read -r file; do
        ln -s "$file" -t "$EXT_SCRIPTS_DIR" 2>/dev/null
        echo -e "agregate symbolic link:\n$file\nto:\n$EXT_SCRIPTS_DIR"
    done <<<"$(find "$MY_SH_DIR" -name "*.sh")"

    while IFS= read -r dir; do
        local target_dir="$EXT_COMPLETIONS_DIR/${dir##*/}"
        while IFS= read -r file; do
            ln -s "$file" "$EXT_COMPLETIONS_DIR" 2>/dev/null
            echo -e "agregate symbolic link:\n$file\nto:\n$EXT_COMPLETIONS_DIR"
        done <<<"$(find "$dir" -type f)"
    done <<<"$(find "$MY_SH_DIR" -type d -name "*_completions")"
}

# Update the shell scripts in the Zsh configuration directory with the latest versions
¡shupdt() {
    find $MY_SH_DIR -type f -name "*.sh" -exec cp {} $EXT_SCRIPTS_DIR/ \;
}

# Open a file or a directory in Visual Studio Code
¡open() {
    local -a files
    for arg in $@; do
        case $arg in
        --zshrc) files+=($ZDOTDIR/.zshrc) ;;
        --generics) files+=($MY_SH_DIR/my_generic_fc.sh) ;;
        --gits) files+=($MY_SH_DIR/git_utils.sh) ;;
        -d | -f) shift ;;
        *) files+=($arg) ;;
        esac
    done
    echo "Open with vscode: ${files[@]}"
    code "${files[@]}"
}

# Helper function for zZmv to parse the argument
__zZmv_args_parser() {
    case $1 in
    rep)
        echo $MY_GH_REPO_DIR
        ;;
    dw)
        echo $MY_DOWNLOADS_DIR
        ;;
    *)
        echo $1
        ;;
    esac
}
