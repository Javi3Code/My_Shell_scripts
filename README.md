# General Info

Repository of bash plugins.

These plugins are complementary to my friend [@Kyrex23](https://github.com/kyrex23)'s repository: [Here](https://github.com/kyrex23/dotfiles) you can find information to install a pack of utilities.

# Installation

You need to have installed my friend's installation pack previously, and extra commands if it's necessary.
```bash
sudo apt install bat && ln -s $(which batcat) ~/.local/bin/bat
sudo apt install p7zip-full
sudo apt install fzf
sudo apt install xclip
```
- JSON/YAML
```bash
sudo apt install jq
sudo apt install pip
sudo apt install json-spec
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
yq shell-completion zsh > "${fpath[1]}/_y"
```

- Create directories:
```bash
mkdir -p ~/dev-tools/projects/shell_scripts
```

- Clone the repository:
```bash
git clone https://github.com/Javi3Code/My_Shell_scripts.git
```

- Create symbolic links in the directory created by kyrex23/dotfiles installation
```bash
    while IFS= read -r file; do
        ln -s "$file" -t "$ZDOTDIR"
        echo -e "agregate symbolic link:\n$file\nto:\n$ZDOTDIR"
    done <<< "$(find "$MY_SH_DIR" -name "*.sh")"
```
Now you can use the new commands.

## ⚠️ Warning

- [my_generic_fc.sh](https://github.com/Javi3Code/My_Shell_scripts/blob/main/my_generic_fc.sh) uses these variables: ***You can overrite it if it's necessary***
```bash
MY_GH_REPO_DIR=~/dev-tools/projects
MY_SH_DIR=$MY_GH_REPO_DIR/shell_scripts
MY_DOWNLOADS_DIR=~/Descargas
```

# Additional Info

$$ Features $$

### [Git Utils](https://github.com/Javi3Code/My_Shell_scripts/blob/main/git_utils.sh) 
### [Generic features](https://github.com/Javi3Code/My_Shell_scripts/blob/main/my_generic_fc.sh) 
✔️ **¡cleandw**:  Cleans the Downloads folder by removing all files and subdirectories within it.
 
✔️ **¡batch_zZmv**:  Batch processes all the zip files in the Downloads folder. Moves and extracts each zip file to the specified target folder and then removes the original zip file.
 
✔️ **¡zZmv**:  Moves and extracts a zip file to the target folder and then removes the original zip file.
 
✔️ **¡symlnk**:  Creates symbolic links for all shell scripts and _completions directories in the specified directory to the Zsh configuration directory.
 
✔️ **¡shupdt**:  Updates the shell scripts in the Zsh configuration directory with the latest versions from MY_SH_DIR.
 
✔️ **¡open**:  Opens a file or directory with Visual Studio Code or another specified program.
 
### [Workspaces Tool](https://github.com/Javi3Code/My_Shell_scripts/blob/main/my_workspaces.sh) 
✔️ **ws_register**:  Registers a new workspace based on interactive user input.
 
✔️ **ws_edit**:  Edits properties of a workspace with the specified short name in the MY_WORKSPACES_SRC file.
 
✔️ **ws_delete**:  Deletes a workspace with the specified short name from the MY_WORKSPACES_SRC file.
 
✔️ **ws_env_aux_delete**:  Deletes a specific env-aux or resource from a workspace.
 
✔️ **ws_show**:  Displays information about workspaces based on the provided command-line options.

------

# Release Notes
Latest version 0.1.0: Files added/updated {[my_generic_fc.sh](https://github.com/Javi3Code/My_Shell_scripts/blob/main/my_generic_fc.sh)}
