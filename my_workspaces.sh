#!/bin/bash
#
# Title: Useful functions to manage dynamic-workspaces
# Author: Javi3Code
# Date: Tuesday May 16, 2023
#

#Init const
MY_WORKSPACES_SRC=$MY_SH_DIR/resources/workspaces.yml
# End const

#=======================================================================================================================

# ws_register: Registers a new workspace based on interactive user input.
#     Reads input from the user for workspace details such as name, short name, description, directory path, and runtime environment.
#     Offers the option to add optional env-aux fields, including command and resources.
#     The new workspace is added to the existing workspaces list in the MY_WORKSPACES_SRC file.
#     Performs validation of the updated workspace file against the _workspace_schema.json schema.
#     Arguments:
#         None
#     Returns:
#         None
ws_register() {
    local new_workspace=$(__ws_register_interactive | tail -n 1)
    local workspaces_backup=$MY_SH_DIR/resources/workspaces-backup.yml
    cp $MY_WORKSPACES_SRC $workspaces_backup &&
        yq eval -i $new_workspace "$workspaces_backup" &&
        __validate_workspace $workspaces_backup &&
        yq eval -i $new_workspace "$MY_WORKSPACES_SRC"
    rm $workspaces_backup
}

# ws_delete: Deletes a workspace with the specified short name from the MY_WORKSPACES_SRC file.
#     Searches for the workspace with the provided short name in the workspaces list and removes it.
#     Arguments:
#         $1: Short name of the workspace to delete
#     Returns:
#         None
ws_delete() {
    yq eval -i 'del(.workspaces[] | select(.["short-name"] == "'"$1"'"))' $MY_WORKSPACES_SRC
}

# ws_show: Displays information about workspaces based on the provided command-line options.
#     Displays either all workspaces (--all), only workspace keys (--keys), or specific workspace details based on the short name (--key=<short-name>).
#     Arguments:
#         $1: Command-line option (--all, --keys, or --key=<short-name>)
#     Returns:
#         None
ws_show() {
    case $1 in
    --all) yq eval '.' $MY_WORKSPACES_SRC | envsubst ;;
    --keys) yq eval '.workspaces[] | { "name": .name, short-name: .short-name, "description": .description }' $MY_WORKSPACES_SRC ;;
    --key=*) yq eval '.workspaces[] | select(.["short-name"] == "'"${1#*=}"'")' $MY_WORKSPACES_SRC | envsubst ;;
    esac
}

# __validate_workspace: Validates the provided workspace file against the _workspace_schema.json schema using json_validator.py script.
#     Validates the workspace file using the specified JSON schema to ensure it adheres to the expected structure.
#     Arguments:
#         $1: Path to the workspace file to validate
#     Returns:
#         None
__validate_workspace() {
    local schema="$MY_SH_DIR/resources/_workspace_schema.json"
    local json=$(yq eval -o=json "$1")
    python3 $MY_SH_DIR/resources/json_validator.py "$schema" "$json"
}

# __ws_register_interactive: Helper function for interactive registration of a new workspace.
#     Guides the user through a series of prompts to provide workspace details.
#     Offers the option to add optional env-aux fields, including command and resources.
#     Constructs a JSON representation of the new workspace based on user input.
#     Returns the JSON representation of the new workspace.
#     Arguments:
#         None
#     Returns:
#         JSON representation of the new workspace
__ws_register_interactive() {

    echo "Register new workspace:"
    read "name?Name: "
    read "short_name?Short Name: "
    read "description?Description: "
    read "parentdir?Directory path: "
    read "ide?Runtime environment: "

    local new_workspace='
    {
        "name": "'"$name"'",
        "short-name": "'"$short_name"'",
        "description": "'"$description"'",
        "path": "'"$parentdir"'",
        "env": "'"$ide"'"
    }'
    read "add_env_aux?Do you want to add optional env-aux fields? (Y/N): "

    if [[ "$add_env_aux" =~ ^[Yy]$ ]]; then
        while true; do
            read "executor?Command: "
            read "resources?Resources (separated by commas): "
            IFS=',' read -rA resource_array <<<"$resources"
            local env_aux='{
                "command": "'"$executor"'",
                "resources": []
            }'
            for resource in "${resource_array[@]}"; do
                env_aux=$(jq --arg resource "$resource" '.resources += [$resource]' <<<"${env_aux}")
            done
            new_workspace=$(jq --argjson env_aux "$env_aux" '.["env-aux"] += [$env_aux]' <<<"${new_workspace}")
            read "add_more_env_aux?Add another env-aux field? (Y/N): "
            if [[ ! "$add_more_env_aux" =~ ^[Yy]$ ]]; then
                break
            fi
        done
    fi
    new_workspace=$(jq -c '.' <<<$new_workspace)
    echo '.workspaces +=' $new_workspace
}
