## @file
## @brief Read and write the plain text configuration file.

if [ -d "$HOME/.config" ]; then
    readonly CONFIGURATION=$HOME/.config/$(basename "$0" .${0##*.}).cfg
else
    readonly CONFIGURATION=$HOME/.$(basename "$0" .${0##*.}).cfg
fi

## @fn cfg_initialize_configuration()
## @brief Execute the existing configuration file, or create it.
## @param $mode The mode of the configuration file.
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
