## @file
## @brief Add, update, remove a post through the Blogger API.

curl_options=-fSs
readonly API_SERVICE=https://www.googleapis.com/blogger/v3/blogs
bp_test_function_suffix=.json

# Obtain an access token.
access_token=$($get_access_token) || exit
if [ -z "$access_token" ]; then
    echo access_token is zero >&2
    exit 1
fi

## @fn bp_list_posts()
## @brief List posts.
## @details The variable \c resource can have the value \c posts or \c
## pages.
## @param $parameters Optional parameters.
## @return A response body in JSON.
bp_list_posts() {
    curl -H "Authorization: Bearer $access_token" \
         -X GET $curl_options $curl_silent_options \
         $API_SERVICE/$BLOG_ID/${resource:=posts}?$1
}

## @fn bp_get_post()
## @brief Retrieve a post.
## @details The variable \c resource can have the value \c posts or \c
## pages.
## @return A response body in JSON.
bp_get_post() {
    if [ -z "$post_id" ]; then
        echo post_id is zero >&2
        exit 1
    else
        curl -H "Authorization: Bearer $access_token" \
             -X GET $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource:=posts}/$post_id
    fi
}

## @fn bp_add_post()
## @brief Add a post.
## @details Multiple pairs of a property and a value are allowed.  The
## variable \c resource can have the value \c posts or \c pages.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
bp_add_post() {
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
             $API_SERVICE/$BLOG_ID/${resource:=posts}?$bp_add_post_parameters
    else
        echo Usage: ${FUNCNAME[0]} PROPERTY VALUE [PROPERTY VALUE ...] >&2
        exit 2
    fi
}

## @fn bp_delete_post()
## @brief Delete a post.
## @details The variable \c resource can have the value \c posts or \c
## pages.
bp_delete_post() {
    if [ -z "$post_id" ]; then
        echo post_id is zero >&2
        exit 1
    else
        curl -H "Authorization: Bearer $access_token" \
             -X DELETE $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/${resource:=posts}/$post_id
    fi
}

## @fn bp_transition_post_status()
## @brief Transition the post status.
## @param $status \c publish or \c revert.
## @return A response body in JSON.
bp_transition_post_status() {
    if [ -z "$post_id" ]; then
        echo post_id is zero >&2
        exit 1
    else
        if [ "$1" == publish -o "$1" == revert ]; then
            curl -H "Authorization: Bearer $access_token" \
                 -X POST $curl_options $curl_silent_options \
                 $API_SERVICE/$BLOG_ID/posts/$post_id/$1
        else
            echo Usage: ${FUNCNAME[0]} publish \| revert >&2
            exit 2
        fi
    fi
}

## @fn bp_partially_update_post()
## @brief Partially update a post.
## @details Multiple pairs of a property and a value are allowed.  The
## variable \c resource can have the value \c posts or \c pages.
## @param $property A property without quotes.
## @param $value A value.
## @return A response body in JSON.
bp_partially_update_post() {
    if [ -z "$post_id" ]; then
        echo post_id is zero >&2
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
                 $API_SERVICE/$BLOG_ID/${resource:=posts}/$post_id
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
    log="$log_root/$$-$(printf %04d $BASH_LINENO)-${1##*/}$bp_test_function_suffix"
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
