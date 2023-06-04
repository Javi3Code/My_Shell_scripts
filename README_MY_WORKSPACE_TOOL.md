# MY WORKSPACE BASH SHELL TOOL

## Description
`my_workspaces` is a Bash shell tool that provides useful functions to manage dynamic workspaces. It allows you to register new workspaces, initialize workspaces by opening the specified IDE and navigating to the workspace directory, change the current directory to the workspace directory, and more.

## Usage

### Register a new workspace
Registers a new workspace based on interactive user input. The script will prompt you to provide details such as the workspace name, short name, description, directory path, and runtime environment. You can also add optional environment auxiliary fields, including command and resources.

```bash
 ws_register
```

### Initialize a workspace
Initializes a workspace by opening the specified IDE and navigating to the workspace directory. Provide the workspace name or short name as an argument. Optionally, you can use the `--non-cd` flag to prevent changing the current directory to the workspace directory, and the `--non-init-env-aux` flag to skip initializing the environment auxiliary resources.

```bash
 ws_init <workspace-name> [--non-cd] [--non-init-env-aux]
```

### Change directory to a workspace
Changes the current directory to the workspace directory. Provide the workspace short name as an argument.

```bash
 ws_cd <workspace-short-name>
```

### Initialize environment auxiliary resources
Initializes the environment auxiliary resources for a workspace. Provide the workspace short name as an argument.

```bash
 ws_env_aux_init <workspace-short-name>
```

### Edit properties of a workspace
Edits properties of a workspace with the specified short name in the workspace configuration file. The script will guide you through interactive prompts to modify the workspace properties.

```bash
 ws_edit <workspace-short-name>
```

### Delete a workspace
Deletes a workspace with the specified short name from the workspace configuration file.

```bash
 ws_delete <workspace-short-name>
```

### Delete an environment auxiliary or resource
Deletes a specific environment auxiliary or resource from a workspace. Provide the workspace short name, environment auxiliary command, and flag (`--all` or `--show`) as arguments. Use the `--all` flag to delete the entire environment auxiliary, or the `--show` flag to display all resources and select resources to delete interactively.

```bash
 ws_env_aux_delete <workspace-short-name> --env-aux-command=<command> --all
 ws_env_aux_delete <workspace-short-name> --env-aux-command=<command> --show
```

### Edit environment auxiliary resources
Edits the environment auxiliary of a workspace by adding resources. Provide the workspace short name, environment auxiliary command, and flag (`--clip` or `--from-all-ws`) as arguments. Use the `--clip` flag to add the contents of the clipboard as a resource, or the `--from-all-ws` flag to show all the resources from other workspaces that are not already present in the specified env-aux and be able to select one of them.

```bash
 ws_env_aux_edit <workspace-short-name> --env-aux-command=<command> --clip
 ws_env_aux_edit <workspace-short-name> --env-aux-command=<command> --from-all-ws
```

### Show workspace details

Displays the details of a specific workspace based on its short name. Use the following command:

```bash
 ws_show --key=<workspace-short-name>
```

Replace `<workspace-short-name>` with the actual short name of the workspace you want to view. This command will retrieve and display the information about the specified workspace from the workspace configuration file.

You can also use the `--all` option to display information about all registered workspaces. Run the following command:

```bash
 ws_show --all
```

This will show detailed information about all the workspaces listed in the workspace configuration file.

If you only want to display the keys (name, short name, and description) of all workspaces, you can use the `--keys` option. Execute the following command:

```bash
 ws_show --keys
```

This will provide a concise list of workspace keys for all registered workspaces.

Feel free to explore the different options of `ws_show` to retrieve the workspace information you need.

## Configuration File
The workspace configuration file (`workspaces.yml`) stores the details of all registered workspaces. The file is in YAML format and contains a list of workspace objects, each representing a single workspace.

Example workspace object:

```yaml
workspaces:
- name: --shell
  short-name: -sh
  description: Workspace for working on shell plugins, bash scripting
  path: $MY_SH_DIR
  env: code
  env-aux:
  - command: google-chrome
    resources:
    - https://chat.openai.com/
    - https://github.com/Javi3Code/dotfiles/pulls
    - https://github.com/zsh-users/zsh-completions/tree/master
```

Feel free to customize the configuration file and add more workspaces as needed.

## Contributing
Contributions are welcome! If you have any ideas, suggestions, or bug reports, please create an issue or submit a pull request on the GitHub repository.

---

Please note that this README assumes a basic familiarity with Bash scripting and command-line tools. Make sure to set the necessary environment variables and have the required tools installed before using the `my_workspaces` tool. For detailed usage instructions and additional functionality, refer to the script's internal documentation.

I hope this README helps you effectively manage your workspaces with the `my_workspaces` tool. Let me know if you need any further assistance!
