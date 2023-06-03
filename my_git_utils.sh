#!/bin/bash
# In_Readme: Git Utils
#
# Title: Useful git and gh functions for semi-regular use
# Description: A collection of functions to improve your work with git and gh
# Author: Javi3Code
# Date: Saturday May 20, 2023
#

¡emptycommit() {
    git commit --allow-empty -m "$*"
}

¡setupstream_branch() {
    local branch=$(__actual_branch)
    ¡setupstream_push
    git branch --set-upstream-to=origin/$branch $branch
    echo "Set upstream(all) to origin/$branch"
}

¡setupstream_push() {
    local branch=$(__actual_branch)
    git push -u origin $branch
    echo "Set upstream(push) to origin/$branch"
}

¡delbranch() {
    while getopts "b:o:" opt; do
        case ${opt} in
        b)
            local branch="$OPTARG"
            ;;
        o)
            case $OPTARG in
            r)
                local del_execution=__del_rm_branch
                ;;
            l)
                local del_execution=__del_loc_branch
                ;;
            lr | rl)
                local del_execution=(__del_loc_branch __del_rm_branch)
                ;;
            esac
            ;;
        esac
        [[ -n "$del_execution" ]] && {
            for delcmd in "${del_execution[@]}"; do
                $delcmd $branch
            done
        }
    done
}

¡backupbranch() {
    local backup="$(__actual_branch)-backup"
    [[ $1 == -sw ]] && git checkout -b $backup || git branch $backup
    echo "$backup has been created"
}

¡orphanbranch() {
    git checkout --orphan $1
    [[ $2 == -r ]] && git rm -r --cached
    echo "$1 has been created"
}

__actual_branch() {
    echo "$(git branch | sed -n -e "s/^\* \(.*\)/\1/p")"
}

__del_rm_branch() {
    git push origin "$1" -d
    echo "Remote "$1" branch has been deleted"
}

__del_loc_branch() {
    git branch "$1" -D
    echo "Local "$1" branch has been deleted"
}
