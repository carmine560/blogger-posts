## @file
## @brief

curl_options=-fSs
readonly API_SERVICE=https://www.googleapis.com/blogger/v3/blogs

default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID'
. configuration.sh && cfg_initialize_configuration || exit

# Obtain an access token.
access_token=$($get_access_token) || exit

## @fn bp_list_posts()
## @brief List posts.
## @param $parameters Optional parameters.
bp_list_posts() {
    curl -H "Authorization: Bearer $access_token" \
         -X GET $curl_options $curl_silent_options \
         $API_SERVICE/$BLOG_ID/posts?$1
}

## @fn bp_transition_post_status()
## @brief Transition the post status.
## @param $status \c publish or \c revert.
bp_transition_post_status() {
    if [ "$1" == publish -o "$1" == revert ]; then
        curl -H "Authorization: Bearer $access_token" \
             -X POST $curl_options $curl_silent_options \
             $API_SERVICE/$BLOG_ID/posts/$post_id/$1
    else
        echo Usage: ${FUNCNAME[0]} publish \| revert >&2
        exit 2
    fi
}

## @fn bp_partially_update_post()
## @brief Update the value of the property.
## @details Multiple pairs of a property and a value are allowed.
## @param $property A property without quotes.
## @param $value A value.
bp_partially_update_post() {
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
             $API_SERVICE/$BLOG_ID/posts/$post_id
    else
        echo Usage: ${FUNCNAME[0]} PROPERTY VALUE [PROPERTY VALUE ...] >&2
        exit 2
    fi
}
