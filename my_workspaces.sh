#!/bin/bash
# In_Readme: Workspaces Tool
#
# Title: Useful functions to manage dynamic-workspaces
# Author: Javi3Code
# Date: Tuesday May 16, 2023
#

#Init const
MY_WORKSPACES_SRC=$MY_SH_DIR/resources/workspaces.yml
# End const

#=======================================================================================================================

# *pb*ws_register: Registers a new workspace based on interactive user input.**
#     Reads input from the user for workspace details such as name, short name, description, directory path, and runtime environment.
#     Offers the option to add optional env-aux fields, including command and resources.
#     The new workspace is added to the existing workspaces list in the MY_WORKSPACES_SRC file.
#     Performs validation of the updated workspace file against the _workspace_schema.json schema.
#     Arguments:
#         None
#     Returns:
#         None
ws_register() {
    echo "Register new workspace:"
    local new_workspace='.workspaces += '$(__ws_register_interactive)
    local workspaces_backup=$MY_SH_DIR/resources/workspaces-backup.yml
    cp $MY_WORKSPACES_SRC $workspaces_backup &&
        yq eval -i $new_workspace "$workspaces_backup" &&
        __validate_workspace $workspaces_backup &&
        yq eval -i $new_workspace "$MY_WORKSPACES_SRC"
    rm $workspaces_backup
}

ws_init() {
    local workspace_json=$(yq eval -o=json '.workspaces[] | select(.["short-name"] == "'"$1"'" or .name == "'"$1"'") | { "short-name": .["short-name"], "path": .path, "env": .env}' "$MY_WORKSPACES_SRC" | envsubst)
    echo $workspace_json
    [[ -n "$workspace_json" ]] && {
        local short_name=$(echo $workspace_json | jq -r '.["short-name"]')
        local directory=$(echo $workspace_json | jq -r '.path')
        local ide=$(echo $workspace_json | jq -r '.env')
        [[ -n "$ide" && "$ide" != '.' ]] && {
            $ide $directory
        } || echo "Principal environment not initialized"
        local args=("$2","$3")
        [[ "${args[*]}" =~ "--non-cd" ]] || cd $directory
        [[ "${args[*]}" =~ "--non-init-env-aux" ]] || ws_env_aux_init $1
    }
}
ws_cd() {
    local workspace_dir=$(yq eval '.workspaces[] | select(.["short-name"] == "'"$1"'") | .path' "$MY_WORKSPACES_SRC" | envsubst)
    cd "$workspace_dir" || echo "Failed to cd to workspace directory: $workspace_dir"
}

ws_env_aux_init() {
    local env_aux_json=$(yq eval -o=json '.workspaces[] | select(.["short-name"] == "'"$1"'") | .["env-aux"]' "$MY_WORKSPACES_SRC")
    echo $env_aux_json
    [[ -n "$env_aux_json" ]] && {
        echo "Initializing env-aux for workspace: $1"
        echo "$env_aux_json" | jq -c '.[]' | while IFS= read -r entry; do
            local command=$(echo "$entry" | jq -r '.command')
            local resources=($(echo "$entry" | jq -r '.resources[]'))
            {$command $resources} >/dev/null 2>&1 &
            disown || echo "Error trying to open env-aux"
        done
    } || echo "Workspace not found or env-aux not defined: $1"
}

# *pb*ws_edit: Edits properties of a workspace with the specified short name in the MY_WORKSPACES_SRC file.**
#     Searches for the workspace with the provided short name in the workspaces list and allows the user to edit its
# properties interactively.
#     The updated workspace is saved back to the MY_WORKSPACES_SRC file.
#     Arguments:
#         $1: Short name of the workspace to edit
#     Returns:
#         None
ws_edit() {
    local short_name="$1"
    local workspace_index=$(__ws_get_index $short_name)
    echo "Edit properties for workspace with shortname -> $short_name"
    local updated_workspace=$(__ws_update_interactive "$short_name")
    updated_workspace='.workspaces["'"$workspace_index"'"] = '$updated_workspace
    echo -e ${updaded_workspace}
    local workspaces_backup=$MY_SH_DIR/resources/workspaces-backup.yml
    cp $MY_WORKSPACES_SRC $workspaces_backup &&
        yq eval -i $updated_workspace "$workspaces_backup" &&
        __validate_workspace $workspaces_backup &&
        yq eval -i $updated_workspace "$MY_WORKSPACES_SRC"
    rm $workspaces_backup
}

