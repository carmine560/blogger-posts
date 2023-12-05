curl_options=-fSs
readonly API_SERVICE=https://www.googleapis.com/blogger/v3/blogs
bp_test_function_suffix=.json

ACCESS_TOKEN=$($get_access_token) || exit
readonly ACCESS_TOKEN

bp_check_variables() {
    local variable
    for variable in ACCESS_TOKEN API_SERVICE BLOG_ID; do
        if [ -z $(eval echo \$$variable) ]; then
            echo $variable is zero >&2
            exit 1
        fi
    done
    while [ $# -gt 0 ]; do
        if [ -z $(eval echo \$$1) ]; then
            echo $1 is zero >&2
            exit 1
        fi
        shift
    done
}

bp_list_resources() {
    if bp_check_variables && [ $# -ge 1 ] &&
            [ "$1" == posts -o "$1" == pages ]; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X GET $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/$1?$2
    else
        echo Usage: ${FUNCNAME[0]} RESOURCE_TYPE [PARAMETER] >&2
        exit 2
    fi
}

bp_get_resource() {
    if bp_check_variables && [ $# == 2 ] &&
            [ "$1" == posts -o "$1" == pages ] && [[ $2 =~ [0-9]+ ]]; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X GET $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/$1/$2
    else
        echo Usage: ${FUNCNAME[0]} RESOURCE_TYPE RESOURCE_ID >&2
        exit 2
    fi
}

bp_add_resource() {
    if bp_check_variables && [ $# -ge 3 -a $(($# % 2)) == 1 ] &&
            [ "$1" == posts -o "$1" == pages ]; then
        local resource_type=$1
        shift
        local index=0
        local parameters=("$@")
        local pairs
        while [ "$index" -lt ${#parameters[*]} ]; do
            if [ -z "$pairs" ]; then
                pairs="\"${parameters[index]}\": ${parameters[++index]}"
            else
                pairs="$pairs, \"${parameters[index]}\": ${parameters[++index]}"
            fi
            ((++index))
        done
        curl -d "{$pairs}" \
             -H "Authorization: Bearer $ACCESS_TOKEN" \
             -H 'Content-Type: application/json; charset=utf-8' \
             -X POST $curl_options \
             $API_SERVICE/$BLOG_ID/$resource_type?$bp_add_resource_parameters
    else
        echo Usage: ${FUNCNAME[0]} RESOURCE_TYPE PROPERTY VALUE \
             [PROPERTY VALUE ...] >&2
        exit 2
    fi
}

bp_delete_resource() {
    if bp_check_variables && [ $# == 2 ] &&
            [ "$1" == posts -o "$1" == pages ] && [[ $2 =~ [0-9]+ ]]; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X DELETE $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/$1/$2
    else
        echo Usage: ${FUNCNAME[0]} RESOURCE_TYPE RESOURCE_ID >&2
        exit 2
    fi
}

bp_partially_update_resource() {
    if bp_check_variables && [ $# -ge 4 -a $(($# % 2)) == 0 ] &&
            [ "$1" == posts -o "$1" == pages ] && [[ $2 =~ [0-9]+ ]]; then
        local resource_type=$1
        local resource_id=$2
        shift 2
        local index=0
        local parameters=("$@")
        local pairs
        while [ "$index" -lt ${#parameters[*]} ]; do
            if [ -z "$pairs" ]; then
                pairs="\"${parameters[index]}\": ${parameters[++index]}"
            else
                pairs="$pairs, \"${parameters[index]}\": ${parameters[++index]}"
            fi
            ((++index))
        done
        curl -d "{$pairs}" \
             -H "Authorization: Bearer $ACCESS_TOKEN" \
             -H 'Content-Type: application/json; charset=utf-8' \
             -X PATCH $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/$resource_type/$resource_id
    else
        echo Usage: ${FUNCNAME[0]} RESOURCE_TYPE RESOURCE_ID PROPERTY VALUE \
             [PROPERTY VALUE ...] >&2
        exit 2
    fi
}

bp_transition_resource_status() {
    if bp_check_variables && [ $# == 3 ] &&
            [ "$1" == posts -o "$1" == pages ] && [[ $2 =~ [0-9]+ ]] &&
            [ "$3" == publish -o "$3" == revert ]; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X POST $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/$1/$2/$3
    else
        echo Usage: ${FUNCNAME[0]} RESOURCE_TYPE RESOURCE_ID STATUS >&2
        exit 2
    fi
}

bp_test_function() {
    local base=$(basename "$0" .sh)
    if [ -d "$HOME/Downloads" ]; then
        local log_root="$HOME/Downloads/$base"
    else
        local log_root="$HOME/$base"
    fi
    if [ ! -d "$log_root" ]; then
        mkdir -v "$log_root" || exit
    fi
    log="$log_root/$$-$2-$(printf %04d $BASH_LINENO)-${1##*/}$bp_test_function_suffix"
    "$@" >"$log"
    local exit_status=$?
    if [ ! -s "$log" ]; then
        rm "$log"
    fi
    if [ $exit_status == 0 ]; then
        echo Succeeded to "$@"
    else
        echo Failed to "$@"
        exit $exit_status
    fi
}
