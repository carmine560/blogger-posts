#!/bin/bash

default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID'
. configuration.sh && cfg_initialize_configuration || exit

. blogger-posts.sh || exit

# bp_list_posts $1
# bp_get_post
bp_add_post title Test content "<p>Test.</p>"
