# General Info

Repository of bash plugins.

These plugins are complementary to my friend @Kyrex23's repository: [Here](https://github.com/kyrex23/dotfiles) you can find information to install a pack of utilities.

# Installation

You need to have installed my friend's installation pack previously.

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
   find ~/dev-tools/projects/shell_scripts -name "*.sh" | while read file; do
        ln -s $file -t $ZDOTDIR
        echo "agregate symbolic link:\n ${target}\nto:\n${ZDOTDIR}"
    done;
```
Now you can use the new commands.

# Additional Info

## Generic features
- Clean the Downloads folder
- Batch process all the zip files in the Downloads folder
- Move and extract a zip file to the target folder and then remove the original zip file
- Create symbolic links for all shell scripts in the specified directory to the Zsh configuration directory
- Update the shell scripts in the Zsh configuration directory with the latest versions
- Open a file in Visual Studio Code

# Release Notes
Latest version 0.1.0: Files added/updated {[my_generic_fc.sh](https://github.com/Javi3Code/My_Shell_scripts/blob/main/my_generic_fc.sh)}
