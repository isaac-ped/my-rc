#!/bin/bash
#
# Helper script to install links to this repo in rc files
#
# For bash installation:
# $ bash install.sh
#
# For zsh installation:
# $ zsh install.sh

THISDIR="$(realpath "$(dirname $0)")"

TAG="### INSERTED FROM MYRC"

is_zsh() {
    [[ $(basename $SHELL) == "zsh" ]]
}
is_bash() {
    [[ $(basename $SHELL) == "bash" ]]
}

prompt() {
    if is_zsh; then
        read "ANS?$1 "
    elif is_bash; then
        read -p "$1 " ANS
    fi
    echo $ANS
}

if is_zsh; then
    SHELLRC="$HOME/.zshrc"
    if [[ ! -e ${THISDIR}/shellrc-cfg.yml ]]; then
        cp "${THISDIR}/shellrc-cfg-default.yml" "${THISDIR}/shellrc-cfg.yml"
        echo "Using the following defaults from prompts from ${THISDIR}/shellrc-cfg-default.yml"
        ymlook --pretty "${THISDIR}/shellrc-cfg.yml zsh prompt"
        echo "Edit that file to change..."
    fi
elif is_bash; then
    SHELLRC="$HOME/.bashrc"
fi



get_setting(){
    while true; do
        VAR=$(prompt "Enter $1")
        OKAY=$(prompt "$1 will be set to \"$VAR\" [Yn] ")
        if [[ "$OKAY" == "y" || "$OKAY" == "" ]]; then
            echo $VAR
            break
        fi
    done
}


MY_GIT_SHORTNAME=$(get_setting "git shortname (maybe ${USER:0:4}?)")

echo "Installing git configuration"
set -x
git config --global core.excludesFile "$(realpath $THISDIR/../git/gitignore_global)"
git config --global include.path "$(realpath $THISDIR/../git/gitconfig)"
git config --global user.shortname "$MY_GIT_SHORTNAME"
set +x

if grep "$TAG" $SHELLRC > 2>&1 /dev/null; then
    echo "Already appears to be inserted in $SHELLRC"
    echo "Cowardly refusing. Delete '$TAG' from $SHELLRC to continue"
    exit 1
fi

if [[ -e ~/.ssh/host-config.yml ]]; then
    echo "better-ssh config already exists (~/.ssh/host-config.yml)"
    echo "Not adding default host"
else
    echo "
    -l?:
        hostname: $MY_DEFAULT_HOST
    " > ~/.ssh/host-config.yml
    echo "Created ~/.ssh/host-config.yml"
fi


TO_EXPORT="
$TAG

source $THISDIR/shellrc

### END INSERT FROM MYRC
"

echo "Inserting the following into $SHELLRC in 5 seconds..."
echo "$TO_EXPORT"

sleep 5

echo "$TO_EXPORT" >> $SHELLRC
