#!/bin/bash

## @file
## @brief Test the functions of `blogger-posts.sh`.
## @details For more details, see:
## https://github.com/carmine560/blogger-posts

set -o pipefail

# Set the configurable variables.
default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID
bp_add_resource_parameters='
. configuration.sh initialize || exit

# Load functions to add, update, or delete a resource through the
# Blogger API.
. blogger-posts.sh || exit

for i in '' pages; do
    resource_type=$i

    # Add a resource and assign the value of the key `id` in the
    # response body to the variable `resource_id`.
    resource_id=$(bp_add_resource title '"Resource Title"' \
                                  content '"<p>A paragraph.</p>"' |
                      jq -r .id)
    if [[ $resource_id =~ [0-9]+ ]]; then
        echo ${resource_type:-posts} $resource_id was added |
            sed 's/s / /'
    else
        echo Failed to add a resource >&2
        exit 1
    fi

    # Test each function that requires the variable `resource_id`
    # except for the function `bp_list_resources`.
    bp_test_function bp_list_resources status=live
    bp_test_function bp_get_resource
    bp_test_function bp_partially_update_resource content \
                     '"<p>An updated paragraph.</p>"'
    bp_test_function bp_transition_resource_status revert
    bp_test_function bp_transition_resource_status publish
    bp_test_function bp_delete_resource
done
