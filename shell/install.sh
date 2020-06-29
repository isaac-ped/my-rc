#!/bin/bash
# Helper script to install links to this in rc files

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
elif is_bash; then
    SHELLRC="$HOME/.bashrc"
fi

if grep "$TAG" $SHELLRC 2>&1 > /dev/null; then
    echo "Already appears to be inserted in $SHELLRC"
    echo "Cowardly refusing. Delete '$TAG' from $SHELLRC to continue"
    exit 1
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

MY_HOSTNAME=$(get_setting "prompt hostname")
MY_DEFAULT_HOST=$(get_setting "default host for ssh")

BASE_PROMPTCOLOR=""
if is_zsh; then
    source ~/.zshrc
    while [[ "$BASE_PROMPTCOLOR" == "" || "${fg[$BASE_PROMPTCOLOR]}" == "" ]]; do
        BASE_PROMPTCOLOR=$(get_setting "base prompt color")
        if [[ "$BASE_PROMPTCOLOR" == "" || "${fg[$BASE_PROMPTCOLOR]}" == "" ]]; then
            echo "$BASE_PROMPTCOLOR is not a color. yellow or green maybe?"
        fi
    done
fi

THISDIR="$(realpath $(dirname $0))"

TO_EXPORT="
$TAG

export DEFAULT_HOST=\"$MY_DEFAULT_HOST\"
PS1_HOSTNAME=\"$MY_HOSTNAME\"
PS1_HOSTCOLOR='\${fg[$BASE_PROMPTCOLOR]}'
RCDIR='$THISDIR'
"

echo $THISDIR

for RC_FILE in $THISDIR/*rc; do
    TO_EXPORT+="
source \$RCDIR/$(basename $RC_FILE)"
done

TO_EXPORT+="

### END INSERT FROM MYRC
"

echo "Inserting the following into $SHELLRC in 5 seconds..."
echo "$TO_EXPORT"

sleep 5

echo "$TO_EXPORT" >> $SHELLRC
