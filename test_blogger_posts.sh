#!/bin/bash

set -o pipefail

default_configuration="get_access_token='google_oauth_token.sh -a'
readonly BLOG_ID=BLOG_ID
bp_add_resource_parameters="
. configuration.sh initialize || exit

. blogger_posts.sh || exit

for resource_type in posts pages; do
    resource_id=$(bp_add_resource $resource_type title '"Resource Title"' \
                                  content '"<p>A paragraph.</p>"' |
                      jq -r .id)
    if [[ $resource_id =~ [0-9]+ ]]; then
        capitalized_resource_type=${resource_type^}
        echo ${capitalized_resource_type%s} $resource_id was added
    else
        echo Failed to add a resource >&2
        exit 1
    fi

    bp_test_function bp_list_resources $resource_type status=live
    bp_test_function bp_get_resource $resource_type $resource_id
    bp_test_function bp_partially_update_resource $resource_type $resource_id \
                     content '"<p>An updated paragraph.</p>"'
    bp_test_function bp_transition_resource_status $resource_type \
                     $resource_id revert
    bp_test_function bp_transition_resource_status $resource_type \
                     $resource_id publish
    bp_test_function bp_delete_resource $resource_type $resource_id
done
