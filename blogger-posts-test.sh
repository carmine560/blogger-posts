#!/bin/bash

set -o pipefail

default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID
bp_add_post_parameters=isDraft=true'
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

bp_transition_post_status publish
exit_status=$?
if [ $exit_status == 0 ]; then
    echo $post_id was published
else
    echo Failed to publish $post_id >&2
    exit $exit_status
fi

bp_partially_update_post content '<p>An updated paragraph.</p>'
exit_status=$?
if [ $exit_status == 0 ]; then
    echo $post_id was partially updated
else
    echo Failed to partially update $post_id >&2
    exit $exit_status
fi

bp_delete_post
exit_status=$?
if [ $exit_status == 0 ]; then
    echo $post_id was deleted
else
    echo Failed to delete $post_id >&2
    exit $exit_status
fi
