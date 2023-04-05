## @file
## @brief Add, update, or delete a post or page through the Blogger
## API.
## @details For more details, see:
## https://github.com/carmine560/blogger-posts

curl_options=-fSs
readonly API_SERVICE=https://www.googleapis.com/blogger/v3/blogs
bp_test_function_suffix=.json

# Obtain an access token.
ACCESS_TOKEN=$($get_access_token) || exit
readonly ACCESS_TOKEN

## @fn bp_check_variables()
## @brief Check if the values of variables is zero.
## @details Multiple variables are allowed.
## @param $variable A variable.
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

## @fn bp_list_resources()
## @brief List resources.
## @param $resource_type A resource type that can have the value \c
## posts or \c pages.
## @param $parameter An optional parameter.
## @return A response body in JSON.
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

## @fn bp_get_resource()
## @brief Retrieve a resource.
## @param $resource_type A resource type that can have the value \c
## posts or \c pages.
## @param $resource_id A resource (page or post) ID.
## @return A response body in JSON.
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

## @fn bp_add_resource()
## @brief Add a resource.
## @details Multiple property-value pairs are allowed.
## @param $resource_type A resource type that can have the value \c
## posts or \c pages.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
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

## @fn bp_delete_resource()
## @brief Delete a resource.
## @param $resource_type A resource type that can have the value \c
## posts or \c pages.
## @param $resource_id A resource (page or post) ID.
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

## @fn bp_partially_update_resource()
## @brief Partially update a resource.
## @details Multiple property-value pairs are allowed.
## @param $resource_type A resource type that can have the value \c
## posts or \c pages.
## @param $resource_id A resource (page or post) ID.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
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

## @fn bp_transition_resource_status()
## @brief Transition the resource status.
## @param $resource_type A resource type that can have the value \c
## posts or \c pages.
## @param $resource_id A resource (page or post) ID.
## @param $status A status that can have the value \c publish or \c
## revert.
## @return A response body in JSON.
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

## @fn bp_test_function()
## @brief Test a function.
## @param $parameters A function and parameters.
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