# *pb*ws_delete: Deletes a workspace with the specified short name from the MY_WORKSPACES_SRC file.**
#     Searches for the workspace with the provided short name in the workspaces list and removes it.
#     Arguments:
#         $1: Short name of the workspace to delete
#     Returns:
#         None
ws_delete() {
    yq eval -i 'del(.workspaces['"$(__ws_get_index $1)"'])' $MY_WORKSPACES_SRC
}

# *pb*ws_env_aux_delete: Deletes a specific env-aux or resource from a workspace.**
#     Takes the workspace short name, env-aux command, and flag (--all, --show) as arguments.
#     If the flag is "--all", deletes the entire env-aux for the specified workspace.
#     If the flag is "--show", displays all the resources for the specified env-aux and allows the user to select and delete resources interactively.
#     Arguments:
#         $1: Short name of the workspace
#         $2: Env-aux command
#         $3: Flag (--all or --show)
#     Returns:
#         None
ws_env_aux_delete() {
    local short_name="$1"
    local command="$2"
    local flag="$3"
    local workspace_index=$(__ws_get_index $short_name)
    local workspace_path=".workspaces[$workspace_index]"
    local command_selector=''"$workspace_path"' ["env-aux"][] | select(.command == "'"$command"'")'
    [[ -n $(yq eval $command_selector $MY_WORKSPACES_SRC) ]] && {
        [[ "$flag" == "--all" ]] && {
            yq eval -i 'del('"$command_selector"')' $MY_WORKSPACES_SRC
            echo "Entire env-aux '$command' deleted successfully from workspace '$short_name'."
        } || [[ "$flag" == "--show" ]] && {
            local resources=$(yq eval ''"$command_selector"'.resources | .[]' $MY_WORKSPACES_SRC) &&
                [[ -n $resources ]] && {
                echo "Select resources to delete (use arrow keys to navigate, press Space to select, and press Enter to delete):"
                local -a resources_array_copy=()
                while IFS= read -r resource; do
                    resources_array_copy+=("$resource")
                done <<<"$resources"
                echo $resources[@] | cat -n | awk '{$1=$1-1; print}' | __ws_fzf_prompt |
                    {
                        local -a selected_resources=($(awk '{print $1}' | sort -rn))
                        for resource in "${selected_resources[@]}"; do
                            [[ $resource -ge 0 ]] && {
                                yq eval -i 'del('"$command_selector"'.resources['"$resource"'])' $MY_WORKSPACES_SRC
                                echo -e "$resources_array_copy[$resource+1] has been deleted"
                            } || echo "Error trying to delete $resources_array_copy[$resource+1]"
                        done
                    }
            } || echo "Empty-Resources for env-aux '$command' in workspace '$short_name'"
        } || echo "Invalid flag. Please specify either --all or --show."
    } || echo "Env-aux '$command' doesn't exist"
}

