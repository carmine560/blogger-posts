#!/bin/bash

set -o pipefail

default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID
bp_add_post_parameters='
. configuration.sh && cfg_initialize_configuration || exit

. blogger-posts.sh || exit

bpt_test() {
    if [ -d "$HOME/Downloads" ]; then
        local log="$HOME/Downloads/${BASH_SOURCE[0]##*/}"
    else
        local log="$HOME/${BASH_SOURCE[0]##*/}"
    fi
    if [ ! -d "$log" ]; then
        mkdir "$log" || exit
    fi
    "$@" >"$log/$$-$(printf %04d $BASH_LINENO)-${1##*/}"
    exit_status=$?
    if [ $exit_status == 0 ]; then
        echo Succeeded to "$@"
    else
        echo Failed to "$@"
        exit $exit_status
    fi
}

post_id=$(bp_add_post title 'Document Title' content '<p>A paragraph.</p>' |
              jq -r .id)
if [[ $post_id =~ [0-9]+ ]]; then
    echo $post_id was added
else
    echo Failed to add a post >&2
    exit 1
fi

bpt_test bp_transition_post_status revert
bpt_test bp_transition_post_status publish
bpt_test bp_list_posts
bpt_test bp_get_post
bpt_test bp_partially_update_post content '<p>An updated paragraph.</p>'
bpt_test bp_delete_post
