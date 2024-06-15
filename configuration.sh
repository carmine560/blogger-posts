if [ -d "$HOME/.config" ]; then
    configuration_directory=$HOME/.config/$(basename "$(dirname "$0")")
    if [ ! -d "$configuration_directory" ]; then
        mkdir -v "$configuration_directory" || exit
    fi
    readonly \
        CONFIGURATION=$configuration_directory/$(basename "$0" .${0##*.}).cfg
else
    readonly CONFIGURATION=$HOME/.$(basename "$0" .${0##*.}).cfg
fi

cfg_initialize_configuration() {
    if [ -f "$CONFIGURATION" ]; then
        . "$CONFIGURATION" || exit
    else
        read -p "$CONFIGURATION does not exist.  Create it? [Y/n] "
        if [ -z "$REPLY" ] || [[ $REPLY =~ ^[Yy] ]]; then
            cat <<EOF >"$CONFIGURATION" || exit
$default_configuration
EOF
            if [ ! -z "$1" ]; then
                chmod $1 "$CONFIGURATION"
            fi
            exit
        else
            exit
        fi
    fi
}
if [ "$1" == initialize ]; then
    cfg_initialize_configuration "$2"
fi