# *pb*ws_env_aux_edit: Edits the env-aux of a workspace by adding resources.**
#     Takes the workspace short name, env-aux command, and flag (--clip or --from-all-ws) as arguments.
#     Flag --clip, adds the contents of the clipboard as a resource to the specified env-aux.
#     Flag --from-all-ws, adds all the resources from other workspaces that are not already present in the specified env-aux.
#     Arguments:
#         $1: Short name of the workspace
#         $2: Env-aux command
#         $3: Flag (--clip or --from-all-ws)
#     Returns:
#         None
ws_env_aux_edit() {
    local short_name="$1"
    local command="$2"
    local flag="$3"
    local workspace_index=$(__ws_get_index $short_name)
    local env_aux_index=$(yq eval '.workspaces['"$workspace_index"'].["env-aux"][] | select(.command == "'"$command"'") | key' $MY_WORKSPACES_SRC)
    [[ -z "$env_aux_index" || "$env_aux_index" == "null" ]] && {
        echo "Error: Command '$command' does not exist in ws $short_name." >&2
        return -1
    } ||
        {
            [[ "$flag" == "--clip" ]] && {
                local resource=$(xpaste)
                echo -e "Do you want to add \n[ $resource ]"
                read "response?to the workspace with short-name = $short_name and env-aux.command = $command? (Y/N):"
                [[ "$response" =~ ^[Yy]$ ]] && {
                    yq eval -i '.workspaces['"$workspace_index"'].["env-aux"]['"$env_aux_index"'].resources += ["'"$resource"'"]' $MY_WORKSPACES_SRC
                    echo "Clipboard content has been added as a resource."
                } || echo "Nothing has been added"
            } || [[ "$flag" == "--from-all-ws" ]] && {
                local resources=$(yq eval \
                    '.workspaces[].["env-aux"][] | select(.command != "'"$command"'") | .resources[]' $MY_WORKSPACES_SRC) &&
                    [[ -n $resources ]] && {
                    echo "Select resources to delete (use arrow keys to navigate, press Space to select, and press Enter to delete):"
                    echo $resources[@] | __ws_fzf_prompt |
                        {
                            local -a selected_resources=($(awk '{print $1}')) &&
                                [[ -n "$selected_resources" ]] && {
                                for res in $selected_resources; do
                                    yq eval -i '.workspaces['"$workspace_index"'].["env-aux"]['"$env_aux_index"'].resources += ["'"$res"'"]' $MY_WORKSPACES_SRC &&
                                        echo -e "Added resource:\n$res" ||
                                        echo "Error trying to add resource ${res}"
                                done
                            } || echo "No resources selected"
                        }

                } || echo "Empty-Resources for selection"
            } || echo "Invalid flag. Please specify either --clip or --from-all-ws."
        } || echo "Env-aux '$command' doesn't exist"
}

# *pb*ws_show: Displays information about workspaces based on the provided command-line options.**
#     Displays either all workspaces (--all), only workspace keys (--keys), or specific workspace details based on the short name (--key=<short-name>).
#     Arguments:
#         $1: Command-line option (--all, --keys, or --key=<short-name>)
#     Returns:
#         None
ws_show() {
    case $1 in
    --all) yq -C -P eval '.' $MY_WORKSPACES_SRC | envsubst ;;
    --keys) yq -C -P eval '.workspaces[] | { "name": .name, short-name: .short-name, "description": .description }' $MY_WORKSPACES_SRC ;;
    --key=*) yq -C -P eval '.workspaces[] | select(.["short-name"] == "'"${1#*=}"'")' $MY_WORKSPACES_SRC | envsubst ;;
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
    read "name?Name: "
    read "short_name?Short Name: "
    read "description?Description: "
    read "parentdir?Directory path (Insert '.' if none required): "
    read "ide?Runtime environment (Insert '.' if none required): "

    local new_workspace='
    {
        "name": "'"$name"'",
        "short-name": "'"$short_name"'",
        "description": "'"$description"'",
        "path": "'"$parentdir"'",
        "env": "'"$ide"'"
    }'
    new_workspace=$(jq -c '.' <<<$(__ws_add_env_aux_interactive $new_workspace))
    echo $new_workspace
}

