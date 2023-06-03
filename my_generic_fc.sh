#!/bin/bash
# In_Readme: Generic features
#
# Title: Useful functions for semi-regular use
# Description: A collection of useful functions for semi-regular use
# Author: Javi3Code
# Date: Saturday May 13, 2023
#

# Init const
export JAVA_HOME=~/.sdkman/candidates/java/current

export MY_GH_REPO_DIR=~/dev-tools/projects
export MY_SH_DIR=$MY_GH_REPO_DIR/shell_scripts
export MY_DOWNLOADS_DIR=~/Descargas
export MY_GH_SH_MAIN_URL=https://github.com/Javi3Code/My_Shell_scripts/blob/main
# End const

¡nav() {

}

# *pb*¡cleandw: Cleans the Downloads folder by removing all files and subdirectories within it.**
#     Arguments:
#         None
#     Returns:
#         None
¡cleandw() {
    find $MY_DOWNLOADS_DIR -mindepth 1 -maxdepth 1 -exec rm -r {} +
}

# *pb*¡batch_zZmv: Batch processes all the zip files in the Downloads folder.** Moves and extracts each zip file to the specified target folder and then removes the original zip file.
#     Arguments:
#         None
#     Returns:
#         None
¡batch_zZmv() {
    for zip_file in "$MY_DOWNLOADS_DIR"/*.zip; do
        ¡zZmv -f "$(basename "$zip_file")" -t rep -o dw
    done
}

# *pb*¡zZmv: Moves and extracts a zip file to the target folder and then removes the original zip file.**
#     Arguments:
#         -t <target>: Target folder where the zip file will be extracted.
#         -o <src>: Source folder where the zip file is located.
#         -f <zipSrc>: Name of the zip file.
#     Returns:
#         None
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

# *pb*¡symlnk: Creates symbolic links for all shell scripts and _completions directories in the specified directory to the Zsh configuration directory.**
#     Arguments:
#         None
#     Returns:
#         None
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

# *pb*¡shupdt: Updates the shell scripts in the Zsh configuration directory with the latest versions from MY_SH_DIR.**
#     Arguments:
#         None
#     Returns:
#         None
¡shupdt() {
    find $MY_SH_DIR -type f -name "*.sh" -exec cp {} $EXT_SCRIPTS_DIR/ \;
}

# *pb*¡open: Opens a file or directory with Visual Studio Code or another specified program.**
#     Arguments:
#         --zshrc: Opens the .zshrc file.
#         --generics: Opens the my_generic_fc.sh file.
#         --gits: Opens the git_utils.sh file.
#         --with=<command>: Opens the files with the specified command (default: code).
#         -d or -f: Ignored options.
#         <files>: Files or directories to open.
#     Returns:
#         None
¡open() {
    local command=code
    local -a files
    for arg in $@; do
        case $arg in
        --zshrc) files+=($ZDOTDIR/.zshrc) ;;
        --generics) files+=($MY_SH_DIR/my_generic_fc.sh) ;;
        --gits) files+=($MY_SH_DIR/git_utils.sh) ;;
        --with=*) command="${arg#*=}" ;;
        -d | -f) shift ;;
        *) files+=($arg) ;;
        esac
    done
    "$command" "${files[@]}"
}

# Helper function for zZmv to parse the argument.
__zZmv_args_parser() {
    case $1 in
    rep) echo $MY_GH_REPO_DIR ;;
    dw) echo $MY_DOWNLOADS_DIR ;;
    *) echo $1 ;;
    esac
}
