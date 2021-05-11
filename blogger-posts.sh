## @file
## @brief Add, update, or delete a post or page through the Blogger
## API.

curl_options=-fSs
readonly API_SERVICE=https://www.googleapis.com/blogger/v3/blogs
bp_test_function_suffix=.json

# Obtain an access token.
access_token=$($get_access_token) || exit
if [ -z "$access_token" ]; then
    echo access_token is zero >&2
    exit 1
fi

## @fn bp_list_resources()
## @brief List resources.
## @details The variable \c resource can have the value \c posts
## (default) or \c pages.
## @param $parameters Optional parameters.
## @return A response body in JSON.
bp_list_resources() {
    curl -H "Authorization: Bearer $access_token" \
         -X GET $curl_options $curl_silent_options \
         $API_SERVICE/$BLOG_ID/${resource_type:=posts}?$1
}

## @fn bp_get_resource()
## @brief Retrieve a resource.
## @details The variable \c resource can have the value \c posts
## (default) or \c pages.
## @return A response body in JSON.
bp_get_resource() {
    if [ -z "$resource_id" ]; then
        echo resource_id is zero >&2
        exit 1
    else
        curl -H "Authorization: Bearer $access_token" \
             -X GET $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id
    fi
}

## @fn bp_add_resource()
## @brief Add a resource.
## @details Multiple pairs of a property and a value are allowed.  The
## variable \c resource can have the value \c posts (default) or \c
## pages.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
bp_add_resource() {
    if [ $# != 0 -a $(($# % 2)) == 0 ]; then
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
             -H "Authorization: Bearer $access_token" \
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
## @details The variable \c resource can have the value \c posts
## (default) or \c pages.
bp_delete_resource() {
    if [ -z "$resource_id" ]; then
        echo resource_id is zero >&2
        exit 1
    else
        curl -H "Authorization: Bearer $access_token" \
             -X DELETE $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id
    fi
}

## @fn bp_transition_post_status()
## @brief Transition the post status.
## @param $status \c publish or \c revert.
## @return A response body in JSON.
bp_transition_post_status() {
    if [ -z "$resource_id" ]; then
        echo resource_id is zero >&2
        exit 1
    else
        if [ "$1" == publish -o "$1" == revert ]; then
            curl -H "Authorization: Bearer $access_token" \
                 -X POST $curl_options $curl_silent_options \
                 $API_SERVICE/$BLOG_ID/posts/$resource_id/$1
        else
            echo Usage: ${FUNCNAME[0]} publish \| revert >&2
            exit 2
        fi
    fi
}

## @fn bp_partially_update_resource()
## @brief Partially update a resource.
## @details Multiple pairs of a property and a value are allowed.  The
## variable \c resource can have the value \c posts (default) or \c
## pages.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
bp_partially_update_resource() {
    if [ -z "$resource_id" ]; then
        echo resource_id is zero >&2
        exit 1
    else
        if [ $# != 0 -a $(($# % 2)) == 0 ]; then
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
                 -H "Authorization: Bearer $access_token" \
                 -H 'Content-Type: application/json; charset=utf-8' \
                 -X PATCH $curl_options $curl_silent_options \
                 $API_SERVICE/$BLOG_ID/${resource_type:=posts}/$resource_id
        else
            echo Usage: ${FUNCNAME[0]} PROPERTY VALUE [PROPERTY VALUE ...] >&2
            exit 2
        fi
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
