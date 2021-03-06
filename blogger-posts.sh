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
## @details The variable \c resource_type can have the value \c posts
## (default) or \c pages.
## @param $parameters Optional parameters.
## @return A response body in JSON.
bp_list_resources() {
    if bp_check_variables; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X GET $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}?$1
    fi
}

## @fn bp_get_resource()
## @brief Retrieve a resource.
## @details The variable \c resource_type can have the value \c posts
## (default) or \c pages.  The variable \c resource_id needs to be
## assigned a value.
## @return A response body in JSON.
bp_get_resource() {
    if bp_check_variables resource_id; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X GET $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id
    fi
}

## @fn bp_add_resource()
## @brief Add a resource.
## @details The variable \c resource_type can have the value \c posts
## (default) or \c pages.  Multiple property-value pairs are allowed.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
bp_add_resource() {
    if bp_check_variables && [ $# != 0 -a $(($# % 2)) == 0 ]; then
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
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}?$bp_add_resource_parameters
    else
        echo Usage: ${FUNCNAME[0]} PROPERTY VALUE [PROPERTY VALUE ...] >&2
        exit 2
    fi
}

## @fn bp_delete_resource()
## @brief Delete a resource.
## @details The variable \c resource_type can have the value \c posts
## (default) or \c pages.  The variable \c resource_id needs to be
## assigned a value.
bp_delete_resource() {
    if bp_check_variables resource_id; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X DELETE $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id
    fi
}

## @fn bp_partially_update_resource()
## @brief Partially update a resource.
## @details The variable \c resource_type can have the value \c posts
## (default) or \c pages.  The variable \c resource_id needs to be
## assigned a value.  Multiple property-value pairs are allowed.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
bp_partially_update_resource() {
    if bp_check_variables resource_id &&
            [ $# != 0 -a $(($# % 2)) == 0 ]; then
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
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id
    else
        echo Usage: ${FUNCNAME[0]} PROPERTY VALUE [PROPERTY VALUE ...] >&2
        exit 2
    fi
}

## @fn bp_transition_resource_status()
## @brief Transition the resource status.
## @details The variable \c resource_type can have the value \c posts
## (default) or \c pages.  The variable \c resource_id needs to be
## assigned a value.
## @param $status The status \c publish or \c revert.
## @return A response body in JSON.
bp_transition_resource_status() {
    if bp_check_variables resource_id &&
            [ "$1" == publish -o "$1" == revert ]; then
        curl -H "Authorization: Bearer $ACCESS_TOKEN" \
             -X POST $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id/$1
    else
        echo Usage: ${FUNCNAME[0]} publish \| revert >&2
        exit 2
    fi
}

## @fn bp_test_function()
## @brief Test a function.
## @param $parameters A function and parameters.
bp_test_function() {
    if [ -d "$HOME/Downloads" ]; then
        local log_root="$HOME/Downloads/${0##*/}"
    else
        local log_root="$HOME/${0##*/}"
    fi
    if [ ! -d "$log_root" ]; then
        mkdir -v "$log_root" || exit
    fi
    log="$log_root/$$-${resource_type:=posts}-$(printf %04d $BASH_LINENO)-${1##*/}$bp_test_function_suffix"
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
