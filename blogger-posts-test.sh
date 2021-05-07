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

bp_transition_post_status revert
exit_status=$?
if [ $exit_status == 0 ]; then
    echo $post_id was reverted
else
    echo Failed to revert $post_id >&2
    exit $exit_status
fi

bp_transition_post_status publish
exit_status=$?
if [ $exit_status == 0 ]; then
    echo $post_id was published
else
    echo Failed to publish $post_id >&2
    exit $exit_status
fi

post_titles=$(bp_list_posts | jq -r .items[].title)
sorted_post_titles=$(echo "$post_titles" | sort -u)
if [ -z "$post_titles" -o "$sorted_post_titles" == null ]; then
    echo Failed to list posts >&2
    exit 1
else
    cat <<EOF
List of posts are:
$post_titles
EOF
fi

bp_get_post
exit_status=$?
if [ $exit_status == 0 ]; then
    echo $post_id was retrieved
else
    echo Failed to retrieve $post_id >&2
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
