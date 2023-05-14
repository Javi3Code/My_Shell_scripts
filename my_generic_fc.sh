#!/bin/bash
#
# Title: Useful functions for semi-regular use
# Description: A collection of useful functions for semi-regular use
# Author: Javi3Code
# Date: Saturday May 13, 2023
#
MY_GH_REPO_DIR=~/dev-tools/projects
MY_SH_DIR=$MY_GH_REPO_DIR/shell_scripts
MY_DOWNLOADS_DIR=~/Descargas

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
            t )
                local target=$(__zZmv_args_parser__ "$OPTARG") ;;
            o )
                local src=$(__zZmv_args_parser__ "$OPTARG") ;;
            f )
                local zipSrc="$OPTARG" ;;
        esac
    done
    zipPathAbs=$src/$zipSrc
    echo "Usage: zZmv -d $target -t $src -o$zipPathAbs"
    7z x "$zipPathAbs" -o"$src" && mv "$src/${zipSrc%.*}" "$target" && rm "$zipPathAbs"
}
# Create symbolic links for all shell scripts in the specified directory to the Zsh configuration directory
¡symlnk(){
   find $MY_SH_DIR -name "*.sh" | while read file; do
        ln -s $file -t $ZDOTDIR
        echo "agregate symbolic link:\n ${target}\nto:\n${ZDOTDIR}"
    done;
}

# Update the shell scripts in the Zsh configuration directory with the latest versions
¡shupdt(){
    find $MY_SH_DIR -type f -name "*.sh" -exec cp {} $ZDOTDIR/ \;
}

# Open a file in Visual Studio Code
¡open(){
    case $1 in
        zshrc)
            local target=$ZDOTDIR/.zshrc;;
        genfc)
            local target=$MY_SH_DIR/my_generic_fc.sh;;
        *)
            local target=$1;;
    esac
    echo "Open with vscode: ${target}"
    code $target
}

# Helper function for zZmv to parse the argument
__zZmv_args_parser__(){
    case $1 in
        rep)
            echo $MY_GH_REPO_DIR;;
        dw)
            echo $MY_DOWNLOADS_DIR;;
        *)
            echo $1;;
    esac
}
