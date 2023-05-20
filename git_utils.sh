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
    git branch --set-upstream-to=origin/$branch $branch
    echo "Set upstream to origin/$branch"
}

¡setupstream_push() {
    local branch=$(__actual_branch__)
    git push -u origin $branch
    ¡setupstream_branch
    echo "Set upstream to origin/$branch"
}

__actual_branch__() {
    echo "$(git branch | sed -n -e "s/^\* \(.*\)/\1/p")"
}