# __ws_update_interactive: Prompts the user to update properties of a workspace interactively.
#     Takes the short name of the workspace as input.
#     Retrieves the index and path of the workspace in the MY_WORKSPACES_SRC file.
#     Displays the current values of the workspace properties.
#     Asks the user to provide new values for each property, allowing them to keep the same value by pressing Enter.
#     Constructs a JSON representation of the updated workspace based on user input.
#     Calls the "__ws_parse_new_val" function to parse the new values, considering the previous values.
#     Calls the "__ws_add_env_aux_interactive" function to add optional env-aux fields to the updated workspace.
#     Returns the JSON representation of the updated workspace.
#     Arguments:
#         $1: Short name of the workspace to update
#     Returns:
#         JSON representation of the updated workspace
__ws_update_interactive() {
    local short_name="$1"
    local workspace_path=".workspaces[$workspace_index]"
    local name=$(yq eval "$workspace_path.name" $MY_WORKSPACES_SRC)
    read "new_name?Name [$name] (Press enter if you want to keep it the same): "
    read "new_short_name?Short-Name [$short_name] (Press enter if you want to keep it the same): "
    local description=$(yq eval "$workspace_path.description" $MY_WORKSPACES_SRC)
    read "new_description?Description [$description] (Press enter if you want to keep it the same): "
    local parentdir=$(yq eval "$workspace_path.path" $MY_WORKSPACES_SRC)
    read "new_parentdir?Directory path [$parentdir] (Insert '.' if none required or press enter if you want to keep it the same): "
    local ide=$(yq eval "$workspace_path.env" $MY_WORKSPACES_SRC)
    read "new_ide?Runtime environment [$ide] (Insert '.' if none required or press enter if you want to keep it the same): "
    local updated_workspace='
    {
        "name": "'"$(__ws_parse_new_val $name $new_name)"'",
        "short-name": "'"$(__ws_parse_new_val $shortname $new_short_name)"'",
        "description": "'"$(__ws_parse_new_val $description $new_description)"'",
        "path": "'"$(__ws_parse_new_val $parentdir $new_parentdir)"'",
        "env": "'"$(__ws_parse_new_val $ide $new_ide)"'"
    }'
    updated_workspace=$(jq -c '.' <<<$(__ws_add_env_aux_interactive $updated_workspace))
    echo $updated_workspace
}

# __ws_add_env_aux_interactive: Prompts the user to add optional env-aux fields to a workspace interactively.
#     Asks the user if they want to add optional env-aux fields.
#     If the user confirms, it guides them through a series of prompts to provide the command and resources for each
# env-aux field.
#     Constructs a JSON representation of the env-aux fields based on user input.
#     Adds the constructed env-aux fields to the provided workspace JSON.
#     Arguments:
#         $1: JSON representation of the workspace to update
#     Returns:
#         JSON representation of the updated workspace with added env-aux fields
__ws_add_env_aux_interactive() {
    read "add_env_aux?Do you want to add optional env-aux fields? (Y/N): "
    local new_workspace=$1
    [[ "$add_env_aux" =~ ^[Yy]$ ]] && {
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
    }
    echo $new_workspace
}

# __ws_get_index: Retrieves the index of a workspace with the specified short name from the MY_WORKSPACES_SRC file.
#     Searches for the workspace with the provided short name in the workspaces list and returns its index.
#     Arguments:
#         $1: Short name of the workspace
#     Returns:
#         Index of the workspace if found, otherwise displays an error message and returns 1
__ws_get_index() {
    local workspace_index=$(yq eval '.workspaces[] | select(.["short-name"] == "'"$1"'") | key' $MY_WORKSPACES_SRC)
    [[ -z "$workspace_index" || "$workspace_index" == "null" ]] && {
        echo "Error: Workspace with short name '$1' does not exist." >&2
        echo -1
    }
    echo $workspace_index
}

# __ws_parse_new_val: Parses the new value for a property, considering the previous value.
#     If the new value is an empty string, it echoes the previous value.
#     Arguments:
#         $1: Previous value of the property
#         $2: New value of the property
#     Returns:
#         value
__ws_parse_new_val() {
    [[ -z "$2" ]] && echo "$1" || echo "$2"
}

__ws_fzf_prompt() {
    fzf -m \
        --prompt='▶' --pointer='→' --marker='✔️' \
        --height=60% \
        --margin=6%,4%,4%,3% \
        --border=rounded \
        --color='dark,fg:green' \
        --info=inline \
        --layout=reverse-list \
        --header='ctrl-c or ESC:quit | tab:select/deselect-one ctrl-a:select-all ctrl-d:deselect-all' \
        --preview 'printf "%s\n" {+}' \
        --bind='ctrl-a:select-all' \
        --bind='ctrl-d:deselect-all' \
        --preview-window=up:50%:wrap
}
