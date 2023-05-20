#!/bin/bash
#
# Title: Useful git and gh functions for semi-regular use
# Description: A collection of functions to improve your work with git and gh
# Author: Javi3Code
# Date: Saturday May 20, 2023
#

¡nav() {

    if [ "$2" = "-p" ]; then
        ¡pull
    fi
    git status
}

¡emptycommit() {
    git commit --allow-empty -m "$@"
}

¡setupstream_branch() {
    local branch=$(__actual_branch__)
    ¡setupstream_branch
    git branch --set-upstream-to=origin/$branch $branch
    echo "Set upstream(all) to origin/$branch"
}

¡setupstream_push() {
    local branch=$(__actual_branch__)
    git push -u origin $branch
    echo "Set upstream(push) to origin/$branch"
}

¡delbranch() {
    while getopts "b:r:l" opt; do
        case ${opt} in
        r)
            git push origin $OPTARG -d
            echo "Remote $OPTARG branch has been deleted"
            ;;
        l)
            git push $OPTARG -D
            echo "Local $OPTARG branch has been deleted"
            ;;
        esac
    done
}

¡backupbranch() {
    local backup="$(__actual_branch__)-backup"
    if [ $1 == -sw ]; then
        git checkout -b $backup
    else
        git branch $backup
    fi
    echo "$backup has been created"
}

¡orphanbranch() {
    git checkout --orphan $1
    if [ $2 == -r ]; then
        git rm -r --cached
    fi
    echo "$1 has been created"
}

__actual_branch__() {
    echo "$(git branch | sed -n -e "s/^\* \(.*\)/\1/p")"
}
