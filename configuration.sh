## @file
## @brief Read and write the plain or encrypted configuration file.

if [ -d "$HOME/.config" ]; then
    configuration=$HOME/.config/${0##*/}
else
    configuration=$HOME/.${0##*/}
fi

## @fn cfg_initialize_configuration()
## @brief Execute the existing configuration file, or create it.
## @param $mode The mode of the configuration file.
cfg_initialize_configuration() {
    if [ -f "$configuration" ]; then
        . "$configuration" || exit
    else
        read -p "$configuration does not exist.  Create it? [Y/n] "
        if [ -z "$REPLY" ] || [[ $REPLY =~ ^[Yy] ]]; then
            cat <<EOF >"$configuration" || exit
$default_configuration
EOF
            if [ ! -z "$1" ]; then
                chmod $1 "$configuration"
            fi
            exit
        else
            exit
        fi
    fi
}

## @fn cfg_initialize_encryption()
## @brief Execute the existing encrypted configuration file, or create
## it.
cfg_initialize_encryption() {
    readonly GPG_OPTIONS='--default-recipient-self --batch --yes'
    if [ -f "$configuration.gpg" ]; then
        eval "$(gpg -dq "$configuration.gpg" || echo exit $?)"
    else
        read -p "$configuration.gpg does not exist.  Create it? [Y/n] "
        if [ -z "$REPLY" ] || [[ $REPLY =~ ^[Yy] ]]; then
            cat <<EOF | gpg -e $GPG_OPTIONS -o "$configuration.gpg" || exit
$default_configuration
EOF
            exit
        else
            exit
        fi
    fi
}

## @fn cfg_set_encrypted_value()
## @brief Store the value of a variable in the encrypted
## configuration.
## @details Multiple pairs of parameters are allowed.
## @param $regex A regular expression for a variable.
## @param $replacement A replacement for the value.
cfg_set_encrypted_value() {
    if [ $# != 0 -a $(($# % 2)) == 0 ]; then
        cp "$configuration.gpg" "$configuration.gpg.bak" || exit
        local index=0
        local parameters=("$@")
        local sed_commands
        while [ "$index" -lt ${#parameters[*]} ]; do
            if [ -z "$sed_commands" ]; then
                sed_commands="s/^(\s*${parameters[index]}=).*$/\1${parameters[++index]}/"
            else
                sed_commands="$sed_commands; s/^(\s*${parameters[index]}=).*$/\1${parameters[++index]}/"
            fi
            ((++index))
        done
        gpg -dq "$configuration.gpg.bak" |
            sed -E "$sed_commands" |
            gpg -e $GPG_OPTIONS -o "$configuration.gpg" || exit
        rm "$configuration.gpg.bak" || exit
    else
        echo Usage: ${FUNCNAME[0]} VARIABLE VALUE [VARIABLE VALUE ...] >&2
        exit 2
    fi
}
