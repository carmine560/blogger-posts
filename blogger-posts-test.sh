#!/bin/bash

set -o pipefail

default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID
bp_add_post_parameters='
. configuration.sh && cfg_initialize_configuration || exit

. blogger-posts.sh || exit

post_id=$(bp_add_post title 'Document Title' content '<p>A paragraph.</p>' |
              jq -r .id)
if [[ $post_id =~ [0-9]+ ]]; then
    echo $post_id was added
else
    echo Failed to add a post >&2
    exit 1
fi

bp_test bp_transition_post_status revert
bp_test bp_transition_post_status publish
bp_test bp_list_posts
bp_test bp_get_post
bp_test bp_partially_update_post content '<p>An updated paragraph.</p>'
bp_test bp_delete_post
